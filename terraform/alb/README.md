# Application Load Balancer (ALB) Module

A production-ready Terraform module for creating and managing AWS Application Load Balancers with support for multiple target groups, HTTPS/HTTP listeners, path-based routing, host-based routing, and advanced configurations.

## Features

- **Application Load Balancer**: Internet-facing or internal ALB with full configuration options
- **Multiple Target Groups**: Support for multiple target groups with different health check configurations
- **Flexible Listeners**: HTTP and HTTPS listeners with SSL/TLS support
- **Advanced Routing**: Path-based and host-based routing with listener rules
- **Security**: Optional security group creation with configurable ingress/egress rules
- **Sticky Sessions**: Session affinity support with lb_cookie or app_cookie
- **Health Checks**: Comprehensive health check configuration per target group
- **Access Logs**: Optional S3 access logging for troubleshooting
- **SSL/TLS**: Support for multiple certificates via SNI
- **WAF Integration**: Optional AWS WAF Web ACL association
- **Production Ready**: Deletion protection, drop invalid headers, and desync mitigation

## Usage Examples

### Basic HTTP ALB

```hcl
module "basic_alb" {
  source = "../../terraform/alb"

  alb_name = "my-web-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  # Create security group
  create_security_group      = true
  security_group_name        = "my-web-alb-sg"
  security_group_description = "Security group for web ALB"

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
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### HTTPS ALB with HTTP to HTTPS Redirect

```hcl
module "https_alb" {
  source = "../../terraform/alb"

  alb_name = "my-https-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  # Enable deletion protection for production
  enable_deletion_protection = true

  # Security configuration
  create_security_group      = true
  security_group_name        = "my-https-alb-sg"
  drop_invalid_header_fields = true

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
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Path-Based Routing

```hcl
module "path_based_alb" {
  source = "../../terraform/alb"

  alb_name = "my-path-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group = true
  security_group_name   = "my-path-alb-sg"

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

  # Multiple target groups
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

  # Path-based routing rules
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
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Host-Based Routing

```hcl
module "host_based_alb" {
  source = "../../terraform/alb"

  alb_name = "my-host-alb"
  vpc_id   = "vpc-12345678"
  subnets  = ["subnet-12345678", "subnet-87654321"]

  create_security_group = true
  security_group_name   = "my-host-alb-sg"

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
    }
  ]

  listeners = [
    {
      port        = 443
      protocol    = "HTTPS"
      ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"

      # Additional certificates for SNI
      additional_certificate_arns = [
        "arn:aws:acm:us-east-1:123456789012:certificate/22222222-2222-2222-2222-222222222222"
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
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## SSL/TLS Policy Guide

Recommended TLS policies (from most secure to most compatible):

| Policy | TLS Version | Description | Use Case |
|--------|-------------|-------------|----------|
| `ELBSecurityPolicy-TLS13-1-2-2021-06` | TLS 1.3 only | Most secure, latest protocol | Modern applications |
| `ELBSecurityPolicy-TLS13-1-2-Res-2021-06` | TLS 1.2-1.3 | Recommended balance | Production (recommended) |
| `ELBSecurityPolicy-TLS-1-2-2017-01` | TLS 1.2+ | Legacy compatibility | Older clients |
| `ELBSecurityPolicy-2016-08` | TLS 1.0+ | Maximum compatibility | Legacy systems |

## Health Check Best Practices

- **Dedicated endpoint**: Use `/health` or `/ping` instead of root `/`
- **Timeout < Interval**: Timeout must be less than interval
- **Healthy threshold**: 2-5 (lower = faster recovery from failure)
- **Unhealthy threshold**: 2-3 (lower = faster detection of failure)
- **Interval**: 15-30 seconds for active monitoring
- **Matcher**: Use `200` for exact match or `200-299` for range

Example health check configuration:

```hcl
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
```

## Target Group Types

| Type | Description | Use Case |
|------|-------------|----------|
| `instance` | EC2 instances by instance ID | Traditional EC2 deployments |
| `ip` | IP addresses | ECS/Fargate containers, on-premises servers |
| `lambda` | Lambda functions | Serverless applications |
| `alb` | Another ALB | ALB chaining for complex routing |

## Routing Patterns

### Path-Based Routing

Route requests based on URL path:

```
/api/*          → API target group
/static/*       → Static content target group
/admin/*        → Admin target group
/*              → Default web target group
```

### Host-Based Routing

Route requests based on domain:

```
api.example.com     → API target group
www.example.com     → Web target group
admin.example.com   → Admin target group
```

### Combined Routing

Combine host and path for complex scenarios:

```
api.example.com/v1/*  → API v1 target group
api.example.com/v2/*  → API v2 target group
www.example.com/*     → Web target group
```

## Sticky Sessions

Session affinity keeps requests from the same client routed to the same target:

### LB Cookie (Duration-Based)

```hcl
stickiness = {
  enabled         = true
  type            = "lb_cookie"
  cookie_duration = 86400  # 24 hours in seconds
  cookie_name     = null
}
```

### App Cookie (Name-Based)

```hcl
stickiness = {
  enabled         = true
  type            = "app_cookie"
  cookie_duration = 86400
  cookie_name     = "JSESSIONID"  # Your application's cookie name
}
```

**Use cases**: Stateful applications, session management, shopping carts

## Access Logs

Enable access logs for production troubleshooting:

```hcl
enable_access_logs  = true
access_logs_bucket  = "my-alb-logs-bucket"
access_logs_prefix  = "prod-alb"
```

**Log contents**: Request time, client IP, latencies, request paths, server responses

**Retention**: Managed by S3 lifecycle policies

## ALB-Specific Considerations

- **Cross-zone load balancing**: Enabled by default for even distribution across AZs
- **Connection draining**: Use `deregistration_delay` (default 300s, range 0-3600s)
- **Slow start**: Gradual traffic increase to new targets (30-900s or 0 to disable)
- **Idle timeout**: For WebSocket connections, increase from default 60s
- **IP address type**: Use `dualstack` for IPv4/IPv6 support
- **Subnet requirements**: Minimum 2 subnets in different AZs
- **Subnet capacity**: ALB needs at least 8 free IPs per subnet
- **SNI support**: Multiple SSL certificates per listener via `additional_certificate_arns`
- **WebSocket**: Supported automatically for HTTP/HTTPS listeners
- **HTTP/2**: Enabled by default, can be disabled via `enable_http2 = false`

## Security Best Practices

1. **Drop invalid headers**: Enable `drop_invalid_header_fields = true` (default)
2. **Latest TLS policy**: Use `ELBSecurityPolicy-TLS13-1-2-2021-06` for HTTPS
3. **Deletion protection**: Enable for production workloads
4. **Security groups**: Explicit ingress/egress rules
5. **WAF integration**: Associate WAF Web ACL via `web_acl_arn`
6. **Access logs**: Enable for audit and troubleshooting

## Common Use Cases

### Web Application with HTTP/HTTPS

Internet-facing ALB with HTTP to HTTPS redirect, serving web application on EC2 instances.

### Microservices with Path-Based Routing

Single ALB routing to multiple microservices based on URL path (`/api/*`, `/admin/*`, etc.).

### Multi-Tenant SaaS with Host-Based Routing

Route different customer subdomains to separate target groups for tenant isolation.

### Container-Based Application (ECS/EKS)

IP-based target groups for dynamic container networking in ECS or Kubernetes.

### Lambda Behind ALB

Serverless functions exposed via ALB using `target_type = "lambda"`.

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Resources

This module creates the following resources:

- `aws_lb` - Application Load Balancer
- `aws_lb_target_group` - Target groups (one or more)
- `aws_lb_listener` - Listeners (HTTP/HTTPS)
- `aws_lb_listener_rule` - Listener rules (optional)
- `aws_lb_target_group_attachment` - Target attachments (optional)
- `aws_lb_listener_certificate` - Additional certificates for SNI (optional)
- `aws_security_group` - Security group (optional)
- `aws_vpc_security_group_ingress_rule` - Ingress rules (optional)
- `aws_vpc_security_group_egress_rule` - Egress rules (optional)
- `aws_wafv2_web_acl_association` - WAF association (optional)

## License

This module is licensed under the MIT License.
