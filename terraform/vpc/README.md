# VPC Terraform Module

Creates a production-ready Amazon VPC with optional IPv6 support, DNS configuration, and tagging.

## Usage

```hcl
module "vpc" {
  source = "github.com/your-org/infra-modules//terraform/vpc"

  name       = "core-vpc"
  cidr_block = "10.0.0.0/16"
  enable_ipv6 = false

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


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
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name tag for the VPC. | `string` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames for instances launched in the VPC. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS resolution for the VPC. | `bool` | `true` | no |
| <a name="input_enable_flow_logs"></a> [enable\_flow\_logs](#input\_enable\_flow\_logs) | Enable VPC Flow Logs for network monitoring and security auditing. | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Assign an Amazon-provided IPv6 CIDR block to the VPC. | `bool` | `false` | no |
| <a name="input_enable_network_address_usage_metrics"></a> [enable\_network\_address\_usage\_metrics](#input\_enable\_network\_address\_usage\_metrics) | Enable network address usage metrics for the VPC. | `bool` | `false` | no |
| <a name="input_flow_logs_destination_arn"></a> [flow\_logs\_destination\_arn](#input\_flow\_logs\_destination\_arn) | ARN of the destination for VPC Flow Logs (CloudWatch Log Group or S3 bucket). Required if enable\_flow\_logs is true. | `string` | `null` | no |
| <a name="input_flow_logs_iam_role_arn"></a> [flow\_logs\_iam\_role\_arn](#input\_flow\_logs\_iam\_role\_arn) | IAM role ARN for VPC Flow Logs. Required if enable\_flow\_logs is true. | `string` | `null` | no |
| <a name="input_flow_logs_traffic_type"></a> [flow\_logs\_traffic\_type](#input\_flow\_logs\_traffic\_type) | Type of traffic to log (ACCEPT, REJECT, ALL). | `string` | `"ALL"` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | The allowed tenancy of instances launched into the VPC. | `string` | `"default"` | no |
| <a name="input_manage_default_nacl"></a> [manage\_default\_nacl](#input\_manage\_default\_nacl) | Manage the default network ACL. | `bool` | `true` | no |
| <a name="input_manage_default_security_group"></a> [manage\_default\_security\_group](#input\_manage\_default\_security\_group) | Manage the default security group and lock it down (recommended for security). | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the VPC. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cidr_block"></a> [cidr\_block](#output\_cidr\_block) | IPv4 CIDR block of the VPC. |
| <a name="output_default_network_acl_id"></a> [default\_network\_acl\_id](#output\_default\_network\_acl\_id) | ID of the default network ACL. |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | ID of the default route table. |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | ID of the default security group. |
| <a name="output_flow_log_id"></a> [flow\_log\_id](#output\_flow\_log\_id) | ID of the VPC Flow Log (if enabled). |
| <a name="output_ipv6_association_id"></a> [ipv6\_association\_id](#output\_ipv6\_association\_id) | Association ID for the IPv6 CIDR block. |
| <a name="output_ipv6_cidr_block"></a> [ipv6\_cidr\_block](#output\_ipv6\_cidr\_block) | Amazon provided IPv6 CIDR block of the VPC. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the VPC. |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
