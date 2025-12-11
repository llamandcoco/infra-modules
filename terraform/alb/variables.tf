# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "alb_name" {
  description = "Name of the Application Load Balancer. Used for Name tag and resource naming."
  type        = string

  validation {
    condition     = length(var.alb_name) > 0 && length(var.alb_name) <= 32
    error_message = "ALB name must be between 1 and 32 characters."
  }
}

variable "subnets" {
  description = "List of subnet IDs for the ALB. Minimum 2 subnets in different AZs required."
  type        = list(string)

  validation {
    condition     = length(var.subnets) >= 2
    error_message = "At least 2 subnets must be provided for ALB."
  }

  validation {
    condition     = alltrue([for s in var.subnets : can(regex("^subnet-", s))])
    error_message = "All subnet IDs must start with 'subnet-'."
  }
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be created. Required for target groups and security group."
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

# -----------------------------------------------------------------------------
# Load Balancer Configuration
# -----------------------------------------------------------------------------

variable "internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false). Internet-facing ALBs route requests from clients over the internet."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type for the ALB. Options: ipv4 (default), dualstack (IPv4 and IPv6), dualstack-without-public-ipv4."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack", "dualstack-without-public-ipv4"], var.ip_address_type)
    error_message = "IP address type must be one of: ipv4, dualstack, dualstack-without-public-ipv4."
  }
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB. Recommended for production workloads to prevent accidental deletion."
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing. Distributes traffic evenly across all registered targets in all enabled AZs."
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2 protocol support. HTTP/2 is more efficient than HTTP/1.1 and is enabled by default."
  type        = bool
  default     = true
}

variable "enable_waf_fail_open" {
  description = "Enable WAF fail open mode. If true, allows requests through if WAF is unavailable. Use with caution in production."
  type        = bool
  default     = false
}

variable "desync_mitigation_mode" {
  description = "How the ALB handles requests that might pose a security risk. Options: monitor (logs), defensive (sanitizes), strictest (rejects)."
  type        = string
  default     = "defensive"

  validation {
    condition     = contains(["monitor", "defensive", "strictest"], var.desync_mitigation_mode)
    error_message = "Desync mitigation mode must be one of: monitor, defensive, strictest."
  }
}

variable "idle_timeout" {
  description = "Time in seconds that connections are allowed to be idle. Range: 1-4000 seconds. Increase for WebSocket connections."
  type        = number
  default     = 60

  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds."
  }
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "security_group_ids" {
  description = "List of security group IDs to attach to the ALB. If create_security_group is true, this is optional."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for sg in var.security_group_ids : can(regex("^sg-", sg))])
    error_message = "All security group IDs must start with 'sg-'."
  }
}

variable "create_security_group" {
  description = "Create a new security group for the ALB. If true, security_group_name is required."
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name of the security group to create. Required if create_security_group is true."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description for the security group. Used when create_security_group is true."
  type        = string
  default     = "Security group for Application Load Balancer"
}

variable "security_group_ingress_rules" {
  description = <<-EOT
    List of ingress rules for the security group. Only used if create_security_group is true.
    Example:
    [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP from anywhere"
      }
    ]
  EOT
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "security_group_egress_rules" {
  description = <<-EOT
    List of egress rules for the security group. Only used if create_security_group is true.
    Example:
    [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
      }
    ]
  EOT
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid HTTP header fields before routing to targets. Recommended for security."
  type        = bool
  default     = true
}

variable "preserve_host_header" {
  description = "Preserve the Host header in requests sent to targets. Set to true if your application needs the original host."
  type        = bool
  default     = false
}

variable "xff_header_processing_mode" {
  description = "How the ALB handles X-Forwarded-For headers. Options: append (default), preserve (keep client value), remove."
  type        = string
  default     = "append"

  validation {
    condition     = contains(["append", "preserve", "remove"], var.xff_header_processing_mode)
    error_message = "X-Forwarded-For header processing mode must be one of: append, preserve, remove."
  }
}

# -----------------------------------------------------------------------------
# Access Logs Configuration
# -----------------------------------------------------------------------------

variable "enable_access_logs" {
  description = "Enable access logs to S3. Useful for troubleshooting and compliance. Logs stored in specified S3 bucket."
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket name for access logs. Required if enable_access_logs is true. Bucket must have proper permissions for ALB."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 prefix for access logs. Organizes logs within the bucket. Optional."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# WAF Integration
# -----------------------------------------------------------------------------

variable "web_acl_arn" {
  description = "ARN of AWS WAF Web ACL to associate with the ALB. Provides application-layer DDoS protection and filtering."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Target Groups Configuration
# -----------------------------------------------------------------------------

variable "target_groups" {
  description = <<-EOT
    List of target groups to create. At least one target group is required.

    Example:
    [
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

        stickiness = {
          enabled         = true
          type            = "lb_cookie"
          cookie_duration = 86400
          cookie_name     = null
        }

        targets = [
          {
            target_id         = "i-1234567890abcdef0"
            port              = null
            availability_zone = null
          }
        ]
      }
    ]
  EOT
  type = list(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = string
    deregistration_delay = optional(number, 300)
    slow_start           = optional(number, 0)

    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      timeout             = optional(number, 5)
      interval            = optional(number, 30)
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      matcher             = optional(string, "200")
    }), {})

    stickiness = optional(object({
      enabled         = bool
      type            = string
      cookie_duration = optional(number, 86400)
      cookie_name     = optional(string)
    }))

    targets = optional(list(object({
      target_id         = string
      port              = optional(number)
      availability_zone = optional(string)
    })), [])
  }))

  validation {
    condition     = length(var.target_groups) >= 1
    error_message = "At least one target group must be defined."
  }

  validation {
    condition     = alltrue([for tg in var.target_groups : contains(["HTTP", "HTTPS"], tg.protocol)])
    error_message = "Target group protocol must be HTTP or HTTPS."
  }

  validation {
    condition     = alltrue([for tg in var.target_groups : contains(["instance", "ip", "lambda", "alb"], tg.target_type)])
    error_message = "Target type must be one of: instance, ip, lambda, alb."
  }

  validation {
    condition     = alltrue([for tg in var.target_groups : tg.port >= 1 && tg.port <= 65535])
    error_message = "Target group port must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups :
      tg.deregistration_delay >= 0 && tg.deregistration_delay <= 3600
    ])
    error_message = "Deregistration delay must be between 0 and 3600 seconds."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups :
      tg.slow_start == 0 || (tg.slow_start >= 30 && tg.slow_start <= 900)
    ])
    error_message = "Slow start must be 0 (disabled) or between 30 and 900 seconds."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups :
      tg.health_check.healthy_threshold >= 2 && tg.health_check.healthy_threshold <= 10
    ])
    error_message = "Health check healthy_threshold must be between 2 and 10."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups :
      tg.health_check.unhealthy_threshold >= 2 && tg.health_check.unhealthy_threshold <= 10
    ])
    error_message = "Health check unhealthy_threshold must be between 2 and 10."
  }

  validation {
    condition = alltrue([
      for tg in var.target_groups :
      tg.health_check.timeout < tg.health_check.interval
    ])
    error_message = "Health check timeout must be less than interval."
  }
}

# -----------------------------------------------------------------------------
# Listeners Configuration
# -----------------------------------------------------------------------------

variable "listeners" {
  description = <<-EOT
    List of listeners to create. At least one listener is required.

    Example HTTP listener:
    [
      {
        port     = 80
        protocol = "HTTP"
        ssl_policy = null
        certificate_arn = null
        additional_certificate_arns = []

        default_action = {
          type              = "forward"
          target_group_name = "web-tg"

          redirect = null
          fixed_response = null
        }
      }
    ]

    Example HTTPS listener:
    [
      {
        port            = 443
        protocol        = "HTTPS"
        ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
        certificate_arn = "arn:aws:acm:..."
        additional_certificate_arns = []

        default_action = {
          type              = "forward"
          target_group_name = "web-tg"

          redirect = null
          fixed_response = null
        }
      }
    ]

    Example HTTP to HTTPS redirect:
    [
      {
        port     = 80
        protocol = "HTTP"

        default_action = {
          type = "redirect"
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
      }
    ]
  EOT
  type = list(object({
    port                        = number
    protocol                    = string
    ssl_policy                  = optional(string)
    certificate_arn             = optional(string)
    additional_certificate_arns = optional(list(string), [])

    default_action = object({
      type              = string
      target_group_name = optional(string)

      redirect = optional(object({
        protocol    = optional(string, "#{protocol}")
        port        = optional(string, "#{port}")
        host        = optional(string, "#{host}")
        path        = optional(string, "/#{path}")
        query       = optional(string, "#{query}")
        status_code = string
      }))

      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
    })
  }))

  validation {
    condition     = length(var.listeners) >= 1
    error_message = "At least one listener must be defined."
  }

  validation {
    condition     = alltrue([for l in var.listeners : contains(["HTTP", "HTTPS"], l.protocol)])
    error_message = "Listener protocol must be HTTP or HTTPS."
  }

  validation {
    condition     = alltrue([for l in var.listeners : l.port >= 1 && l.port <= 65535])
    error_message = "Listener port must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for l in var.listeners :
      l.protocol != "HTTPS" || (l.ssl_policy != null && l.certificate_arn != null)
    ])
    error_message = "HTTPS listeners require both ssl_policy and certificate_arn."
  }

  validation {
    condition = alltrue([
      for l in var.listeners :
      contains(["forward", "redirect", "fixed-response"], l.default_action.type)
    ])
    error_message = "Listener default action type must be one of: forward, redirect, fixed-response."
  }

  validation {
    condition = alltrue([
      for l in var.listeners :
      l.default_action.type != "forward" || l.default_action.target_group_name != null
    ])
    error_message = "Forward action requires target_group_name."
  }

  validation {
    condition = alltrue([
      for l in var.listeners :
      l.default_action.type != "redirect" || l.default_action.redirect != null
    ])
    error_message = "Redirect action requires redirect configuration."
  }

  validation {
    condition = alltrue([
      for l in var.listeners :
      l.default_action.type != "fixed-response" || l.default_action.fixed_response != null
    ])
    error_message = "Fixed-response action requires fixed_response configuration."
  }

  validation {
    condition = alltrue([
      for l in var.listeners :
      l.default_action.redirect == null || contains(["HTTP_301", "HTTP_302"], l.default_action.redirect.status_code)
    ])
    error_message = "Redirect status_code must be HTTP_301 or HTTP_302."
  }
}

# -----------------------------------------------------------------------------
# Listener Rules Configuration
# -----------------------------------------------------------------------------

variable "listener_rules" {
  description = <<-EOT
    List of listener rules for path-based, host-based, or other conditional routing.

    Example path-based rule:
    [
      {
        listener_port = 443
        priority      = 100

        conditions = [
          {
            path_pattern = {
              values = ["/api/*"]
            }
            host_header          = null
            http_header          = null
            http_request_method  = null
            query_string         = null
            source_ip            = null
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

    Example host-based rule:
    [
      {
        listener_port = 443
        priority      = 200

        conditions = [
          {
            host_header = {
              values = ["api.example.com"]
            }
            path_pattern         = null
            http_header          = null
            http_request_method  = null
            query_string         = null
            source_ip            = null
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
  EOT
  type = list(object({
    listener_port = number
    priority      = number

    conditions = list(object({
      path_pattern = optional(object({
        values = list(string)
      }))

      host_header = optional(object({
        values = list(string)
      }))

      http_header = optional(object({
        http_header_name = string
        values           = list(string)
      }))

      http_request_method = optional(object({
        values = list(string)
      }))

      query_string = optional(object({
        key   = optional(string)
        value = string
      }))

      source_ip = optional(object({
        values = list(string)
      }))
    }))

    action = object({
      type              = string
      target_group_name = optional(string)

      redirect = optional(object({
        protocol    = optional(string, "#{protocol}")
        port        = optional(string, "#{port}")
        host        = optional(string, "#{host}")
        path        = optional(string, "/#{path}")
        query       = optional(string, "#{query}")
        status_code = string
      }))

      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
    })
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.listener_rules :
      rule.priority >= 1 && rule.priority <= 50000
    ])
    error_message = "Listener rule priority must be between 1 and 50000."
  }

  validation {
    condition = alltrue([
      for rule in var.listener_rules :
      contains(["forward", "redirect", "fixed-response"], rule.action.type)
    ])
    error_message = "Listener rule action type must be one of: forward, redirect, fixed-response."
  }

  validation {
    condition = alltrue([
      for rule in var.listener_rules :
      rule.action.type != "forward" || rule.action.target_group_name != null
    ])
    error_message = "Forward action requires target_group_name."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use for cost allocation, resource organization, and governance."
  type        = map(string)
  default     = {}
}

variable "target_group_tags" {
  description = "Additional tags to apply to target groups only. Merged with var.tags."
  type        = map(string)
  default     = {}
}
