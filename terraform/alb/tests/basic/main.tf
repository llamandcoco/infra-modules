terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# -----------------------------------------------------------------------------
# Test 1: Basic HTTP ALB
# Demonstrates minimal configuration with HTTP listener and single target group
# -----------------------------------------------------------------------------

module "basic_http_alb" {
  source = "../../"

  alb_name = "test-basic-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  # Create security group for the ALB
  create_security_group      = true
  security_group_name        = "test-basic-alb-sg"
  security_group_description = "Security group for basic HTTP ALB"

  # Allow HTTP traffic from anywhere
  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from anywhere"
    }
  ]

  # Allow all outbound traffic
  security_group_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  # Single target group
  target_groups = [
    {
      name                 = "web-tg"
      port                 = 80
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 300
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      stickiness = null
      targets    = []
    }
  ]

  # HTTP listener
  listeners = [
    {
      port                        = 80
      protocol                    = "HTTP"
      ssl_policy                  = null
      certificate_arn             = null
      additional_certificate_arns = []

      default_action = {
        type              = "forward"
        target_group_name = "web-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "basic-http-alb-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: Basic ALB with existing security group
# Demonstrates using an existing security group instead of creating one
# -----------------------------------------------------------------------------

module "basic_alb_existing_sg" {
  source = "../../"

  alb_name = "test-existing-sg-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  # Use existing security group (not creating one)
  create_security_group = false
  security_group_ids    = ["sg-12345678"]

  # Single target group with different health check settings
  target_groups = [
    {
      name                 = "app-tg"
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 30
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        interval            = 15
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      stickiness = null
      targets    = []
    }
  ]

  # HTTP listener
  listeners = [
    {
      port                        = 80
      protocol                    = "HTTP"
      ssl_policy                  = null
      certificate_arn             = null
      additional_certificate_arns = []

      default_action = {
        type              = "forward"
        target_group_name = "app-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "existing-sg-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Internal ALB
# Demonstrates internal (private) ALB configuration
# -----------------------------------------------------------------------------

module "internal_alb" {
  source = "../../"

  alb_name = "test-internal-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]
  internal = true

  create_security_group      = true
  security_group_name        = "test-internal-alb-sg"
  security_group_description = "Security group for internal ALB"

  # Allow HTTP traffic from VPC CIDR
  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow HTTP from VPC"
    }
  ]

  security_group_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  target_groups = [
    {
      name                 = "internal-tg"
      port                 = 80
      protocol             = "HTTP"
      target_type          = "ip"
      deregistration_delay = 300
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      stickiness = null
      targets    = []
    }
  ]

  listeners = [
    {
      port                        = 80
      protocol                    = "HTTP"
      ssl_policy                  = null
      certificate_arn             = null
      additional_certificate_arns = []

      default_action = {
        type              = "forward"
        target_group_name = "internal-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "internal-alb-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_http_alb_dns_name" {
  description = "DNS name for basic HTTP ALB"
  value       = module.basic_http_alb.alb_dns_name
}

output "basic_http_alb_arn" {
  description = "ARN of basic HTTP ALB"
  value       = module.basic_http_alb.alb_arn
}

output "basic_http_alb_target_groups" {
  description = "Target group ARNs"
  value       = module.basic_http_alb.target_group_arns
}

output "basic_http_alb_listener_arns" {
  description = "Listener ARNs"
  value       = module.basic_http_alb.listener_arns
}

output "internal_alb_dns_name" {
  description = "DNS name for internal ALB"
  value       = module.internal_alb.alb_dns_name
}

output "internal_alb_internal_flag" {
  description = "Internal flag for internal ALB"
  value       = module.internal_alb.internal
}
