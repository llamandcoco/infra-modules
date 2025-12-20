# Application Load Balancer (ALB) Module

A production-ready Terraform module for creating and managing AWS Application Load Balancers with support for multiple target groups, HTTPS/HTTP listeners, path-based routing, host-based routing, and advanced configurations.

## Features

- Application Load Balancer Internet-facing or internal ALB with full configuration options
- Multiple Target Groups Support for multiple target groups with different health check configurations
- Flexible Listeners HTTP and HTTPS listeners with SSL/TLS support
- Advanced Routing Path-based and host-based routing with listener rules
- Security Optional security group creation with configurable ingress/egress rules
- Sticky Sessions Session affinity support with lb_cookie or app_cookie
- Health Checks Comprehensive health check configuration per target group
- Access Logs Optional S3 access logging for troubleshooting

## Quick Start

```hcl
module "alb" {
  source = "github.com/llamandcoco/infra-modules//terraform/alb?ref=v1.0.0"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/`](tests/basic/) |
| Host Based | [`tests/host_based/`](tests/host_based/) |
| Https | [`tests/https/`](tests/https/) |
| Multi Target | [`tests/multi_target/`](tests/multi_target/) |
| Path Based | [`tests/path_based/`](tests/path_based/) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | S3 bucket name for access logs. Required if enable\_access\_logs is true. Bucket must have proper permissions for ALB. | `string` | `null` | no |
| <a name="input_access_logs_prefix"></a> [access\_logs\_prefix](#input\_access\_logs\_prefix) | S3 prefix for access logs. Organizes logs within the bucket. Optional. | `string` | `null` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the Application Load Balancer. Used for Name tag and resource naming. | `string` | n/a | yes |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create a new security group for the ALB. If true, security\_group\_name is required. | `bool` | `false` | no |
| <a name="input_desync_mitigation_mode"></a> [desync\_mitigation\_mode](#input\_desync\_mitigation\_mode) | How the ALB handles requests that might pose a security risk. Options: monitor (logs), defensive (sanitizes), strictest (rejects). | `string` | `"defensive"` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Drop invalid HTTP header fields before routing to targets. Recommended for security. | `bool` | `true` | no |
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | Enable access logs to S3. Useful for troubleshooting and compliance. Logs stored in specified S3 bucket. | `bool` | `false` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Enable cross-zone load balancing. Distributes traffic evenly across all registered targets in all enabled AZs. | `bool` | `true` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable deletion protection for the ALB. Recommended for production workloads to prevent accidental deletion. | `bool` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Enable HTTP/2 protocol support. HTTP/2 is more efficient than HTTP/1.1 and is enabled by default. | `bool` | `true` | no |
| <a name="input_enable_waf_fail_open"></a> [enable\_waf\_fail\_open](#input\_enable\_waf\_fail\_open) | Enable WAF fail open mode. If true, allows requests through if WAF is unavailable. Use with caution in production. | `bool` | `false` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | Time in seconds that connections are allowed to be idle. Range: 1-4000 seconds. Increase for WebSocket connections. | `number` | `60` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Whether the ALB is internal (true) or internet-facing (false). Internet-facing ALBs route requests from clients over the internet. | `bool` | `false` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | IP address type for the ALB. Options: ipv4 (default), dualstack (IPv4 and IPv6), dualstack-without-public-ipv4. | `string` | `"ipv4"` | no |
| <a name="input_listener_rules"></a> [listener\_rules](#input\_listener\_rules) | List of listener rules for path-based, host-based, or other conditional routing.<br/><br/>Example path-based rule:<br/>[<br/>  {<br/>    listener\_port = 443<br/>    priority      = 100<br/><br/>    conditions = [<br/>      {<br/>        path\_pattern = {<br/>          values = ["/api/*"]<br/>        }<br/>        host\_header          = null<br/>        http\_header          = null<br/>        http\_request\_method  = null<br/>        query\_string         = null<br/>        source\_ip            = null<br/>      }<br/>    ]<br/><br/>    action = {<br/>      type              = "forward"<br/>      target\_group\_name = "api-tg"<br/>      redirect          = null<br/>      fixed\_response    = null<br/>    }<br/>  }<br/>]<br/><br/>Example host-based rule:<br/>[<br/>  {<br/>    listener\_port = 443<br/>    priority      = 200<br/><br/>    conditions = [<br/>      {<br/>        host\_header = {<br/>          values = ["api.example.com"]<br/>        }<br/>        path\_pattern         = null<br/>        http\_header          = null<br/>        http\_request\_method  = null<br/>        query\_string         = null<br/>        source\_ip            = null<br/>      }<br/>    ]<br/><br/>    action = {<br/>      type              = "forward"<br/>      target\_group\_name = "api-tg"<br/>      redirect          = null<br/>      fixed\_response    = null<br/>    }<br/>  }<br/>] | <pre>list(object({<br/>    listener_port = number<br/>    priority      = number<br/><br/>    conditions = list(object({<br/>      path_pattern = optional(object({<br/>        values = list(string)<br/>      }))<br/><br/>      host_header = optional(object({<br/>        values = list(string)<br/>      }))<br/><br/>      http_header = optional(object({<br/>        http_header_name = string<br/>        values           = list(string)<br/>      }))<br/><br/>      http_request_method = optional(object({<br/>        values = list(string)<br/>      }))<br/><br/>      query_string = optional(object({<br/>        key   = optional(string)<br/>        value = string<br/>      }))<br/><br/>      source_ip = optional(object({<br/>        values = list(string)<br/>      }))<br/>    }))<br/><br/>    action = object({<br/>      type              = string<br/>      target_group_name = optional(string)<br/><br/>      redirect = optional(object({<br/>        protocol    = optional(string, "#{protocol}")<br/>        port        = optional(string, "#{port}")<br/>        host        = optional(string, "#{host}")<br/>        path        = optional(string, "/#{path}")<br/>        query       = optional(string, "#{query}")<br/>        status_code = string<br/>      }))<br/><br/>      fixed_response = optional(object({<br/>        content_type = string<br/>        message_body = optional(string)<br/>        status_code  = string<br/>      }))<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | List of listeners to create. At least one listener is required.<br/><br/>Example HTTP listener:<br/>[<br/>  {<br/>    port     = 80<br/>    protocol = "HTTP"<br/>    ssl\_policy = null<br/>    certificate\_arn = null<br/>    additional\_certificate\_arns = []<br/><br/>    default\_action = {<br/>      type              = "forward"<br/>      target\_group\_name = "web-tg"<br/><br/>      redirect = null<br/>      fixed\_response = null<br/>    }<br/>  }<br/>]<br/><br/>Example HTTPS listener:<br/>[<br/>  {<br/>    port            = 443<br/>    protocol        = "HTTPS"<br/>    ssl\_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"<br/>    certificate\_arn = "arn:aws:acm:..."<br/>    additional\_certificate\_arns = []<br/><br/>    default\_action = {<br/>      type              = "forward"<br/>      target\_group\_name = "web-tg"<br/><br/>      redirect = null<br/>      fixed\_response = null<br/>    }<br/>  }<br/>]<br/><br/>Example HTTP to HTTPS redirect:<br/>[<br/>  {<br/>    port     = 80<br/>    protocol = "HTTP"<br/><br/>    default\_action = {<br/>      type = "redirect"<br/>      target\_group\_name = null<br/><br/>      redirect = {<br/>        protocol    = "HTTPS"<br/>        port        = "443"<br/>        host        = "#{host}"<br/>        path        = "/#{path}"<br/>        query       = "#{query}"<br/>        status\_code = "HTTP\_301"<br/>      }<br/><br/>      fixed\_response = null<br/>    }<br/>  }<br/>] | <pre>list(object({<br/>    port                        = number<br/>    protocol                    = string<br/>    ssl_policy                  = optional(string)<br/>    certificate_arn             = optional(string)<br/>    additional_certificate_arns = optional(list(string), [])<br/><br/>    default_action = object({<br/>      type              = string<br/>      target_group_name = optional(string)<br/><br/>      redirect = optional(object({<br/>        protocol    = optional(string, "#{protocol}")<br/>        port        = optional(string, "#{port}")<br/>        host        = optional(string, "#{host}")<br/>        path        = optional(string, "/#{path}")<br/>        query       = optional(string, "#{query}")<br/>        status_code = string<br/>      }))<br/><br/>      fixed_response = optional(object({<br/>        content_type = string<br/>        message_body = optional(string)<br/>        status_code  = string<br/>      }))<br/>    })<br/>  }))</pre> | n/a | yes |
| <a name="input_preserve_host_header"></a> [preserve\_host\_header](#input\_preserve\_host\_header) | Preserve the Host header in requests sent to targets. Set to true if your application needs the original host. | `bool` | `false` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description for the security group. Used when create\_security\_group is true. | `string` | `"Security group for Application Load Balancer"` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | List of egress rules for the security group. Only used if create\_security\_group is true.<br/>Example:<br/>[<br/>  {<br/>    from\_port   = 0<br/>    to\_port     = 0<br/>    protocol    = "-1"<br/>    cidr\_blocks = ["0.0.0.0/0"]<br/>    description = "Allow all outbound traffic"<br/>  }<br/>] | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>    description = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to the ALB. If create\_security\_group is true, this is optional. | `list(string)` | `[]` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | List of ingress rules for the security group. Only used if create\_security\_group is true.<br/>Example:<br/>[<br/>  {<br/>    from\_port   = 80<br/>    to\_port     = 80<br/>    protocol    = "tcp"<br/>    cidr\_blocks = ["0.0.0.0/0"]<br/>    description = "Allow HTTP from anywhere"<br/>  }<br/>] | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>    description = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group to create. Required if create\_security\_group is true. | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs for the ALB. Minimum 2 subnets in different AZs required. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use for cost allocation, resource organization, and governance. | `map(string)` | `{}` | no |
| <a name="input_target_group_tags"></a> [target\_group\_tags](#input\_target\_group\_tags) | Additional tags to apply to target groups only. Merged with var.tags. | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | List of target groups to create. At least one target group is required.<br/><br/>Example:<br/>[<br/>  {<br/>    name                 = "web-tg"<br/>    port                 = 80<br/>    protocol             = "HTTP"<br/>    target\_type          = "instance"<br/>    deregistration\_delay = 300<br/>    slow\_start           = 0<br/><br/>    health\_check = {<br/>      enabled             = true<br/>      healthy\_threshold   = 3<br/>      unhealthy\_threshold = 3<br/>      timeout             = 5<br/>      interval            = 30<br/>      path                = "/health"<br/>      port                = "traffic-port"<br/>      protocol            = "HTTP"<br/>      matcher             = "200"<br/>    }<br/><br/>    stickiness = {<br/>      enabled         = true<br/>      type            = "lb\_cookie"<br/>      cookie\_duration = 86400<br/>      cookie\_name     = null<br/>    }<br/><br/>    targets = [<br/>      {<br/>        target\_id         = "i-1234567890abcdef0"<br/>        port              = null<br/>        availability\_zone = null<br/>      }<br/>    ]<br/>  }<br/>] | <pre>list(object({<br/>    name                 = string<br/>    port                 = number<br/>    protocol             = string<br/>    target_type          = string<br/>    deregistration_delay = optional(number, 300)<br/>    slow_start           = optional(number, 0)<br/><br/>    health_check = optional(object({<br/>      enabled             = optional(bool, true)<br/>      healthy_threshold   = optional(number, 3)<br/>      unhealthy_threshold = optional(number, 3)<br/>      timeout             = optional(number, 5)<br/>      interval            = optional(number, 30)<br/>      path                = optional(string, "/")<br/>      port                = optional(string, "traffic-port")<br/>      protocol            = optional(string, "HTTP")<br/>      matcher             = optional(string, "200")<br/>    }), {})<br/><br/>    stickiness = optional(object({<br/>      enabled         = bool<br/>      type            = string<br/>      cookie_duration = optional(number, 86400)<br/>      cookie_name     = optional(string)<br/>    }))<br/><br/>    targets = optional(list(object({<br/>      target_id         = string<br/>      port              = optional(number)<br/>      availability_zone = optional(string)<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the ALB will be created. Required for target groups and security group. | `string` | n/a | yes |
| <a name="input_web_acl_arn"></a> [web\_acl\_arn](#input\_web\_acl\_arn) | ARN of AWS WAF Web ACL to associate with the ALB. Provides application-layer DDoS protection and filtering. | `string` | `null` | no |
| <a name="input_xff_header_processing_mode"></a> [xff\_header\_processing\_mode](#input\_xff\_header\_processing\_mode) | How the ALB handles X-Forwarded-For headers. Options: append (default), preserve (keep client value), remove. | `string` | `"append"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | The ARN of the ALB. Use this for IAM policies, CloudWatch alarms, and cross-account access. |
| <a name="output_alb_arn_suffix"></a> [alb\_arn\_suffix](#output\_alb\_arn\_suffix) | The ARN suffix for use with CloudWatch metrics. Format: app/alb-name/1234567890abcdef |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the ALB. Use this to access the load balancer or create DNS records. |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | The ID of the ALB. Use this for resource references and integrations. |
| <a name="output_alb_name"></a> [alb\_name](#output\_alb\_name) | The name of the ALB. |
| <a name="output_alb_type"></a> [alb\_type](#output\_alb\_type) | The type of load balancer. Always 'application' for this module. |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | The canonical hosted zone ID of the ALB. Use this for creating Route53 alias records. |
| <a name="output_enable_deletion_protection"></a> [enable\_deletion\_protection](#output\_enable\_deletion\_protection) | Whether deletion protection is enabled for the ALB. |
| <a name="output_enable_http2"></a> [enable\_http2](#output\_enable\_http2) | Whether HTTP/2 is enabled for the ALB. |
| <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn) | ARN of the HTTP listener (port 80), if it exists. Null otherwise. |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | ARN of the HTTPS listener (port 443), if it exists. Null otherwise. |
| <a name="output_idle_timeout"></a> [idle\_timeout](#output\_idle\_timeout) | The idle timeout value in seconds for the ALB. |
| <a name="output_internal"></a> [internal](#output\_internal) | Whether the ALB is internal (true) or internet-facing (false). |
| <a name="output_ip_address_type"></a> [ip\_address\_type](#output\_ip\_address\_type) | The IP address type of the ALB (ipv4, dualstack, or dualstack-without-public-ipv4). |
| <a name="output_listener_arns"></a> [listener\_arns](#output\_listener\_arns) | Map of listener ports to their ARNs. Use these for creating listener rules or certificates. |
| <a name="output_listener_ids"></a> [listener\_ids](#output\_listener\_ids) | Map of listener ports to their IDs. Use these for resource references. |
| <a name="output_listener_rule_arns"></a> [listener\_rule\_arns](#output\_listener\_rule\_arns) | Map of listener rule keys to their ARNs. Use these for monitoring or modifications. |
| <a name="output_listener_rule_ids"></a> [listener\_rule\_ids](#output\_listener\_rule\_ids) | Map of listener rule keys to their IDs. Use these for resource references. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group created for the ALB. Null if create\_security\_group is false. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | The list of subnet IDs attached to the ALB. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the ALB, including defaults and custom tags. |
| <a name="output_target_group_arn_suffixes"></a> [target\_group\_arn\_suffixes](#output\_target\_group\_arn\_suffixes) | Map of target group names to their ARN suffixes. Use these for CloudWatch metrics and monitoring. |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | Map of target group names to their ARNs. Use these for registering targets or creating listener rules. |
| <a name="output_target_group_ids"></a> [target\_group\_ids](#output\_target\_group\_ids) | Map of target group names to their IDs. Use these for resource references. |
| <a name="output_target_group_names"></a> [target\_group\_names](#output\_target\_group\_names) | Map of target group keys to their names. Lists all target groups created. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID where the ALB and target groups are created. |
<!-- END_TF_DOCS -->
