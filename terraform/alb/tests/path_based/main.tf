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
# Test 1: Path-based routing
# Demonstrates routing traffic based on URL path patterns
# Priority: Lower number = higher priority
# -----------------------------------------------------------------------------

module "path_based_alb" {
  source = "../../"

  alb_name = "test-path-based-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-path-based-alb-sg"
  security_group_description = "Security group for path-based routing ALB"

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

  # Three target groups for different application components
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
    },
    {
      name                 = "api-tg"
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 60
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        interval            = 15
        path                = "/api/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      stickiness = null
      targets    = []
    },
    {
      name                 = "admin-tg"
      port                 = 8443
      protocol             = "HTTPS"
      target_type          = "instance"
      deregistration_delay = 300
      slow_start           = 0

      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/admin/health"
        port                = "traffic-port"
        protocol            = "HTTPS"
        matcher             = "200"
      }

      stickiness = null
      targets    = []
    }
  ]

  # HTTPS listener with default action to web target group
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

  # Path-based routing rules
  # Lower priority number = evaluated first
  listener_rules = [
    {
      # Route /api/* to API target group
      listener_port = 443
      priority      = 100

      conditions = [
        {
          path_pattern = {
            values = ["/api/*"]
          }
          host_header         = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
        type              = "forward"
        target_group_name = "api-tg"
        redirect          = null
        fixed_response    = null
      }
    },
    {
      # Route /admin/* to Admin target group
      listener_port = 443
      priority      = 200

      conditions = [
        {
          path_pattern = {
            values = ["/admin/*"]
          }
          host_header         = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
        type              = "forward"
        target_group_name = "admin-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "path-based-routing-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: Complex path-based routing with multiple patterns
# Demonstrates advanced path matching and priority ordering
# -----------------------------------------------------------------------------

module "complex_path_routing_alb" {
  source = "../../"

  alb_name = "test-complex-path-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-complex-path-alb-sg"
  security_group_description = "Security group for complex path routing ALB"

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
      name                 = "default-tg"
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
    },
    {
      name                 = "api-v1-tg"
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 60
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
    },
    {
      name                 = "api-v2-tg"
      port                 = 8081
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 60
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
    },
    {
      name                 = "static-tg"
      port                 = 8082
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

  listeners = [
    {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
      additional_certificate_arns = []

      default_action = {
        type              = "forward"
        target_group_name = "default-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  # Complex routing rules with multiple path patterns
  listener_rules = [
    {
      # Route API v1 endpoints
      listener_port = 443
      priority      = 50

      conditions = [
        {
          path_pattern = {
            values = ["/api/v1/*"]
          }
          host_header         = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
        type              = "forward"
        target_group_name = "api-v1-tg"
        redirect          = null
        fixed_response    = null
      }
    },
    {
      # Route API v2 endpoints
      listener_port = 443
      priority      = 60

      conditions = [
        {
          path_pattern = {
            values = ["/api/v2/*"]
          }
          host_header         = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
        type              = "forward"
        target_group_name = "api-v2-tg"
        redirect          = null
        fixed_response    = null
      }
    },
    {
      # Route static content
      listener_port = 443
      priority      = 100

      conditions = [
        {
          path_pattern = {
            values = ["/static/*", "/assets/*", "/images/*"]
          }
          host_header         = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
        type              = "forward"
        target_group_name = "static-tg"
        redirect          = null
        fixed_response    = null
      }
    },
    {
      # Return 404 for deprecated endpoints
      listener_port = 443
      priority      = 150

      conditions = [
        {
          path_pattern = {
            values = ["/deprecated/*"]
          }
          host_header         = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
        type              = "fixed-response"
        target_group_name = null
        redirect          = null
        fixed_response = {
          content_type = "text/plain"
          message_body = "This endpoint has been deprecated"
          status_code  = "404"
        }
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "complex-path-routing-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Path-based routing with redirect
# Demonstrates redirecting certain paths
# -----------------------------------------------------------------------------

module "path_redirect_alb" {
  source = "../../"

  alb_name = "test-path-redirect-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-path-redirect-alb-sg"
  security_group_description = "Security group for path redirect ALB"

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
      name                 = "app-tg"
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

  listeners = [
    {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
      additional_certificate_arns = []

      default_action = {
        type              = "forward"
        target_group_name = "app-tg"
        redirect          = null
        fixed_response    = null
      }
    }
  ]

  # Redirect old paths to new paths
  listener_rules = [
    {
      # Redirect /old/* to /new/*
      listener_port = 443
      priority      = 100

      conditions = [
        {
          path_pattern = {
            values = ["/old/*"]
          }
          host_header         = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
        type              = "redirect"
        target_group_name = null
        redirect = {
          protocol    = "#{protocol}"
          port        = "#{port}"
          host        = "#{host}"
          path        = "/new/#{path}"
          query       = "#{query}"
          status_code = "HTTP_301"
        }
        fixed_response = null
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "path-redirect-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "path_based_alb_dns_name" {
  description = "DNS name for path-based routing ALB"
  value       = module.path_based_alb.alb_dns_name
}

output "path_based_alb_listener_rules" {
  description = "Listener rule ARNs for path-based ALB"
  value       = module.path_based_alb.listener_rule_arns
}

output "complex_path_alb_dns_name" {
  description = "DNS name for complex path routing ALB"
  value       = module.complex_path_routing_alb.alb_dns_name
}

output "path_redirect_alb_dns_name" {
  description = "DNS name for path redirect ALB"
  value       = module.path_redirect_alb.alb_dns_name
}
