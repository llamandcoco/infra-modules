# basic

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_basic_bucket"></a> [basic\_bucket](#module\_basic\_bucket) | ../../ | n/a |
| <a name="module_kms_encrypted_bucket"></a> [kms\_encrypted\_bucket](#module\_kms\_encrypted\_bucket) | ../../ | n/a |
| <a name="module_lifecycle_bucket"></a> [lifecycle\_bucket](#module\_lifecycle\_bucket) | ../../ | n/a |
| <a name="module_no_versioning_bucket"></a> [no\_versioning\_bucket](#module\_no\_versioning\_bucket) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_basic_bucket_arn"></a> [basic\_bucket\_arn](#output\_basic\_bucket\_arn) | ARN of the basic test bucket |
| <a name="output_basic_bucket_id"></a> [basic\_bucket\_id](#output\_basic\_bucket\_id) | ID of the basic test bucket |
| <a name="output_kms_bucket_encryption"></a> [kms\_bucket\_encryption](#output\_kms\_bucket\_encryption) | Encryption algorithm used for KMS bucket |
| <a name="output_lifecycle_bucket_id"></a> [lifecycle\_bucket\_id](#output\_lifecycle\_bucket\_id) | ID of the lifecycle test bucket |
| <a name="output_no_versioning_bucket_versioning_enabled"></a> [no\_versioning\_bucket\_versioning\_enabled](#output\_no\_versioning\_bucket\_versioning\_enabled) | Versioning status of the no-versioning test bucket |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
