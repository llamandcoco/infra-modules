# -----------------------------------------------------------------------------
# Terraform Configuration
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {
  count = var.caller_identity_override == null ? 1 : 0
}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Determine if using multiple rules or single rule
  use_multiple_rules = var.rules != null

  # For backwards compatibility: convert single rule to rules format
  single_rule_as_list = var.rules == null && var.rule_name != null ? [{
    name                = var.rule_name
    description         = var.rule_description
    event_pattern       = var.event_pattern
    schedule_expression = var.schedule_expression
    enabled             = var.is_enabled
    targets             = var.targets
  }] : []

  # Final rules list
  all_rules = local.use_multiple_rules ? var.rules : local.single_rule_as_list

  # Validate single rule type
  has_schedule      = var.schedule_expression != null
  has_event_pattern = var.event_pattern != null
  single_rule_type_valid = var.rules != null ? true : (
    var.rule_name == null ? true : (
      (local.has_schedule && !local.has_event_pattern) ||
      (!local.has_schedule && local.has_event_pattern)
    )
  )

  caller_identity = var.caller_identity_override != null ? var.caller_identity_override : data.aws_caller_identity.current[0]

  # Event bus name to use
  event_bus_name = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].name : var.event_bus_name

  # Flatten targets for IAM role permissions
  all_targets = flatten([
    for rule in local.all_rules : [
      for target in rule.targets : {
        arn     = target.arn
        service = split(":", target.arn)[2]
        is_ecs  = split(":", target.arn)[2] == "ecs"
      }
    ]
  ])

  # Determine target types for IAM policy generation
  target_services = distinct([for t in local.all_targets : t.service])

  # Map services to IAM permissions
  service_permissions = {
    "lambda"  = ["lambda:InvokeFunction"]
    "sqs"     = ["sqs:SendMessage"]
    "sns"     = ["sns:Publish"]
    "states"  = ["states:StartExecution"]
    "kinesis" = ["kinesis:PutRecord", "kinesis:PutRecords"]
    "ecs"     = ["ecs:RunTask"]
    "logs"    = ["logs:CreateLogStream", "logs:PutLogEvents"]
    "batch"   = ["batch:SubmitJob"]
  }

  # Build IAM policy statements for each target service
  iam_policy_statements = [
    for service in local.target_services : {
      Effect = "Allow"
      Action = lookup(local.service_permissions, service, [])
      Resource = [
        for t in local.all_targets :
        t.arn if t.service == service
      ]
    } if lookup(local.service_permissions, service, null) != null
  ]

  # Add ECS-specific IAM PassRole permissions if ECS targets exist
  has_ecs_targets = contains(local.target_services, "ecs")

  # Cross-account event bus policy
  should_create_bus_policy = var.create_event_bus && (length(var.allow_account_ids) > 0 || var.event_bus_policy_statement != null)

  # Auto-generated cross-account policy
  auto_generated_policy = length(var.allow_account_ids) > 0 ? jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowAccountsToPutEvents"
      Effect = "Allow"
      Principal = {
        AWS = [for account_id in var.allow_account_ids : "arn:aws:iam::${account_id}:root"]
      }
      Action   = "events:PutEvents"
      Resource = aws_cloudwatch_event_bus.this[0].arn
    }]
  }) : null

  # Use custom policy if provided, otherwise use auto-generated
  event_bus_policy = var.event_bus_policy_statement != null ? var.event_bus_policy_statement : local.auto_generated_policy

  # IAM role name
  role_name = var.role_name != null ? var.role_name : "${var.event_bus_name}-eventbridge-role"
}

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

resource "null_resource" "validate_single_rule_type" {
  count = var.rules == null ? 1 : 0

  lifecycle {
    precondition {
      condition     = local.single_rule_type_valid
      error_message = "When using single rule mode, exactly one of schedule_expression or event_pattern must be specified."
    }
  }
}

resource "null_resource" "validate_rules_or_single" {
  lifecycle {
    precondition {
      condition     = var.rules != null || var.rule_name != null
      error_message = "Either 'rules' or 'rule_name' must be specified."
    }
  }
}

# -----------------------------------------------------------------------------
# EventBridge Event Bus
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_bus" "this" {
  count = var.create_event_bus ? 1 : 0

  name = var.event_bus_name
  tags = var.tags
}

# -----------------------------------------------------------------------------
# EventBridge Event Bus Policy (Cross-Account)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_bus_policy" "this" {
  count = local.should_create_bus_policy ? 1 : 0

  event_bus_name = aws_cloudwatch_event_bus.this[0].name
  policy         = local.event_bus_policy
}

# -----------------------------------------------------------------------------
# EventBridge Archive
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_archive" "this" {
  count = var.archive_config != null ? 1 : 0

  name             = var.archive_config.name
  description      = var.archive_config.description
  event_source_arn = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].arn : "arn:aws:events:${data.aws_region.current.name}:${local.caller_identity.account_id}:event-bus/${var.event_bus_name}"
  retention_days   = var.archive_config.retention_days
  event_pattern    = var.archive_config.event_pattern
}

# -----------------------------------------------------------------------------
# EventBridge Rules
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for idx, rule in local.all_rules : rule.name => rule }

  name           = each.value.name
  description    = each.value.description
  event_bus_name = local.event_bus_name

  # Use schedule_expression if provided, otherwise use event_pattern
  schedule_expression = each.value.schedule_expression
  event_pattern       = each.value.event_pattern

  state = each.value.enabled ? "ENABLED" : "DISABLED"
  tags  = var.tags

  depends_on = [
    null_resource.validate_single_rule_type,
    null_resource.validate_rules_or_single,
    aws_cloudwatch_event_bus.this
  ]
}

# -----------------------------------------------------------------------------
# IAM Role for EventBridge
# -----------------------------------------------------------------------------

resource "aws_iam_role" "eventbridge" {
  count = var.create_role && length(local.all_rules) > 0 ? 1 : 0

  name                 = local.role_name
  description          = var.role_description != null ? var.role_description : "IAM role for EventBridge to invoke targets"
  path                 = var.role_path
  permissions_boundary = var.role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# -----------------------------------------------------------------------------
# IAM Policy for EventBridge Role
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "eventbridge" {
  count = var.create_role && length(local.all_rules) > 0 ? 1 : 0

  name = "${local.role_name}-policy"
  role = aws_iam_role.eventbridge[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # Target-specific permissions
      local.iam_policy_statements,
      # ECS PassRole permissions if needed
      local.has_ecs_targets ? [{
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }] : []
    )
  })
}

# -----------------------------------------------------------------------------
# Attach Additional Policies
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "additional" {
  count = var.create_role && length(local.all_rules) > 0 ? length(var.additional_policy_arns) : 0

  role       = aws_iam_role.eventbridge[0].name
  policy_arn = var.additional_policy_arns[count.index]
}

# -----------------------------------------------------------------------------
# EventBridge Targets
# -----------------------------------------------------------------------------

locals {
  # Flatten all targets with their rule name for for_each
  all_targets_flat = flatten([
    for rule in local.all_rules : [
      for target_idx, target in rule.targets : {
        key                    = "${rule.name}-${target.target_id}"
        rule_name              = rule.name
        target_id              = target.target_id
        arn                    = target.arn
        role_arn               = target.role_arn
        input                  = target.input
        input_path             = target.input_path
        input_transformer      = target.input_transformer
        dead_letter_config     = target.dead_letter_config
        retry_policy           = target.retry_policy
        sqs_parameters         = target.sqs_parameters
        ecs_parameters         = target.ecs_parameters
        batch_parameters       = target.batch_parameters
        kinesis_parameters     = target.kinesis_parameters
        run_command_parameters = target.run_command_parameters
        http_parameters        = target.http_parameters
      }
    ]
  ])

  targets_map = { for t in local.all_targets_flat : t.key => t }
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = local.targets_map

  rule           = aws_cloudwatch_event_rule.this[each.value.rule_name].name
  event_bus_name = local.event_bus_name
  target_id      = each.value.target_id
  arn            = each.value.arn

  # Use custom role if provided, otherwise use auto-created role
  role_arn = each.value.role_arn != null ? each.value.role_arn : (
    var.create_role ? aws_iam_role.eventbridge[0].arn : null
  )

  # Input transformation
  input      = each.value.input
  input_path = each.value.input_path

  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths_map
      input_template = input_transformer.value.input_template
    }
  }

  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_config != null ? [each.value.dead_letter_config] : []
    content {
      arn = dead_letter_config.value.arn
    }
  }

  # Retry policy
  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
    content {
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age_in_seconds
    }
  }

  # SQS-specific parameters
  dynamic "sqs_target" {
    for_each = each.value.sqs_parameters != null ? [each.value.sqs_parameters] : []
    content {
      message_group_id = sqs_target.value.message_group_id
    }
  }

  # ECS-specific parameters
  dynamic "ecs_target" {
    for_each = each.value.ecs_parameters != null ? [each.value.ecs_parameters] : []
    content {
      task_definition_arn     = ecs_target.value.task_definition_arn
      task_count              = ecs_target.value.task_count
      launch_type             = ecs_target.value.launch_type
      platform_version        = ecs_target.value.platform_version
      group                   = ecs_target.value.group
      enable_ecs_managed_tags = ecs_target.value.enable_ecs_managed_tags
      enable_execute_command  = ecs_target.value.enable_execute_command
      propagate_tags          = ecs_target.value.propagate_tags
      tags                    = ecs_target.value.tags

      dynamic "network_configuration" {
        for_each = ecs_target.value.network_configuration != null ? [ecs_target.value.network_configuration] : []
        content {
          subnets          = network_configuration.value.subnets
          security_groups  = network_configuration.value.security_groups
          assign_public_ip = network_configuration.value.assign_public_ip
        }
      }

      dynamic "capacity_provider_strategy" {
        for_each = ecs_target.value.capacity_provider_strategy != null ? ecs_target.value.capacity_provider_strategy : []
        content {
          capacity_provider = capacity_provider_strategy.value.capacity_provider
          weight            = capacity_provider_strategy.value.weight
          base              = capacity_provider_strategy.value.base
        }
      }

      dynamic "placement_constraint" {
        for_each = ecs_target.value.placement_constraints != null ? ecs_target.value.placement_constraints : []
        content {
          type       = placement_constraint.value.type
          expression = placement_constraint.value.expression
        }
      }

    }
  }

  # Batch-specific parameters
  dynamic "batch_target" {
    for_each = each.value.batch_parameters != null ? [each.value.batch_parameters] : []
    content {
      job_definition = batch_target.value.job_definition
      job_name       = batch_target.value.job_name
      array_size     = try(batch_target.value.array_properties.size, null)
      job_attempts   = try(batch_target.value.retry_strategy.attempts, null)
    }
  }

  # Kinesis-specific parameters
  dynamic "kinesis_target" {
    for_each = each.value.kinesis_parameters != null ? [each.value.kinesis_parameters] : []
    content {
      partition_key_path = kinesis_target.value.partition_key_path
    }
  }

  # Run Command-specific parameters
  dynamic "run_command_targets" {
    for_each = each.value.run_command_parameters != null ? each.value.run_command_parameters.run_command_targets : []
    content {
      key    = run_command_targets.value.key
      values = run_command_targets.value.values
    }
  }

  # HTTP-specific parameters (API Destinations)
  dynamic "http_target" {
    for_each = each.value.http_parameters != null ? [each.value.http_parameters] : []
    content {
      path_parameter_values   = http_target.value.path_parameter_values
      header_parameters       = http_target.value.header_parameters
      query_string_parameters = http_target.value.query_string_parameters
    }
  }

  depends_on = [
    aws_iam_role_policy.eventbridge,
    aws_iam_role_policy_attachment.additional
  ]
}
