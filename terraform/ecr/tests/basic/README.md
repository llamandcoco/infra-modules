# ECR Module - Basic Tests

This directory contains basic tests for the ECR module.

## Test Cases

1. **Basic Repository**: Default configuration with encryption and scanning
2. **KMS Encrypted Repository**: Custom KMS key for encryption
3. **Lifecycle Policy**: Image retention and cleanup rules
4. **Repository Policy**: Cross-account access and CI/CD permissions
5. **Mutable Repository**: Development workflow with mutable tags
6. **Comprehensive**: All features combined

## Running Tests

```bash
# Initialize terraform
terraform init -backend=false

# Run plan to validate configuration
terraform plan

# Format code
terraform fmt
```

## Expected Behavior

All tests should successfully plan without errors. No actual AWS resources will be created due to the mock provider configuration.
