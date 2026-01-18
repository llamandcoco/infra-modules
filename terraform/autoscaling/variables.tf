variable "name" {
  description = "Name prefix for ASG and Launch Template"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs for ASG (multiple AZs recommended)"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Optional list of ALB/NLB target group ARNs to attach"
  type        = list(string)
  default     = []
}

variable "min_size" {
  description = "ASG min size"
  type        = number
}

variable "max_size" {
  description = "ASG max size"
  type        = number
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for instances (if provided, overrides SSM lookup)"
  type        = string
  default     = null
}

variable "use_ssm_ami_lookup" {
  description = "When true, use SSM parameter to lookup AL2023 AMI"
  type        = bool
  default     = true
}

variable "ami_ssm_parameter_name" {
  description = "SSM parameter name for AL2023 AMI"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "security_group_ids" {
  description = "List of security group IDs for instances"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances (ECR/SSM permissions)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Plain user data script (will be base64-encoded)"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64 user data script"
  type        = string
  default     = null
}

variable "health_check_type" {
  description = "ASG health check type (EC2 or ELB)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Seconds to ignore health checks after instance launch"
  type        = number
  default     = 120
}

variable "capacity_rebalance" {
  description = "Enable capacity rebalance"
  type        = bool
  default     = false
}

variable "termination_policies" {
  description = "List of termination policies"
  type        = list(string)
  default     = ["Default"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_target_tracking_cpu" {
  description = "Enable target tracking on ASG average CPU utilization"
  type        = bool
  default     = false
}

variable "cpu_target_value" {
  description = "Target value for ASGAverageCPUUtilization (percentage)"
  type        = number
  default     = 50
}

variable "enable_target_tracking_alb" {
  description = "Enable target tracking on ALBRequestCountPerTarget (RPS-based scaling)"
  type        = bool
  default     = false
}

variable "alb_target_value" {
  description = "Target requests per target for ALBRequestCountPerTarget (RPS metric, e.g., 100 RPS per instance)"
  type        = number
  default     = 100
}

variable "alb_target_group_resource_label" {
  description = "Target group resource label (suffix) for ALBRequestCountPerTarget metric, format: targetgroup/<name>/<id>"
  type        = string
  default     = null
}

variable "enable_memory_alarm" {
  description = "Enable memory-based CloudWatch alarm for manual step scaling"
  type        = bool
  default     = false
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold (%) to trigger alarm and scale out"
  type        = number
  default     = 80
}

variable "memory_alarm_namespace" {
  description = "CloudWatch namespace for memory metric (e.g., CWAgent when using CloudWatch Agent)"
  type        = string
  default     = "CWAgent"
}

variable "memory_alarm_metric_name" {
  description = "CloudWatch metric name for memory utilization"
  type        = string
  default     = "mem_used_percent"
}

variable "step_policy_name" {
  description = "Optional Step Scaling policy name (if set, resource is created)"
  type        = string
  default     = null
}

variable "step_adjustment_type" {
  description = "Adjustment type for step scaling (ChangeInCapacity|PercentChangeInCapacity|ExactCapacity)"
  type        = string
  default     = "PercentChangeInCapacity"
}

variable "step_adjustments" {
  description = "List of step adjustments"
  type = list(object({
    metric_interval_lower_bound = optional(string)
    metric_interval_upper_bound = optional(string)
    scaling_adjustment          = number
  }))
  default = []
}

# Warm Pool Configuration
variable "enable_warm_pool" {
  description = "Enable warm pool for faster scale-out"
  type        = bool
  default     = false
}

variable "warm_pool_state" {
  description = "Warm pool instance state (Stopped, Running, Hibernated)"
  type        = string
  default     = "Stopped"
  validation {
    condition     = contains(["Stopped", "Running", "Hibernated"], var.warm_pool_state)
    error_message = "warm_pool_state must be one of: Stopped, Running, Hibernated"
  }
}

variable "warm_pool_min_size" {
  description = "Minimum number of instances in warm pool"
  type        = number
  default     = null
}

variable "warm_pool_max_group_prepared_capacity" {
  description = "Maximum instances (in-service + warm pool). If null, defaults to max_size"
  type        = number
  default     = null
}

variable "warm_pool_reuse_on_scale_in" {
  description = "Whether to return instances to warm pool on scale-in"
  type        = bool
  default     = true
}

# Predictive Scaling Configuration
variable "enable_predictive_scaling" {
  description = "Enable predictive scaling (requires 14 days of historical data)"
  type        = bool
  default     = false
}

variable "predictive_metric_type" {
  description = "Metric type for predictive scaling (cpu or alb)"
  type        = string
  default     = "cpu"
  validation {
    condition     = contains(["cpu", "alb"], var.predictive_metric_type)
    error_message = "predictive_metric_type must be either 'cpu' or 'alb'"
  }
}

variable "predictive_target_value" {
  description = "Target value for predictive scaling (e.g., 60 for 60% CPU)"
  type        = number
  default     = 60
}

variable "predictive_scaling_mode" {
  description = "Predictive scaling mode: ForecastAndScale or ForecastOnly"
  type        = string
  default     = "ForecastAndScale"
  validation {
    condition     = contains(["ForecastAndScale", "ForecastOnly"], var.predictive_scaling_mode)
    error_message = "predictive_scaling_mode must be either 'ForecastAndScale' or 'ForecastOnly'"
  }
}

variable "predictive_scheduling_buffer_time" {
  description = "Buffer time in seconds to pre-launch instances (default: 300 = 5 minutes)"
  type        = number
  default     = 300
}

variable "predictive_max_capacity_breach_behavior" {
  description = "Behavior when forecast exceeds max capacity: HonorMaxCapacity or IncreaseMaxCapacity"
  type        = string
  default     = "HonorMaxCapacity"
  validation {
    condition     = contains(["HonorMaxCapacity", "IncreaseMaxCapacity"], var.predictive_max_capacity_breach_behavior)
    error_message = "predictive_max_capacity_breach_behavior must be either 'HonorMaxCapacity' or 'IncreaseMaxCapacity'"
  }
}

# Step Scaling Configuration - CPU
variable "enable_step_scaling_cpu" {
  description = "Enable step scaling for CPU (aggressive scaling for sudden spikes)"
  type        = bool
  default     = false
}

variable "cpu_step_threshold" {
  description = "CPU threshold (%) to trigger step scaling (e.g., 75 for aggressive scaling above 75%)"
  type        = number
  default     = 75
}

variable "cpu_step_adjustments" {
  description = "Step adjustments for CPU-based scaling. metric_interval is relative to threshold."
  type = list(object({
    metric_interval_lower_bound = optional(number)
    metric_interval_upper_bound = optional(number)
    scaling_adjustment          = number
  }))
  default = [
    {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 10 # threshold to threshold+10 (e.g., 75-85%)
      scaling_adjustment          = 1
    },
    {
      metric_interval_lower_bound = 10 # threshold+10 and above (e.g., 85%+)
      scaling_adjustment          = 3
    }
  ]
}

variable "cpu_step_evaluation_periods" {
  description = "Number of periods to evaluate before triggering step scaling (1 = immediate)"
  type        = number
  default     = 1
}

# Step Scaling Configuration - RPS (ALB)
variable "enable_step_scaling_rps" {
  description = "Enable step scaling for RPS (ALBRequestCountPerTarget)"
  type        = bool
  default     = false
}

variable "rps_step_threshold" {
  description = "RPS threshold per target to trigger step scaling (e.g., 150 RPS per instance)"
  type        = number
  default     = 150
}

variable "rps_step_adjustments" {
  description = "Step adjustments for RPS-based scaling. metric_interval is relative to threshold."
  type = list(object({
    metric_interval_lower_bound = optional(number)
    metric_interval_upper_bound = optional(number)
    scaling_adjustment          = number
  }))
  default = [
    {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 50 # threshold to threshold+50 (e.g., 150-200 RPS)
      scaling_adjustment          = 2
    },
    {
      metric_interval_lower_bound = 50 # threshold+50 and above (e.g., 200+ RPS)
      scaling_adjustment          = 4
    }
  ]
}

variable "rps_step_evaluation_periods" {
  description = "Number of periods to evaluate before triggering RPS step scaling"
  type        = number
  default     = 1
}

# Instance Warmup Configuration
variable "default_instance_warmup" {
  description = "Default warmup time in seconds for all scaling activities (applies to ASG)"
  type        = number
  default     = null # null = use ASG default (health_check_grace_period or 300s)
}

variable "cpu_step_instance_warmup" {
  description = "Warmup time in seconds for CPU step scaling (null = use default_instance_warmup)"
  type        = number
  default     = null
}

variable "rps_step_instance_warmup" {
  description = "Warmup time in seconds for RPS step scaling (null = use default_instance_warmup)"
  type        = number
  default     = null
}
