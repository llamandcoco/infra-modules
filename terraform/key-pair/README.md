# Key Pair Terraform Module

## Features

- Key Generation Create new SSH key pairs (RSA, ECDSA, or ED25519)
- Key Import Support for importing existing public keys
- Local File Management Automatic saving of keys to local filesystem with proper permissions
- Flexible Configuration Multiple algorithms, key sizes, and storage options
- Security Best Practices Encrypted state storage, secure key handling

## Quick Start

```hcl
module "key_pair" {
  source = "github.com/llamandcoco/infra-modules//terraform/key-pair?ref=<commit-sha>"

  key_name = "my-ec2-key"
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

## Security Considerations

⚠️ **Important**: When generating keys with this module:

1. **Private keys are stored in Terraform state** - Ensure your state backend is secure and encrypted
2. **Use remote state backends** (S3, Terraform Cloud) with encryption enabled
3. **Limit state access** to only authorized users/systems
4. **Consider using existing keys** for production environments instead of generating new ones

### Best Practices

- For production: Import existing keys rather than generating new ones
- Use strong algorithms (ED25519 or RSA 4096)
- Store private keys securely (password managers, vaults)
- Rotate keys regularly
- Use different keys for different environments

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_algorithm"></a> [algorithm](#input\_algorithm) | Algorithm to use for generating SSH keys when public\_key is not provided.<br/>Valid values: RSA, ECDSA, ED25519 | `string` | `"RSA"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of the SSH key pair to create in AWS. | `string` | n/a | yes |
| <a name="input_private_key_filename"></a> [private\_key\_filename](#input\_private\_key\_filename) | Path where the private key file should be saved.<br/>If not specified, will use '<key\_name>.pem' in the current directory. | `string` | `null` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | SSH public key material to use for the key pair. If not provided, a new key pair will be generated.<br/>Should be in OpenSSH format (starts with 'ssh-rsa', 'ssh-ed25519', etc.). | `string` | `null` | no |
| <a name="input_public_key_filename"></a> [public\_key\_filename](#input\_public\_key\_filename) | Path where the public key file should be saved.<br/>If not specified, will use '<key\_name>.pub' in the current directory. | `string` | `null` | no |
| <a name="input_rsa_bits"></a> [rsa\_bits](#input\_rsa\_bits) | Number of bits for RSA key. Only used when algorithm is RSA and public\_key is not provided. | `number` | `4096` | no |
| <a name="input_save_private_key"></a> [save\_private\_key](#input\_save\_private\_key) | Whether to save the generated private key to a local file.<br/>Only applies when public\_key is not provided (key is generated).<br/>WARNING: Private keys will be stored in Terraform state! | `bool` | `true` | no |
| <a name="input_save_public_key"></a> [save\_public\_key](#input\_save\_public\_key) | Whether to save the generated public key to a local file.<br/>Only applies when public\_key is not provided (key is generated). | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the key pair resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | The key pair name |
| <a name="output_key_pair_arn"></a> [key\_pair\_arn](#output\_key\_pair\_arn) | The key pair ARN |
| <a name="output_key_pair_fingerprint"></a> [key\_pair\_fingerprint](#output\_key\_pair\_fingerprint) | The MD5 public key fingerprint as specified in section 4 of RFC 4716 |
| <a name="output_key_pair_id"></a> [key\_pair\_id](#output\_key\_pair\_id) | The key pair ID |
| <a name="output_private_key_filename"></a> [private\_key\_filename](#output\_private\_key\_filename) | Path to the saved private key file (if save\_private\_key is true) |
| <a name="output_private_key_openssh"></a> [private\_key\_openssh](#output\_private\_key\_openssh) | Private key data in OpenSSH format. WARNING: Sensitive value, only available when key is generated. |
| <a name="output_private_key_pem"></a> [private\_key\_pem](#output\_private\_key\_pem) | Private key data in PEM format. WARNING: Sensitive value, only available when key is generated. |
| <a name="output_public_key_filename"></a> [public\_key\_filename](#output\_public\_key\_filename) | Path to the saved public key file (if save\_public\_key is true) |
| <a name="output_public_key_openssh"></a> [public\_key\_openssh](#output\_public\_key\_openssh) | The public key data in OpenSSH authorized\_keys format |
| <a name="output_public_key_pem"></a> [public\_key\_pem](#output\_public\_key\_pem) | Public key data in PEM format. Only available when key is generated. |
<!-- END_TF_DOCS -->
</details>
