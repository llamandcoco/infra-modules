<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-01-31 19:05:00 | Updated: 2026-01-31 19:05:00 -->

# gcp

## Purpose

Google Cloud Platform (GCP) Terraform modules for serverless and storage infrastructure. Unlike AWS modules, these use the `hashicorp/google` provider and follow GCP-specific naming conventions, security patterns, and resource structures.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `cloud-functions/` | GCP Cloud Functions (2nd Gen) with VPC connectivity and secret management |
| `gcs/` | Google Cloud Storage buckets with encryption, versioning, and lifecycle management |

## For AI Agents

### Working In This Directory

**Key Differences from AWS Modules:**

| Aspect | AWS Pattern | GCP Pattern |
|--------|-------------|-------------|
| **Provider** | `hashicorp/aws ~> 5.0` | `hashicorp/google ~> 5.0` |
| **Resource Naming** | `aws_s3_bucket` | `google_storage_bucket` |
| **Encryption** | Explicit KMS key or AES256 | Google-managed by default, optional CMEK |
| **IAM** | Separate policy documents | `google_*_iam_member` resources |
| **Testing** | Mock AWS provider | Mock Google provider with project_id |

**GCP-Specific Security Defaults:**
- Public access prevention enforced by default
- Uniform bucket-level access (IAM-only) enabled
- Versioning enabled by default
- Google-managed encryption (or CMEK via KMS)

### Testing Requirements

**Mock Provider Configuration for GCP:**
```hcl
provider "google" {
  project                     = "test-project-id"
  region                      = "us-central1"
  access_token                = "test"
  # Credentials-less testing
}
```

**Required Variables:**
- All GCP modules require `project_id`
- Location/region parameters (e.g., `region`, `location`)
- Resource names must follow GCP conventions

### Common Patterns

**IAM Member Pattern:**
```hcl
resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:sa@project.iam.gserviceaccount.com"
}
```

**Service Account & Secret Manager:**
- Service accounts: Use `google_service_account` with `account_id`, `display_name`, and `project`
- Secrets: Reference via `secret_environment_variables` with `key`, `secret`, and `version` fields

## Dependencies

### Internal
- GCP modules are independent and do not depend on other modules in this repository
- Can be composed with AWS modules for multi-cloud deployments
- Stack modules may combine GCP and AWS resources

### External

**Required Providers:**
- `hashicorp/google` ~> 5.0 or ~> 6.0 (varies by module)
- Terraform >= 1.0

**GCP Services Required:**
- Cloud Resource Manager API (for project management)
- Service Usage API (for enabling GCP services)
- Module-specific APIs:
  - Cloud Functions: Cloud Functions API, Cloud Build API
  - GCS: Cloud Storage API

**Local Development:**
- Same tools as AWS modules (terraform, pre-commit, tflint, trivy)
- Optional: `gcloud` CLI for manual testing (not required for CI/CD)

## Multi-Cloud Considerations

When using GCP modules alongside AWS modules:
- Keep providers separate in root modules and use separate state files or workspaces per cloud
- Use cloud prefix in resource names (e.g., `gcp-function-*`, `aws-lambda-*`) and tag/label resources with cloud provider identifier
- Test each cloud's modules independently before composition

<!-- MANUAL: Add any project-specific notes below this line -->
