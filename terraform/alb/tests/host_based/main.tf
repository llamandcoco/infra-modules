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
# Test 1: Host-based routing
# Demonstrates routing traffic based on the Host header
# Useful for multi-tenant applications or multiple domains
# -----------------------------------------------------------------------------

module "host_based_alb" {
  source = "../../"

  alb_name = "test-host-based-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-host-based-alb-sg"
  security_group_description = "Security group for host-based routing ALB"

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

  # Three target groups for different subdomains
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
        path                = "/health"
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
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTPS"
        matcher             = "200"
      }

      stickiness = null
      targets    = []
    }
  ]

  # HTTPS listener with SNI support (multiple certificates)
  listeners = [
    {
      port        = 443
      protocol    = "HTTPS"
      ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      # Default certificate for www.example.com
      certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"

      # Additional certificates for SNI (api.example.com, admin.example.com)
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

  # Host-based routing rules
  listener_rules = [
    {
      # Route api.example.com to API target group
      listener_port = 443
      priority      = 100

      conditions = [
        {
          host_header = {
            values = ["api.example.com"]
          }
          path_pattern        = null
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
      # Route admin.example.com to Admin target group
      listener_port = 443
      priority      = 200

      conditions = [
        {
          host_header = {
            values = ["admin.example.com"]
          }
          path_pattern        = null
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
    },
    {
      # Route www.example.com and example.com to Web target group
      listener_port = 443
      priority      = 300

      conditions = [
        {
          host_header = {
            values = ["www.example.com", "example.com"]
          }
          path_pattern        = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        }
      ]

      action = {
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
    Purpose     = "host-based-routing-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: Combined host and path-based routing
# Demonstrates routing based on both host and path
# Useful for complex multi-tenant applications
# -----------------------------------------------------------------------------

module "combined_routing_alb" {
  source = "../../"

  alb_name = "test-combined-routing-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-combined-routing-alb-sg"
  security_group_description = "Security group for combined routing ALB"

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

  # Combined host and path routing
  listener_rules = [
    {
      # Route api.example.com/v1/* to API v1 target group
      listener_port = 443
      priority      = 50

      conditions = [
        {
          host_header = {
            values = ["api.example.com"]
          }
          path_pattern        = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        },
        {
          path_pattern = {
            values = ["/v1/*"]
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
      # Route api.example.com/v2/* to API v2 target group
      listener_port = 443
      priority      = 60

      conditions = [
        {
          host_header = {
            values = ["api.example.com"]
          }
          path_pattern        = null
          http_header         = null
          http_request_method = null
          query_string        = null
          source_ip           = null
        },
        {
          path_pattern = {
            values = ["/v2/*"]
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
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "combined-routing-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Host-based routing with redirect
# Demonstrates redirecting non-www to www
# -----------------------------------------------------------------------------

module "host_redirect_alb" {
  source = "../../"

  alb_name = "test-host-redirect-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group      = true
  security_group_name        = "test-host-redirect-alb-sg"
  security_group_description = "Security group for host redirect ALB"

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

  # Redirect example.com to www.example.com
  listener_rules = [
    {
      listener_port = 443
      priority      = 100

      conditions = [
        {
          host_header = {
            values = ["example.com"]
          }
          path_pattern        = null
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
          host        = "www.example.com"
          path        = "/#{path}"
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
    Purpose     = "host-redirect-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "host_based_alb_dns_name" {
  description = "DNS name for host-based routing ALB"
  value       = module.host_based_alb.alb_dns_name
}

output "host_based_alb_listener_rules" {
  description = "Listener rule ARNs for host-based ALB"
  value       = module.host_based_alb.listener_rule_arns
}

output "combined_routing_alb_dns_name" {
  description = "DNS name for combined routing ALB"
  value       = module.combined_routing_alb.alb_dns_name
}

output "host_redirect_alb_dns_name" {
  description = "DNS name for host redirect ALB"
  value       = module.host_redirect_alb.alb_dns_name
}
