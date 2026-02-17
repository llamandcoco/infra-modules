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
# Test 1: ALB with multiple target groups
# Demonstrates multiple target groups with different configurations
# -----------------------------------------------------------------------------

module "multi_target_alb" {
  source = "../../"

  alb_name = "test-multi-target-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-multi-target-alb-sg"
  security_group_description = "Security group for multi-target ALB"

  security_group_ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from anywhere"
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

  # Three target groups: web, api, and admin
  target_groups = [
    {
      # Web application target group with stickiness
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
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      # Enable session stickiness for stateful web application
      stickiness = {
        enabled         = true
        type            = "lb_cookie"
        cookie_duration = 86400 # 24 hours
        cookie_name     = null
      }

      targets = []
    },
    {
      # API target group with faster health checks
      name                 = "api-tg"
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 60 # Shorter for API
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        interval            = 15 # More frequent for API
        path                = "/api/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      # No stickiness for stateless API
      stickiness = null

      targets = []
    },
    {
      # Admin target group with strict health checks
      name                 = "admin-tg"
      port                 = 8443
      protocol             = "HTTPS"
      target_type          = "instance"
      deregistration_delay = 300
      slow_start           = 30 # Gradual traffic increase

      health_check = {
        enabled             = true
        healthy_threshold   = 5 # Stricter
        unhealthy_threshold = 2
        timeout             = 10
        interval            = 30
        path                = "/admin/health"
        port                = "traffic-port"
        protocol            = "HTTPS"
        matcher             = "200"
      }

      stickiness = null

      targets = []
    }
  ]

  # HTTPS listener - defaults to web target group
  listeners = [
    {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
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
    Purpose     = "multi-target-group-testing"
  }

  target_group_tags = {
    Monitoring = "enabled"
    Team       = "platform"
  }
}

# -----------------------------------------------------------------------------
# Test 2: ALB with IP-based target groups (for containers)
# Demonstrates IP target type for ECS/Fargate containers
# -----------------------------------------------------------------------------

module "container_alb" {
  source = "../../"

  alb_name = "test-container-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-container-alb-sg"
  security_group_description = "Security group for container ALB"

  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from anywhere"
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

  # IP-based target groups for containers
  target_groups = [
    {
      # Frontend service
      name                 = "frontend-tg"
      port                 = 3000
      protocol             = "HTTP"
      target_type          = "ip" # For ECS/Fargate tasks
      deregistration_delay = 30
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 15
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      stickiness = null

      targets = []
    },
    {
      # Backend service
      name                 = "backend-tg"
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "ip"
      deregistration_delay = 30
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 15
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      stickiness = null

      targets = []
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
        target_group_name = "frontend-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "container-target-group-testing"
    Workload    = "containerized"
  }
}

# -----------------------------------------------------------------------------
# Test 3: ALB with target group attachments
# Demonstrates registering specific targets with target groups
# -----------------------------------------------------------------------------

module "attached_targets_alb" {
  source = "../../"

  alb_name = "test-attached-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-attached-alb-sg"
  security_group_description = "Security group for ALB with attached targets"

  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from anywhere"
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

  # Target group with specific EC2 instances attached
  target_groups = [
    {
      name                 = "web-servers-tg"
      port                 = 80
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 300
      slow_start           = 60

      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200-299"
      }

      stickiness = null

      # Attach specific EC2 instances
      targets = [
        {
          target_id         = "i-1234567890abcdef0"
          port              = null # Use target group port
          availability_zone = null
        },
        {
          target_id         = "i-0987654321fedcba0"
          port              = null
          availability_zone = null
        },
        {
          # Custom port for this target
          target_id         = "i-abcdef1234567890"
          port              = 8080
          availability_zone = null
        }
      ]
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
        target_group_name = "web-servers-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "target-attachment-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "multi_target_alb_dns_name" {
  description = "DNS name for multi-target ALB"
  value       = module.multi_target_alb.alb_dns_name
}

output "multi_target_alb_target_groups" {
  description = "All target group ARNs"
  value       = module.multi_target_alb.target_group_arns
}

output "multi_target_alb_target_group_names" {
  description = "All target group names"
  value       = module.multi_target_alb.target_group_names
}

output "container_alb_dns_name" {
  description = "DNS name for container ALB"
  value       = module.container_alb.alb_dns_name
}

output "attached_targets_alb_dns_name" {
  description = "DNS name for ALB with attached targets"
  value       = module.attached_targets_alb.alb_dns_name
}
