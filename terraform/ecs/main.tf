# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ECS Fargate Module
# Creates an ECS cluster, task definition, service, and auto-scaling configuration
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# ECS Cluster
# -----------------------------------------------------------------------------

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.cluster_name}/${var.container_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "/ecs/${var.cluster_name}/${var.container_name}"
    }
  )
}

# -----------------------------------------------------------------------------
# ECS Task Definition
# -----------------------------------------------------------------------------

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.cluster_name}-${var.container_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.container_image
    essential = true

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    environment = var.environment_variables

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name
        "awslogs-region"        = data.aws_region.current.id
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = var.container_health_check != null ? {
      command     = var.container_health_check.command
      interval    = var.container_health_check.interval
      timeout     = var.container_health_check.timeout
      retries     = var.container_health_check.retries
      startPeriod = var.container_health_check.start_period
    } : null
  }])

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${var.container_name}"
    }
  )
}

# -----------------------------------------------------------------------------
# ECS Service
# -----------------------------------------------------------------------------

resource "aws_ecs_service" "this" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = var.health_check_grace_period

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  enable_execute_command = var.enable_ecs_exec

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-service"
    }
  )

  depends_on = [aws_ecs_task_definition.this]
}

# -----------------------------------------------------------------------------
# Application Auto Scaling
# -----------------------------------------------------------------------------

resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.this]
}

# CPU-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_cpu_scaling ? 1 : 0

  name               = "${var.cluster_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.target_cpu_utilization
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.this]
}

# Memory-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_memory_scaling ? 1 : 0

  name               = "${var.cluster_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.target_memory_utilization
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.this]
}

# ALB Request Count-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "alb_request_count" {
  count = var.enable_alb_scaling ? 1 : 0

  name               = "${var.cluster_name}-alb-request-count-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.alb_resource_label
    }

    target_value       = var.target_request_count_per_target
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.this]
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_region" "current" {}
