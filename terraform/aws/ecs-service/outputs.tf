# -----------------------------------------------------------------------------
# ECS Service Outputs
# -----------------------------------------------------------------------------

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.this.id
}

output "service_desired_count" {
  description = "Desired count of tasks in the ECS service"
  value       = aws_ecs_service.this.desired_count
}

# -----------------------------------------------------------------------------
# Task Definition Outputs
# -----------------------------------------------------------------------------

output "task_definition_arn" {
  description = "ARN of the task definition (with revision number)"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "Family name of the task definition"
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  description = "Revision number of the task definition"
  value       = aws_ecs_task_definition.this.revision
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Outputs
# -----------------------------------------------------------------------------

output "log_group_name" {
  description = "Name of the CloudWatch log group for ECS tasks"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.arn
}

# -----------------------------------------------------------------------------
# Auto Scaling Outputs
# -----------------------------------------------------------------------------

output "autoscaling_target_resource_id" {
  description = "Resource ID of the auto-scaling target"
  value       = aws_appautoscaling_target.this.resource_id
}

output "autoscaling_min_capacity" {
  description = "Minimum capacity for auto-scaling"
  value       = aws_appautoscaling_target.this.min_capacity
}

output "autoscaling_max_capacity" {
  description = "Maximum capacity for auto-scaling"
  value       = aws_appautoscaling_target.this.max_capacity
}

output "cpu_scaling_policy_arn" {
  description = "ARN of the CPU-based auto-scaling policy (if enabled)"
  value       = var.enable_cpu_scaling ? aws_appautoscaling_policy.cpu[0].arn : null
}

output "memory_scaling_policy_arn" {
  description = "ARN of the memory-based auto-scaling policy (if enabled)"
  value       = var.enable_memory_scaling ? aws_appautoscaling_policy.memory[0].arn : null
}

output "alb_scaling_policy_arn" {
  description = "ARN of the ALB request count-based auto-scaling policy (if enabled)"
  value       = var.enable_alb_scaling ? aws_appautoscaling_policy.alb_request_count[0].arn : null
}

# -----------------------------------------------------------------------------
# Container Configuration Outputs
# -----------------------------------------------------------------------------

output "container_name" {
  description = "Name of the container"
  value       = local.container_name
}

output "container_image" {
  description = "Docker image used for the container"
  value       = var.container_image
}

output "container_port" {
  description = "Port number the container listens on"
  value       = var.container_port
}
