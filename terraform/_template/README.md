# Module Name

Brief description of what this module does.

## Usage

```hcl
module "example" {
  source = "github.com/your-org/infra-modules//terraform/module-name?ref=v1.0.0"

  resource_name = "my-resource"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_name | Name of the resource | `string` | n/a | yes |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_id | The ID of the created resource |
| resource_arn | The ARN of the created resource |

## Examples

### Basic Example

```hcl
module "basic_example" {
  source = "../../"

  resource_name = "example-resource"
}
```

### Advanced Example

```hcl
module "advanced_example" {
  source = "../../"

  resource_name = "example-resource"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Testing

To test this module locally:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

## Notes

Add any important notes, caveats, or known limitations here.
