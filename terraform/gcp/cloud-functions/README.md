# GCP Cloud Functions (2nd Gen) Terraform Module

## Features

- Security First Private by default with explicit IAM controls
- Serverless Architecture Auto-scaling with configurable limits
- Secret Management Native integration with Google Secret Manager
- VPC Connectivity Optional private network access via VPC connectors
- Source Management Automated Cloud Storage bucket for function code
- Service Account Automatic creation with least privilege access
- Production Ready Follows Google Cloud best practices
- Fully Tested Includes test configurations and security scanning

## Quick Start

```hcl
module "cloud-functions" {
  source = "github.com/llamandcoco/infra-modules//terraform/gcp/cloud-functions?ref=<commit-sha>"

  # Add required variables here
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

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloudfunctions2_function.function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_cloudfunctions2_function_iam_member.invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function_iam_member) | resource |
| [google_cloudfunctions2_function_iam_member.public_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function_iam_member) | resource |
| [google_service_account.function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.function_source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_all_traffic_on_latest_revision"></a> [all\_traffic\_on\_latest\_revision](#input\_all\_traffic\_on\_latest\_revision) | Whether to route all traffic to the latest revision. Set to false for gradual rollouts. | `bool` | `true` | no |
| <a name="input_allow_unauthenticated_invocations"></a> [allow\_unauthenticated\_invocations](#input\_allow\_unauthenticated\_invocations) | Allow unauthenticated invocations of the function. Set to true for public APIs. Use with caution. | `bool` | `false` | no |
| <a name="input_available_cpu"></a> [available\_cpu](#input\_available\_cpu) | The number of CPUs available for the function. If not specified, defaults based on memory. | `string` | `null` | no |
| <a name="input_available_memory"></a> [available\_memory](#input\_available\_memory) | Memory available for the function in MB. Must be one of: 128M, 256M, 512M, 1G, 2G, 4G, 8G, 16G, or 32G. | `string` | `"256M"` | no |
| <a name="input_build_environment_variables"></a> [build\_environment\_variables](#input\_build\_environment\_variables) | Environment variables available during the build process. | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Cloud Function. Helps document the function's purpose. | `string` | `null` | no |
| <a name="input_docker_repository"></a> [docker\_repository](#input\_docker\_repository) | Docker repository for the function's container image (format: projects/PROJECT\_ID/locations/REGION/repositories/REPO\_NAME). | `string` | `null` | no |
| <a name="input_entry_point"></a> [entry\_point](#input\_entry\_point) | The name of the function (as defined in source code) that will be executed. For HTTP functions, this is the function that handles requests. | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables to set for the function runtime. Use for non-sensitive configuration. | `map(string)` | `{}` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow deletion of the source bucket even when it contains objects. Use with caution in production. | `bool` | `false` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Cloud Function. Must be unique within the project and region. | `string` | n/a | yes |
| <a name="input_ingress_settings"></a> [ingress\_settings](#input\_ingress\_settings) | Ingress settings for the function. Controls which traffic can reach the function. | `string` | `"ALLOW_ALL"` | no |
| <a name="input_invoker_members"></a> [invoker\_members](#input\_invoker\_members) | List of IAM members that can invoke the function (e.g., ['user:admin@example.com', 'serviceAccount:sa@project.iam.gserviceaccount.com']). | `list(string)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to add to all resources. Use for organizing and tracking resources. | `map(string)` | `{}` | no |
| <a name="input_max_instance_count"></a> [max\_instance\_count](#input\_max\_instance\_count) | Maximum number of function instances that can run in parallel. Use to control costs and resource usage. | `number` | `100` | no |
| <a name="input_max_instance_request_concurrency"></a> [max\_instance\_request\_concurrency](#input\_max\_instance\_request\_concurrency) | Maximum number of concurrent requests each instance can handle. Default is 1 for most runtimes. | `number` | `1` | no |
| <a name="input_min_instance_count"></a> [min\_instance\_count](#input\_min\_instance\_count) | Minimum number of function instances to keep warm. Setting this > 0 reduces cold starts but increases costs. | `number` | `0` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where the Cloud Function will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region where the Cloud Function will be deployed. | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime environment for the Cloud Function (e.g., 'python311', 'nodejs20', 'go121'). | `string` | n/a | yes |
| <a name="input_secret_environment_variables"></a> [secret\_environment\_variables](#input\_secret\_environment\_variables) | Secret environment variables from Secret Manager. Each entry should have:<br/>- key: Environment variable name<br/>- project\_id: GCP project ID containing the secret<br/>- secret: Secret name in Secret Manager<br/>- version: Secret version (e.g., 'latest', '1', '2') | <pre>list(object({<br/>    key        = string<br/>    project_id = string<br/>    secret     = string<br/>    version    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_secret_volumes"></a> [secret\_volumes](#input\_secret\_volumes) | Mount secrets as volumes. Each entry should have:<br/>- mount\_path: Path where the secret will be mounted<br/>- project\_id: GCP project ID containing the secret<br/>- secret: Secret name in Secret Manager<br/>- versions: List of versions to mount with their paths | <pre>list(object({<br/>    mount_path = string<br/>    project_id = string<br/>    secret     = string<br/>    versions = list(object({<br/>      version = string<br/>      path    = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Service account email to use for the function. If not specified, a new service account will be created. | `string` | `null` | no |
| <a name="input_source_archive_object"></a> [source\_archive\_object](#input\_source\_archive\_object) | The name of the source archive object in the Cloud Storage bucket (e.g., 'function-source.zip'). | `string` | n/a | yes |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | Maximum amount of time the function can run before timing out (in seconds). Maximum is 3600s (60 minutes). | `number` | `60` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning on the source code bucket to maintain history of function deployments. | `bool` | `true` | no |
| <a name="input_vpc_connector"></a> [vpc\_connector](#input\_vpc\_connector) | VPC Connector to use for private network access (format: projects/PROJECT\_ID/locations/REGION/connectors/CONNECTOR\_NAME). | `string` | `null` | no |
| <a name="input_vpc_connector_egress_settings"></a> [vpc\_connector\_egress\_settings](#input\_vpc\_connector\_egress\_settings) | VPC egress settings. Controls which traffic routes through the VPC connector. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allow_unauthenticated"></a> [allow\_unauthenticated](#output\_allow\_unauthenticated) | Whether unauthenticated invocations are allowed. |
| <a name="output_available_memory"></a> [available\_memory](#output\_available\_memory) | The amount of memory allocated to the Cloud Function. |
| <a name="output_function_id"></a> [function\_id](#output\_function\_id) | The unique identifier of the Cloud Function. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Cloud Function. |
| <a name="output_function_uri"></a> [function\_uri](#output\_function\_uri) | The URI of the Cloud Function. Use this to invoke the function via HTTP. |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | The URL of the Cloud Function (alias for function\_uri for convenience). |
| <a name="output_ingress_settings"></a> [ingress\_settings](#output\_ingress\_settings) | The ingress settings configured for the Cloud Function. |
| <a name="output_labels"></a> [labels](#output\_labels) | All labels applied to the Cloud Function. |
| <a name="output_max_instance_count"></a> [max\_instance\_count](#output\_max\_instance\_count) | The maximum number of function instances configured. |
| <a name="output_min_instance_count"></a> [min\_instance\_count](#output\_min\_instance\_count) | The minimum number of function instances configured. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The GCP project ID where the Cloud Function is deployed. |
| <a name="output_region"></a> [region](#output\_region) | The GCP region where the Cloud Function is deployed. |
| <a name="output_runtime"></a> [runtime](#output\_runtime) | The runtime environment of the Cloud Function. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | The email address of the service account used by the Cloud Function. |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | The unique ID of the created service account, if one was created by this module. |
| <a name="output_source_bucket_name"></a> [source\_bucket\_name](#output\_source\_bucket\_name) | The name of the Cloud Storage bucket containing the function source code. |
| <a name="output_source_bucket_url"></a> [source\_bucket\_url](#output\_source\_bucket\_url) | The URL of the Cloud Storage bucket containing the function source code. |
| <a name="output_state"></a> [state](#output\_state) | The current state of the Cloud Function. |
| <a name="output_timeout_seconds"></a> [timeout\_seconds](#output\_timeout\_seconds) | The timeout setting of the Cloud Function in seconds. |
<!-- END_TF_DOCS -->
</details>
