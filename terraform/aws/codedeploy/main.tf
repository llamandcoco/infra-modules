terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------

locals {
  role_name = var.create_service_role ? "${var.application_name}-codedeploy-role" : null

  default_deployment_config_name = (
    var.compute_platform == "Lambda" ? "CodeDeployDefault.LambdaAllAtOnce" :
    var.compute_platform == "ECS" ? "CodeDeployDefault.ECSAllAtOnce" :
    "CodeDeployDefault.OneAtATime"
  )

  # CodeDeploy requires different managed policies by compute platform.
  service_role_policy_arn = (
    var.compute_platform == "Lambda" ? "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda" :
    var.compute_platform == "ECS" ? "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS" :
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  )
}

# -----------------------------------------------------------------------------
# CodeDeploy Application
# -----------------------------------------------------------------------------

resource "aws_codedeploy_app" "this" {
  name             = var.application_name
  compute_platform = var.compute_platform
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# IAM Service Role
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "assume" {
  count = var.create_service_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_service_role ? 1 : 0

  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume[0].json
  tags               = var.tags
}

# Attach AWS managed policy for CodeDeploy
resource "aws_iam_role_policy_attachment" "codedeploy" {
  count = var.create_service_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = local.service_role_policy_arn
}

# -----------------------------------------------------------------------------
# Deployment Group
# -----------------------------------------------------------------------------

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = var.create_service_role ? aws_iam_role.this[0].arn : var.service_role_arn
  deployment_config_name = coalesce(var.deployment_config_name, local.default_deployment_config_name)

  # EC2/On-Premises configuration
  dynamic "ec2_tag_set" {
    for_each = length(var.ec2_tag_filters) > 0 ? [1] : []
    content {
      dynamic "ec2_tag_filter" {
        for_each = var.ec2_tag_filters
        content {
          key   = ec2_tag_filter.value.key
          type  = ec2_tag_filter.value.type
          value = ec2_tag_filter.value.value
        }
      }
    }
  }

  # Auto Scaling Group configuration
  autoscaling_groups = var.autoscaling_groups

  # ECS configuration
  dynamic "ecs_service" {
    for_each = var.ecs_service != null ? [var.ecs_service] : []
    content {
      cluster_name = ecs_service.value.cluster_name
      service_name = ecs_service.value.service_name
    }
  }

  # Deployment Style (for all platforms when deployment_type is specified)
  dynamic "deployment_style" {
    for_each = var.deployment_type != null ? [1] : []
    content {
      deployment_option = var.deployment_type == "BLUE_GREEN" ? "WITH_TRAFFIC_CONTROL" : "WITHOUT_TRAFFIC_CONTROL"
      deployment_type   = var.deployment_type
    }
  }

  # Blue/Green deployment configuration
  dynamic "blue_green_deployment_config" {
    for_each = var.blue_green_deployment_config != null ? [var.blue_green_deployment_config] : []
    content {
      terminate_blue_instances_on_deployment_success {
        action                           = blue_green_deployment_config.value.terminate_blue_instances_action
        termination_wait_time_in_minutes = blue_green_deployment_config.value.termination_wait_time_in_minutes
      }

      deployment_ready_option {
        action_on_timeout    = blue_green_deployment_config.value.deployment_ready_action
        wait_time_in_minutes = blue_green_deployment_config.value.deployment_ready_wait_time_in_minutes
      }

      green_fleet_provisioning_option {
        action = blue_green_deployment_config.value.green_fleet_provisioning_action
      }
    }
  }

  # Load balancer configuration
  dynamic "load_balancer_info" {
    for_each = var.load_balancer_info != null ? [var.load_balancer_info] : []
    content {
      dynamic "target_group_info" {
        for_each = load_balancer_info.value.target_group_names
        content {
          name = target_group_info.value
        }
      }

      dynamic "elb_info" {
        for_each = load_balancer_info.value.elb_names
        content {
          name = elb_info.value
        }
      }
    }
  }

  # Auto rollback configuration
  dynamic "auto_rollback_configuration" {
    for_each = var.auto_rollback_enabled ? [1] : []
    content {
      enabled = true
      events  = var.auto_rollback_events
    }
  }

  # Alarm configuration
  dynamic "alarm_configuration" {
    for_each = length(var.alarm_names) > 0 ? [1] : []
    content {
      alarms                    = var.alarm_names
      enabled                   = true
      ignore_poll_alarm_failure = var.ignore_poll_alarm_failure
    }
  }

  # Trigger configuration
  dynamic "trigger_configuration" {
    for_each = var.trigger_configurations
    content {
      trigger_name       = trigger_configuration.value.trigger_name
      trigger_events     = trigger_configuration.value.trigger_events
      trigger_target_arn = trigger_configuration.value.trigger_target_arn
    }
  }

  lifecycle {
    precondition {
      condition     = var.create_service_role || var.service_role_arn != null
      error_message = "service_role_arn must be provided when create_service_role is false."
    }

    precondition {
      condition = (
        (var.compute_platform == "ECS" && var.ecs_service != null) ||
        (var.compute_platform != "ECS" && var.ecs_service == null)
      )
      error_message = "ecs_service must be set only when compute_platform is ECS."
    }

    precondition {
      condition     = var.compute_platform == "Server" || length(var.ec2_tag_filters) == 0
      error_message = "ec2_tag_filters is only supported when compute_platform is Server."
    }

    precondition {
      condition     = var.compute_platform == "Server" || length(var.autoscaling_groups) == 0
      error_message = "autoscaling_groups is only supported when compute_platform is Server."
    }

    precondition {
      condition     = var.compute_platform == "Server" || var.deployment_type == "BLUE_GREEN"
      error_message = "deployment_type IN_PLACE is only supported when compute_platform is Server."
    }

    precondition {
      condition     = var.compute_platform != "Lambda" || var.blue_green_deployment_config == null
      error_message = "blue_green_deployment_config is not supported when compute_platform is Lambda."
    }

    precondition {
      condition     = var.compute_platform != "Lambda" || var.load_balancer_info == null
      error_message = "load_balancer_info is not supported when compute_platform is Lambda."
    }

    precondition {
      condition = (
        try(length(var.load_balancer_info.target_group_names), 0) +
        try(length(var.load_balancer_info.elb_names), 0)
      ) > 0 || var.load_balancer_info == null
      error_message = "load_balancer_info must include at least one target group or ELB name."
    }

    precondition {
      condition = (
        try(length(var.load_balancer_info.target_group_names), 0) <= 1 &&
        try(length(var.load_balancer_info.elb_names), 0) <= 1
      )
      error_message = "CodeDeploy deployment groups support at most one target group and one ELB in load_balancer_info."
    }

    precondition {
      condition = (
        var.compute_platform != "ECS" ||
        try(length(var.load_balancer_info.target_group_names), 0) > 0
      )
      error_message = "ECS deployments require load_balancer_info with at least one target group."
    }
  }

  tags = var.tags
}
