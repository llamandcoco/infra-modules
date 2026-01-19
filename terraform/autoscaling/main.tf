terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  lt_name  = "${var.name}-lt"
  asg_name = "${var.name}-asg"
}

# -----------------------------------------------------------------------------
# Image Selection
# -----------------------------------------------------------------------------
# CI-safe conditional SSM lookup for AL2023 AMI
data "aws_ssm_parameter" "al2023" {
  count = var.ami_id == null && var.use_ssm_ami_lookup ? 1 : 0
  name  = var.ami_ssm_parameter_name
}

# -----------------------------------------------------------------------------
# Derived Locals
# -----------------------------------------------------------------------------
locals {
  image_id = var.ami_id != null ? var.ami_id : (
    var.use_ssm_ami_lookup && length(data.aws_ssm_parameter.al2023) > 0 ? data.aws_ssm_parameter.al2023[0].value : null
  )
}

# -----------------------------------------------------------------------------
# Launch Template
# -----------------------------------------------------------------------------
resource "aws_launch_template" "this" {
  name        = local.lt_name
  description = "Launch template for ${var.name}"

  image_id      = local.image_id
  instance_type = var.instance_type

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null ? [1] : []
    content {
      name = var.iam_instance_profile_name
    }
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = var.user_data_base64 != null ? var.user_data_base64 : (
    var.user_data != null ? base64encode(var.user_data) : null
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = local.asg_name
    })
  }
}

# -----------------------------------------------------------------------------
# Auto Scaling Group
# -----------------------------------------------------------------------------
resource "aws_autoscaling_group" "this" {
  name                = local.asg_name
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.vpc_subnet_ids

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  capacity_rebalance   = var.capacity_rebalance
  termination_policies = var.termination_policies

  # Default warmup time for all scaling activities
  # Reduces time before new instances contribute to metrics (default: 300s)
  default_instance_warmup = var.default_instance_warmup

  dynamic "launch_template" {
    for_each = [1]
    content {
      id      = aws_launch_template.this.id
      version = "$Latest"
    }
  }

  target_group_arns = var.target_group_arns

  # -----------------------------------------------------------------------------
  # Warm Pool (Optional)
  # -----------------------------------------------------------------------------
  dynamic "warm_pool" {
    for_each = var.enable_warm_pool ? [1] : []
    content {
      pool_state                  = var.warm_pool_state
      min_size                    = var.warm_pool_min_size
      max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity

      instance_reuse_policy {
        reuse_on_scale_in = var.warm_pool_reuse_on_scale_in
      }
    }
  }

  tag {
    key                 = "Name"
    value               = local.asg_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Target Tracking Policies
# -----------------------------------------------------------------------------
# Target Tracking: CPU
resource "aws_autoscaling_policy" "tt_cpu" {
  count                  = var.enable_target_tracking_cpu ? 1 : 0
  name                   = "${local.asg_name}-tt-cpu"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}

# Target Tracking: ALB Request Count per Target (RPS-based scaling)
resource "aws_autoscaling_policy" "tt_alb" {
  count                  = var.enable_target_tracking_alb && var.alb_target_group_resource_label != null ? 1 : 0
  name                   = "${local.asg_name}-tt-rps"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.alb_target_group_resource_label
    }
    target_value = var.alb_target_value
  }
}

# -----------------------------------------------------------------------------
# Memory Alarm (Optional)
# -----------------------------------------------------------------------------
# Optional memory-based alarm (requires CloudWatch Agent to publish mem_used_percent)
resource "aws_cloudwatch_metric_alarm" "memory" {
  count       = var.enable_memory_alarm ? 1 : 0
  alarm_name  = "${local.asg_name}-memory-high"
  namespace   = var.memory_alarm_namespace
  metric_name = var.memory_alarm_metric_name

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.memory_alarm_threshold
  period              = 60
  evaluation_periods  = 2
  statistic           = "Average"
  treat_missing_data  = "ignore"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = var.enable_memory_alarm && var.step_policy_name != null ? [try(aws_autoscaling_policy.step[0].arn, "")] : []
}


# -----------------------------------------------------------------------------
# Step Scaling Policy
# -----------------------------------------------------------------------------
# Optional Step Scaling policy (to be wired with CloudWatch Alarm actions)
resource "aws_autoscaling_policy" "step" {
  count                  = var.step_policy_name != null && length(var.step_adjustments) > 0 ? 1 : 0
  name                   = var.step_policy_name
  policy_type            = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = var.step_adjustment_type

  dynamic "step_adjustment" {
    for_each = var.step_adjustments
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = try(step_adjustment.value.metric_interval_lower_bound, null)
      metric_interval_upper_bound = try(step_adjustment.value.metric_interval_upper_bound, null)
    }
  }
}

# -----------------------------------------------------------------------------
# Predictive Scaling Policy
# -----------------------------------------------------------------------------
# Predictive Scaling Policy (requires 14 days of historical data)
resource "aws_autoscaling_policy" "predictive" {
  count                  = var.enable_predictive_scaling ? 1 : 0
  name                   = "${local.asg_name}-predictive"
  policy_type            = "PredictiveScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  predictive_scaling_configuration {
    metric_specification {
      target_value = var.predictive_target_value

      # Use predefined CPU metric
      dynamic "predefined_metric_pair_specification" {
        for_each = var.predictive_metric_type == "cpu" ? [1] : []
        content {
          predefined_metric_type = "ASGCPUUtilization"
        }
      }

      # Or use custom metric (ALB RPS)
      dynamic "predefined_load_metric_specification" {
        for_each = var.predictive_metric_type == "alb" && var.alb_target_group_resource_label != null ? [1] : []
        content {
          predefined_metric_type = "ALBTargetGroupRequestCount"
          resource_label         = var.alb_target_group_resource_label
        }
      }
    }

    mode                         = var.predictive_scaling_mode
    scheduling_buffer_time       = var.predictive_scheduling_buffer_time
    max_capacity_breach_behavior = var.predictive_max_capacity_breach_behavior
  }
}

# -----------------------------------------------------------------------------
# Step Scaling - CPU
# -----------------------------------------------------------------------------

# Step Scaling Policy - CPU
resource "aws_autoscaling_policy" "step_cpu" {
  count                  = var.enable_step_scaling_cpu ? 1 : 0
  name                   = "${local.asg_name}-step-cpu"
  policy_type            = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"

  # Warmup time before new instances contribute to metrics
  # Lower values = faster consecutive scaling (default: 300s)
  estimated_instance_warmup = var.cpu_step_instance_warmup

  dynamic "step_adjustment" {
    for_each = var.cpu_step_adjustments
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }
}

# -----------------------------------------------------------------------------
# CPU High Step Alarm
# -----------------------------------------------------------------------------
# CloudWatch Alarm - CPU High (triggers step scaling)
resource "aws_cloudwatch_metric_alarm" "cpu_high_step" {
  count               = var.enable_step_scaling_cpu ? 1 : 0
  alarm_name          = "${local.asg_name}-cpu-high-step"
  alarm_description   = "Trigger step scaling when CPU exceeds ${var.cpu_step_threshold}%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_step_threshold
  period              = 60
  evaluation_periods  = var.cpu_step_evaluation_periods
  statistic           = "Average"
  treat_missing_data  = "ignore"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = [aws_autoscaling_policy.step_cpu[0].arn]
}

# -----------------------------------------------------------------------------
# Step Scaling - RPS
# -----------------------------------------------------------------------------

# Step Scaling Policy - RPS
resource "aws_autoscaling_policy" "step_rps" {
  count                  = var.enable_step_scaling_rps && var.alb_target_group_resource_label != null ? 1 : 0
  name                   = "${local.asg_name}-step-rps"
  policy_type            = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"

  # Warmup time before new instances contribute to metrics
  # Lower values = faster consecutive scaling (default: 300s)
  estimated_instance_warmup = var.rps_step_instance_warmup

  dynamic "step_adjustment" {
    for_each = var.rps_step_adjustments
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }
}

# -----------------------------------------------------------------------------
# RPS High Step Alarm
# -----------------------------------------------------------------------------
# CloudWatch Alarm - RPS High (triggers step scaling)
resource "aws_cloudwatch_metric_alarm" "rps_high_step" {
  count               = var.enable_step_scaling_rps && var.alb_target_group_resource_label != null ? 1 : 0
  alarm_name          = "${local.asg_name}-rps-high-step"
  alarm_description   = "Trigger step scaling when RPS exceeds ${var.rps_step_threshold} per target"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "RequestCountPerTarget"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.rps_step_threshold
  period              = 60
  evaluation_periods  = var.rps_step_evaluation_periods
  statistic           = "Sum"
  treat_missing_data  = "ignore"

  dimensions = {
    TargetGroup = var.alb_target_group_resource_label
  }

  alarm_actions = [aws_autoscaling_policy.step_rps[0].arn]
}
