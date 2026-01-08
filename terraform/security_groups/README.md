# security_groups

Create any number of security groups with cross-references in a single stack. Pass a map of groups; rules can point at other groups by `source_sg_key` or set `self = true`.

## Usage

```hcl
module "security_groups" {
  source = "github.com/llamandcoco/infra-modules//terraform/security_groups?ref=<sha>"

  vpc_id = "vpc-12345678"

  security_groups = {
    control = {
      name        = "laco-k8s-control-plane-sg"
      description = "K8s control plane"
      ingress_rules = [
        {
          description = "API"
          from_port   = 6443
          to_port     = 6443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description  = "kubelet from workers"
          from_port    = 10250
          to_port      = 10250
          protocol     = "tcp"
          source_sg_key = "worker"
        }
      ]
    }

    worker = {
      name        = "laco-k8s-worker-sg"
      description = "K8s workers"
      ingress_rules = [
        {
          description   = "kubelet from control"
          from_port     = 10250
          to_port       = 10250
          protocol      = "tcp"
          source_sg_key = "control"
        },
        {
          description = "nodeport"
          from_port   = 30000
          to_port     = 32767
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}
```

## Inputs

- `vpc_id` (string, required): VPC ID.
- `security_groups` (map(object), required): Map of groups keyed by any string.
  - `name` (string): Security group name.
  - `description` (string, default `"Managed security group"`).
  - `tags` (map(string), default `{}`): Extra tags; `Name` is auto-added.
  - `ingress_rules` (list(object), default `[]`): Ingress rules.
    - `description` (string, optional)
    - `from_port`/`to_port` (number)
    - `protocol` (string)
    - `cidr_blocks`/`ipv6_cidr_blocks`/`prefix_list_ids` (list(string), optional)
    - `source_sg_key` (string, optional): Key of another SG in the map.
    - `self` (bool, optional): Whether the group can talk to itself.
  - `egress_rules` (list(object), default `[]`): Same shape as ingress. No egress is created unless you define rules explicitly.

## Outputs

- `security_group_ids`: Map of SG IDs keyed by `security_groups` keys.

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
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
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of security groups to create keyed by an arbitrary name | <pre>map(object({<br/>    name        = string<br/>    description = optional(string, "Managed security group")<br/>    tags        = optional(map(string), {})<br/><br/>    ingress_rules = optional(list(object({<br/>      description      = optional(string)<br/>      from_port        = number<br/>      to_port          = number<br/>      protocol         = string<br/>      cidr_blocks      = optional(list(string))<br/>      ipv6_cidr_blocks = optional(list(string))<br/>      prefix_list_ids  = optional(list(string))<br/>      source_sg_key    = optional(string)<br/>      self             = optional(bool)<br/>    })), [])<br/><br/>    egress_rules = optional(list(object({<br/>      description      = optional(string)<br/>      from_port        = number<br/>      to_port          = number<br/>      protocol         = string<br/>      cidr_blocks      = optional(list(string))<br/>      ipv6_cidr_blocks = optional(list(string))<br/>      prefix_list_ids  = optional(list(string))<br/>      source_sg_key    = optional(string)<br/>      self             = optional(bool)<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where security groups will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Map of security group IDs keyed by the provided security\_groups map keys |
<!-- END_TF_DOCS -->
