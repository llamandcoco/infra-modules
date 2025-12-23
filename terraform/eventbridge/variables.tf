# -----------------------------------------------------------------------------
# Event Bus Configuration
# -----------------------------------------------------------------------------

variable "event_bus_name" {
  description = "Name of the EventBridge event bus. Use 'default' for the AWS default event bus, or provide a custom name to create a new event bus."
  type        = string
  default     = "default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.event_bus_name))
    error_message = "Event bus name must only contain alphanumeric characters, hyphens, underscores, and periods."
  }

  validation {
    condition     = length(var.event_bus_name) >= 1 && length(var.event_bus_name) <= 256
    error_message = "Event bus name must be between 1 and 256 characters long."
  }
}

variable "create_event_bus" {
  description = <<-EOT
    Whether to create a custom event bus. Set to false to use the default event bus.
    - true: Creates a new custom event bus with the name specified in event_bus_name
    - false: Uses the AWS default event bus (event_bus_name will be ignored if not 'default')
  EOT
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Event Rule Configuration
# -----------------------------------------------------------------------------

variable "rule_name" {
  description = "Name of the EventBridge rule. Must be unique within the event bus."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.rule_name))
    error_message = "Rule name must only contain alphanumeric characters, hyphens, underscores, and periods."
  }

  validation {
    condition     = length(var.rule_name) >= 1 && length(var.rule_name) <= 64
    error_message = "Rule name must be between 1 and 64 characters long."
  }
}

variable "rule_description" {
  description = "Description of the EventBridge rule. Helps document the purpose of the rule."
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = <<-EOT
    Schedule expression for the rule. Use either rate() or cron() expressions.
    Examples:
    - Rate: "rate(5 minutes)", "rate(1 hour)", "rate(1 day)"
    - Cron: "cron(0 12 * * ? *)" (daily at noon UTC), "cron(0 9 ? * MON-FRI *)" (weekdays at 9 AM)
    Note: Either schedule_expression or event_pattern must be specified, but not both.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.schedule_expression == null || can(regex("^(rate|cron)\\(.+\\)$", var.schedule_expression))
    error_message = "Schedule expression must be a valid rate() or cron() expression."
  }
}

variable "event_pattern" {
  description = <<-EOT
    Event pattern in JSON format. Matches events from AWS services or custom applications.
    Example:
    {
      "source": ["aws.ec2"],
      "detail-type": ["EC2 Instance State-change Notification"],
      "detail": {
        "state": ["running"]
      }
    }
    Note: Either schedule_expression or event_pattern must be specified, but not both.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.event_pattern == null || can(jsondecode(var.event_pattern))
    error_message = "Event pattern must be a valid JSON string."
  }
}

variable "is_enabled" {
  description = "Whether the rule is enabled. Set to false to temporarily disable the rule without deleting it."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Rule Type Validation
# -----------------------------------------------------------------------------

# NOTE: Terraform doesn't support cross-variable validation in variable blocks.
# The validation that ensures exactly one of schedule_expression or event_pattern
# is specified is handled in the locals block in main.tf using precondition.

# -----------------------------------------------------------------------------
# Event Targets Configuration
# -----------------------------------------------------------------------------

variable "targets" {
  description = <<-EOT
    List of targets for the EventBridge rule (single rule mode only).
    If using 'rules' variable for multiple rules, this should be null.

    Each target represents a service to invoke when the rule matches.
    AWS allows up to 5 targets per rule.

    Required fields:
    - target_id: Unique identifier for the target (used for tracking)
    - arn: ARN of the target resource (Lambda, SQS, SNS, Step Functions, Kinesis, ECS, CloudWatch Logs)

    Optional fields for input transformation:
    - input: Static JSON input to pass to the target (conflicts with input_path and input_transformer)
    - input_path: JSONPath expression to select part of the event (conflicts with input and input_transformer)
    - input_transformer: Complex input transformation configuration (conflicts with input and input_path)

    Optional fields for reliability:
    - dead_letter_config: Configuration for dead letter queue when target invocation fails
      - arn: ARN of the SQS queue or SNS topic to use as DLQ
    - retry_policy: Retry configuration for failed invocations
      - maximum_retry_attempts: Number of retry attempts (0-185, default: 185)
      - maximum_event_age_in_seconds: Maximum age of event in seconds (60-86400, default: 86400)

    Optional fields for IAM:
    - role_arn: Custom IAM role ARN for invoking the target (auto-created if null and create_role is true)

    Target-specific configurations:
    - sqs_parameters: SQS-specific settings
      - message_group_id: Message group ID for FIFO queues
    - ecs_parameters: ECS-specific settings
      - task_definition_arn: Task definition ARN
      - task_count: Number of tasks to launch (default: 1)
      - launch_type: Launch type (EC2 or FARGATE)
      - network_configuration: Network configuration for awsvpc mode
      - platform_version: Fargate platform version (default: LATEST)
      - group: Task group name
      - capacity_provider_strategy: Capacity provider strategy
      - enable_ecs_managed_tags: Enable ECS managed tags (default: false)
      - enable_execute_command: Enable ECS Exec (default: false)
      - placement_constraints: Placement constraints
      - placement_strategy: Placement strategy
      - propagate_tags: Propagate tags from task definition (TASK_DEFINITION or none)
      - tags: Tags for the task
    - batch_parameters: Batch-specific settings
      - job_definition: Job definition ARN
      - job_name: Job name
      - array_properties: Array job properties
      - retry_strategy: Retry strategy
    - kinesis_parameters: Kinesis-specific settings
      - partition_key_path: JSONPath to partition key
    - run_command_parameters: SSM Run Command settings
      - run_command_targets: Run command targets
    - http_parameters: API Destinations settings (future enhancement)
      - path_parameter_values: Path parameter values
      - header_parameters: Header parameters
      - query_string_parameters: Query string parameters
  EOT
  type = list(object({
    target_id = string
    arn       = string
    role_arn  = optional(string)

    # Input transformation
    input      = optional(string)
    input_path = optional(string)
    input_transformer = optional(object({
      input_paths_map = map(string)
      input_template  = string
    }))

    # Reliability
    dead_letter_config = optional(object({
      arn = string
    }))
    retry_policy = optional(object({
      maximum_retry_attempts       = optional(number)
      maximum_event_age_in_seconds = optional(number)
    }))

    # Target-specific configurations
    sqs_parameters = optional(object({
      message_group_id = optional(string)
    }))
    ecs_parameters = optional(object({
      task_definition_arn = string
      task_count          = optional(number, 1)
      launch_type         = optional(string)
      network_configuration = optional(object({
        subnets          = list(string)
        security_groups  = optional(list(string))
        assign_public_ip = optional(bool)
      }))
      platform_version = optional(string)
      group            = optional(string)
      capacity_provider_strategy = optional(list(object({
        capacity_provider = string
        weight            = optional(number)
        base              = optional(number)
      })))
      enable_ecs_managed_tags = optional(bool)
      enable_execute_command  = optional(bool)
      placement_constraints = optional(list(object({
        type       = string
        expression = optional(string)
      })))
      placement_strategy = optional(list(object({
        type  = string
        field = optional(string)
      })))
      propagate_tags = optional(string)
      tags           = optional(map(string))
    }))
    batch_parameters = optional(object({
      job_definition = string
      job_name       = string
      array_properties = optional(object({
        size = number
      }))
      retry_strategy = optional(object({
        attempts = number
      }))
    }))
    kinesis_parameters = optional(object({
      partition_key_path = string
    }))
    run_command_parameters = optional(object({
      run_command_targets = list(object({
        key    = string
        values = list(string)
      }))
    }))
    http_parameters = optional(object({
      path_parameter_values   = optional(map(string))
      header_parameters       = optional(map(string))
      query_string_parameters = optional(map(string))
    }))
  }))
  default = null

  validation {
    condition     = var.targets == null ? true : (length(var.targets) >= 1 && length(var.targets) <= 5)
    error_message = "At least 1 target is required, and AWS EventBridge supports a maximum of 5 targets per rule."
  }

  validation {
    condition = var.targets == null ? true : alltrue([
      for target in var.targets :
      (target.input != null ? 1 : 0) +
      (target.input_path != null ? 1 : 0) +
      (target.input_transformer != null ? 1 : 0) <= 1
    ])
    error_message = "Each target can have only one of: input, input_path, or input_transformer."
  }

  validation {
    condition = var.targets == null ? true : alltrue([
      for target in var.targets :
      target.retry_policy == null ? true : (
        target.retry_policy.maximum_retry_attempts == null ? true : (
          target.retry_policy.maximum_retry_attempts >= 0 && target.retry_policy.maximum_retry_attempts <= 185
        )
      )
    ])
    error_message = "Retry policy maximum_retry_attempts must be between 0 and 185."
  }

  validation {
    condition = var.targets == null ? true : alltrue([
      for target in var.targets :
      target.retry_policy == null ? true : (
        target.retry_policy.maximum_event_age_in_seconds == null ? true : (
          target.retry_policy.maximum_event_age_in_seconds >= 60 && target.retry_policy.maximum_event_age_in_seconds <= 86400
        )
      )
    ])
    error_message = "Retry policy maximum_event_age_in_seconds must be between 60 and 86400 (1 minute to 24 hours)."
  }
}

# -----------------------------------------------------------------------------
# IAM Role Configuration
# -----------------------------------------------------------------------------

variable "create_role" {
  description = <<-EOT
    Whether to create an IAM role for EventBridge to invoke targets.
    - true: Automatically creates IAM role with least-privilege permissions based on target types
    - false: Use existing IAM role (must specify role_arn in targets)
  EOT
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of the IAM role to create. If not specified, a name will be generated based on the rule name."
  type        = string
  default     = null

  validation {
    condition     = var.role_name == null ? true : can(regex("^[a-zA-Z0-9_+=,.@-]+$", var.role_name))
    error_message = "Role name must only contain alphanumeric characters and +=,.@-_ characters."
  }

  validation {
    condition     = var.role_name == null ? true : (length(var.role_name) >= 1 && length(var.role_name) <= 64)
    error_message = "Role name must be between 1 and 64 characters long."
  }
}

variable "role_description" {
  description = "Description of the IAM role. Helps document the purpose of the role."
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path for the IAM role. Useful for organizing roles in your AWS account."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/.*/$", var.role_path)) || var.role_path == "/"
    error_message = "Role path must start and end with a forward slash (/)."
  }
}

variable "role_permissions_boundary" {
  description = "ARN of the policy to use as the permissions boundary for the IAM role."
  type        = string
  default     = null
}

variable "additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the role. Use for custom permissions beyond auto-generated target permissions."
  type        = list(string)
  default     = []
}

variable "caller_identity_override" {
  description = "Optional override for caller identity (account_id/arn/user_id) to avoid STS calls during tests."
  type = object({
    account_id = string
    arn        = string
    user_id    = string
  })
  default = null
}

# -----------------------------------------------------------------------------
# Cross-Account Configuration
# -----------------------------------------------------------------------------

variable "allow_account_ids" {
  description = <<-EOT
    List of AWS account IDs allowed to send events to this event bus.
    Only applicable when create_event_bus is true (custom event bus).
    Leave empty to disable cross-account access.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for account_id in var.allow_account_ids :
      can(regex("^[0-9]{12}$", account_id))
    ])
    error_message = "Account IDs must be 12-digit numbers."
  }
}

variable "event_bus_policy_statement" {
  description = <<-EOT
    Custom event bus policy statement in JSON format. Use for advanced cross-account scenarios.
    If specified, this will be used instead of auto-generated policy from allow_account_ids.
    Only applicable when create_event_bus is true (custom event bus).
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.event_bus_policy_statement == null || can(jsondecode(var.event_bus_policy_statement))
    error_message = "Event bus policy statement must be a valid JSON string."
  }
}

# -----------------------------------------------------------------------------
# Multiple Rules Configuration (Alternative to single rule)
# -----------------------------------------------------------------------------

variable "rules" {
  description = <<-EOT
    List of EventBridge rules to create. Use this for creating multiple rules on the same event bus.
    If specified, this takes precedence over the single rule variables (rule_name, event_pattern, etc.).

    Each rule object contains:
    - name: Name of the rule
    - description: Description of the rule (optional)
    - event_pattern: Event pattern JSON string (required if no schedule_expression)
    - schedule_expression: Schedule expression (required if no event_pattern)
    - enabled: Whether the rule is enabled (default: true)
    - targets: List of targets for this rule (same structure as targets variable)
  EOT
  type = list(object({
    name                = string
    description         = optional(string)
    event_pattern       = optional(string)
    schedule_expression = optional(string)
    enabled             = optional(bool, true)
    targets = list(object({
      target_id = string
      arn       = string
      role_arn  = optional(string)

      # Input transformation
      input      = optional(string)
      input_path = optional(string)
      input_transformer = optional(object({
        input_paths_map = map(string)
        input_template  = string
      }))

      # Reliability
      dead_letter_config = optional(object({
        arn = string
      }))
      retry_policy = optional(object({
        maximum_retry_attempts       = optional(number)
        maximum_event_age_in_seconds = optional(number)
      }))

      # Target-specific configurations
      sqs_parameters = optional(object({
        message_group_id = optional(string)
      }))
      ecs_parameters = optional(object({
        task_definition_arn = string
        task_count          = optional(number, 1)
        launch_type         = optional(string)
        network_configuration = optional(object({
          subnets          = list(string)
          security_groups  = optional(list(string))
          assign_public_ip = optional(bool)
        }))
        platform_version = optional(string)
        group            = optional(string)
        capacity_provider_strategy = optional(list(object({
          capacity_provider = string
          weight            = optional(number)
          base              = optional(number)
        })))
        enable_ecs_managed_tags = optional(bool)
        enable_execute_command  = optional(bool)
        placement_constraints = optional(list(object({
          type       = string
          expression = optional(string)
        })))
        placement_strategy = optional(list(object({
          type  = string
          field = optional(string)
        })))
        propagate_tags = optional(string)
        tags           = optional(map(string))
      }))
      batch_parameters = optional(object({
        job_definition = string
        job_name       = string
        array_properties = optional(object({
          size = number
        }))
        retry_strategy = optional(object({
          attempts = number
        }))
      }))
      kinesis_parameters = optional(object({
        partition_key_path = string
      }))
      run_command_parameters = optional(object({
        run_command_targets = list(object({
          key    = string
          values = list(string)
        }))
      }))
      http_parameters = optional(object({
        path_parameter_values   = optional(map(string))
        header_parameters       = optional(map(string))
        query_string_parameters = optional(map(string))
      }))
    }))
  }))
  default = null

  validation {
    condition = var.rules == null ? true : alltrue([
      for rule in var.rules :
      (rule.event_pattern != null ? 1 : 0) + (rule.schedule_expression != null ? 1 : 0) == 1
    ])
    error_message = "Each rule must have exactly one of: event_pattern or schedule_expression."
  }

  validation {
    condition = var.rules == null ? true : alltrue([
      for rule in var.rules :
      length(rule.targets) >= 1 && length(rule.targets) <= 5
    ])
    error_message = "Each rule must have between 1 and 5 targets."
  }
}

# -----------------------------------------------------------------------------
# Archive Configuration
# -----------------------------------------------------------------------------

variable "archive_config" {
  description = <<-EOT
    Configuration for EventBridge archive. Archives store events for replay.

    Fields:
    - name: Name of the archive
    - description: Description of the archive (optional)
    - retention_days: Number of days to retain events (0 = indefinite, max = 365)
    - event_pattern: Event pattern to filter which events to archive (optional)
  EOT
  type = object({
    name           = string
    description    = optional(string)
    retention_days = optional(number, 0)
    event_pattern  = optional(string)
  })
  default = null

  validation {
    condition     = var.archive_config == null ? true : (var.archive_config.retention_days >= 0 && var.archive_config.retention_days <= 365)
    error_message = "Archive retention_days must be between 0 (indefinite) and 365 days."
  }

  validation {
    condition     = var.archive_config == null ? true : (var.archive_config.event_pattern == null || can(jsondecode(var.archive_config.event_pattern)))
    error_message = "Archive event_pattern must be valid JSON."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
