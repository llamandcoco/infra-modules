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
  # Validate that exactly one of schedule_expression or event_pattern is specified
  has_schedule      = var.schedule_expression != null
  has_event_pattern = var.event_pattern != null
  rule_type_valid   = (local.has_schedule && !local.has_event_pattern) || (!local.has_schedule && local.has_event_pattern)

  caller_identity = var.caller_identity_override != null ? var.caller_identity_override : data.aws_caller_identity.current[0]

  # Event bus name to use
  event_bus_name = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].name : var.event_bus_name

  # IAM role name
  role_name = var.role_name != null ? var.role_name : "${var.rule_name}-eventbridge-role"

  # Determine target types for IAM policy generation
  target_arns = [for target in var.targets : target.arn]

  # Extract service from ARN to determine permissions needed
  # ARN format: arn:partition:service:region:account-id:resource
  target_services = distinct([
    for arn in local.target_arns :
    split(":", arn)[2] # Extract service from ARN
  ])

  # Map services to IAM permissions
  service_permissions = {
    "lambda" = [
      "lambda:InvokeFunction"
    ]
    "sqs" = [
      "sqs:SendMessage"
    ]
    "sns" = [
      "sns:Publish"
    ]
    "states" = [
      "states:StartExecution"
    ]
    "kinesis" = [
      "kinesis:PutRecord",
      "kinesis:PutRecords"
    ]
    "ecs" = [
      "ecs:RunTask"
    ]
    "logs" = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    "batch" = [
      "batch:SubmitJob"
    ]
  }

  # Build IAM policy statements for each target service
  iam_policy_statements = [
    for service in local.target_services : {
      Effect = "Allow"
      Action = lookup(local.service_permissions, service, [])
      Resource = [
        for arn in local.target_arns :
        arn if split(":", arn)[2] == service
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
}

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

resource "null_resource" "validate_rule_type" {
  lifecycle {
    precondition {
      condition     = local.rule_type_valid
      error_message = "Exactly one of schedule_expression or event_pattern must be specified."
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
# EventBridge Rule
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "this" {
  name           = var.rule_name
  description    = var.rule_description
  event_bus_name = local.event_bus_name

  # Use schedule_expression if provided, otherwise use event_pattern
  schedule_expression = var.schedule_expression
  event_pattern       = var.event_pattern

  state = var.is_enabled ? "ENABLED" : "DISABLED"
  tags  = var.tags

  depends_on = [
    null_resource.validate_rule_type,
    aws_cloudwatch_event_bus.this
  ]
}

# -----------------------------------------------------------------------------
# IAM Role for EventBridge
# -----------------------------------------------------------------------------

resource "aws_iam_role" "eventbridge" {
  count = var.create_role ? 1 : 0

  name                 = local.role_name
  description          = var.role_description != null ? var.role_description : "IAM role for EventBridge rule ${var.rule_name} to invoke targets"
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
  count = var.create_role ? 1 : 0

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
  count = var.create_role ? length(var.additional_policy_arns) : 0

  role       = aws_iam_role.eventbridge[0].name
  policy_arn = var.additional_policy_arns[count.index]
}

# -----------------------------------------------------------------------------
# EventBridge Targets
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_target" "this" {
  count = length(var.targets)

  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = local.event_bus_name
  target_id      = var.targets[count.index].target_id
  arn            = var.targets[count.index].arn

  # Use custom role if provided, otherwise use auto-created role
  role_arn = var.targets[count.index].role_arn != null ? var.targets[count.index].role_arn : (
    var.create_role ? aws_iam_role.eventbridge[0].arn : null
  )

  # Input transformation
  input      = var.targets[count.index].input
  input_path = var.targets[count.index].input_path

  dynamic "input_transformer" {
    for_each = var.targets[count.index].input_transformer != null ? [var.targets[count.index].input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths_map
      input_template = input_transformer.value.input_template
    }
  }

  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.targets[count.index].dead_letter_config != null ? [var.targets[count.index].dead_letter_config] : []
    content {
      arn = dead_letter_config.value.arn
    }
  }

  # Retry policy
  dynamic "retry_policy" {
    for_each = var.targets[count.index].retry_policy != null ? [var.targets[count.index].retry_policy] : []
    content {
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age_in_seconds
    }
  }

  # SQS-specific parameters
  dynamic "sqs_target" {
    for_each = var.targets[count.index].sqs_parameters != null ? [var.targets[count.index].sqs_parameters] : []
    content {
      message_group_id = sqs_target.value.message_group_id
    }
  }

  # ECS-specific parameters
  dynamic "ecs_target" {
    for_each = var.targets[count.index].ecs_parameters != null ? [var.targets[count.index].ecs_parameters] : []
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
    for_each = var.targets[count.index].batch_parameters != null ? [var.targets[count.index].batch_parameters] : []
    content {
      job_definition = batch_target.value.job_definition
      job_name       = batch_target.value.job_name
      array_size     = try(batch_target.value.array_properties.size, null)
      job_attempts   = try(batch_target.value.retry_strategy.attempts, null)
    }
  }

  # Kinesis-specific parameters
  dynamic "kinesis_target" {
    for_each = var.targets[count.index].kinesis_parameters != null ? [var.targets[count.index].kinesis_parameters] : []
    content {
      partition_key_path = kinesis_target.value.partition_key_path
    }
  }

  # Run Command-specific parameters
  dynamic "run_command_targets" {
    for_each = var.targets[count.index].run_command_parameters != null ? var.targets[count.index].run_command_parameters.run_command_targets : []
    content {
      key    = run_command_targets.value.key
      values = run_command_targets.value.values
    }
  }

  # HTTP-specific parameters (API Destinations)
  dynamic "http_target" {
    for_each = var.targets[count.index].http_parameters != null ? [var.targets[count.index].http_parameters] : []
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
