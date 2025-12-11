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
# Test 1: HTTPS ALB with HTTP to HTTPS redirect
# Demonstrates HTTPS listener with TLS certificate and HTTP redirect
# -----------------------------------------------------------------------------

module "https_alb" {
  source = "../../"

  alb_name = "test-https-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-https-alb-sg"
  security_group_description = "Security group for HTTPS ALB"

  # Allow HTTP and HTTPS traffic
  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from anywhere"
    },
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
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      stickiness = null
      targets    = []
    }
  ]

  # Two listeners: HTTP (redirect) and HTTPS (forward)
  listeners = [
    {
      # HTTP listener redirects to HTTPS
      port                        = 80
      protocol                    = "HTTP"
      ssl_policy                  = null
      certificate_arn             = null
      additional_certificate_arns = []

      default_action = {
        type              = "redirect"
        target_group_name = null

        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          host        = "#{host}"
          path        = "/#{path}"
          query       = "#{query}"
          status_code = "HTTP_301"
        }

        fixed_response = null
      }
    },
    {
      # HTTPS listener forwards to target group
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
    Purpose     = "https-alb-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: HTTPS ALB with access logs and deletion protection
# Demonstrates production-ready configuration with logging
# -----------------------------------------------------------------------------

module "https_alb_production" {
  source = "../../"

  alb_name = "test-prod-https-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  # Enable deletion protection for production
  enable_deletion_protection = true

  # Enable access logs
  enable_access_logs  = true
  access_logs_bucket  = "my-alb-logs-bucket"
  access_logs_prefix  = "prod-alb"

  # Drop invalid headers for security
  drop_invalid_header_fields = true

  create_security_group      = true
  security_group_name        = "test-prod-https-alb-sg"
  security_group_description = "Security group for production HTTPS ALB"

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

  target_groups = [
    {
      name                 = "prod-web-tg"
      port                 = 80
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 300
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
      targets    = []
    }
  ]

  listeners = [
    {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
      additional_certificate_arns = []

      default_action = {
        type              = "forward"
        target_group_name = "prod-web-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "production-https-alb"
    CostCenter  = "engineering"
  }
}

# -----------------------------------------------------------------------------
# Test 3: HTTPS ALB with multiple certificates (SNI)
# Demonstrates SNI support with additional certificates
# -----------------------------------------------------------------------------

module "https_alb_sni" {
  source = "../../"

  alb_name = "test-sni-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-sni-alb-sg"
  security_group_description = "Security group for SNI ALB"

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

  # HTTPS listener with primary certificate and additional certificates for SNI
  listeners = [
    {
      port        = 443
      protocol    = "HTTPS"
      ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"

      # Additional certificates for SNI (different domains)
      additional_certificate_arns = [
        "arn:aws:acm:us-east-1:123456789012:certificate/22222222-2222-2222-2222-222222222222",
        "arn:aws:acm:us-east-1:123456789012:certificate/33333333-3333-3333-3333-333333333333"
      ]

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
    Purpose     = "sni-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: HTTPS ALB with different TLS policy
# Demonstrates using a more compatible TLS policy
# -----------------------------------------------------------------------------

module "https_alb_compatible_tls" {
  source = "../../"

  alb_name = "test-compatible-tls-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-compatible-tls-alb-sg"
  security_group_description = "Security group for compatible TLS ALB"

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

  target_groups = [
    {
      name                 = "legacy-tg"
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

  # HTTPS listener with TLS 1.2 policy for broader compatibility
  listeners = [
    {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
      additional_certificate_arns = []

      default_action = {
        type              = "forward"
        target_group_name = "legacy-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "compatible-tls-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "https_alb_dns_name" {
  description = "DNS name for HTTPS ALB"
  value       = module.https_alb.alb_dns_name
}

output "https_alb_listener_arns" {
  description = "Listener ARNs for HTTPS ALB"
  value       = module.https_alb.listener_arns
}

output "https_alb_http_listener_arn" {
  description = "HTTP listener ARN (redirect)"
  value       = module.https_alb.http_listener_arn
}

output "https_alb_https_listener_arn" {
  description = "HTTPS listener ARN"
  value       = module.https_alb.https_listener_arn
}

output "production_alb_deletion_protection" {
  description = "Deletion protection status"
  value       = module.https_alb_production.enable_deletion_protection
}

output "sni_alb_dns_name" {
  description = "DNS name for SNI ALB"
  value       = module.https_alb_sni.alb_dns_name
}
