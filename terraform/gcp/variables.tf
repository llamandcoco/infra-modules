# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "function_name" {
  description = "Name of the Cloud Function. Must be unique within the project and region."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.function_name))
    error_message = "Function name must start with a lowercase letter, followed by up to 61 lowercase letters, numbers, or hyphens, and cannot end with a hyphen."
  }
}

variable "project_id" {
  description = "The GCP project ID where the Cloud Function will be created."
  type        = string
}

variable "region" {
  description = "The GCP region where the Cloud Function will be deployed."
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Cloud Function (e.g., 'python311', 'nodejs20', 'go121')."
  type        = string

  validation {
    condition = contains([
      "nodejs16", "nodejs18", "nodejs20", "nodejs22",
      "python38", "python39", "python310", "python311", "python312",
      "go116", "go118", "go119", "go120", "go121", "go122",
      "java11", "java17", "java21",
      "dotnet3", "dotnet6", "dotnet8",
      "ruby30", "ruby32", "ruby33",
      "php81", "php82", "php83"
    ], var.runtime)
    error_message = "Runtime must be a valid Cloud Functions 2nd gen runtime."
  }
}

variable "entry_point" {
  description = "The name of the function (as defined in source code) that will be executed. For HTTP functions, this is the function that handles requests."
  type        = string
}

variable "source_archive_object" {
  description = "The name of the source archive object in the Cloud Storage bucket (e.g., 'function-source.zip')."
  type        = string
}

# -----------------------------------------------------------------------------
# Function Configuration Variables
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the Cloud Function. Helps document the function's purpose."
  type        = string
  default     = null
}

variable "available_memory" {
  description = "Memory available for the function in MB. Must be one of: 128M, 256M, 512M, 1G, 2G, 4G, 8G, 16G, or 32G."
  type        = string
  default     = "256M"

  validation {
    condition     = contains(["128M", "256M", "512M", "1G", "2G", "4G", "8G", "16G", "32G"], var.available_memory)
    error_message = "Memory must be one of: 128M, 256M, 512M, 1G, 2G, 4G, 8G, 16G, or 32G."
  }
}

variable "timeout_seconds" {
  description = "Maximum amount of time the function can run before timing out (in seconds). Maximum is 3600s (60 minutes)."
  type        = number
  default     = 60

  validation {
    condition     = var.timeout_seconds >= 1 && var.timeout_seconds <= 3600
    error_message = "Timeout must be between 1 and 3600 seconds."
  }
}

variable "available_cpu" {
  description = "The number of CPUs available for the function. If not specified, defaults based on memory."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Scaling Configuration Variables
# -----------------------------------------------------------------------------

variable "max_instance_count" {
  description = "Maximum number of function instances that can run in parallel. Use to control costs and resource usage."
  type        = number
  default     = 100

  validation {
    condition     = var.max_instance_count >= 1 && var.max_instance_count <= 1000
    error_message = "Max instance count must be between 1 and 1000."
  }
}

variable "min_instance_count" {
  description = "Minimum number of function instances to keep warm. Setting this > 0 reduces cold starts but increases costs."
  type        = number
  default     = 0

  validation {
    condition     = var.min_instance_count >= 0 && var.min_instance_count <= 1000
    error_message = "Min instance count must be between 0 and 1000."
  }
}

variable "max_instance_request_concurrency" {
  description = "Maximum number of concurrent requests each instance can handle. Default is 1 for most runtimes."
  type        = number
  default     = 1

  validation {
    condition     = var.max_instance_request_concurrency >= 1 && var.max_instance_request_concurrency <= 1000
    error_message = "Max instance request concurrency must be between 1 and 1000."
  }
}

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------

variable "environment_variables" {
  description = "Environment variables to set for the function runtime. Use for non-sensitive configuration."
  type        = map(string)
  default     = {}
}

variable "build_environment_variables" {
  description = "Environment variables available during the build process."
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = <<-EOT
    Secret environment variables from Secret Manager. Each entry should have:
    - key: Environment variable name
    - project_id: GCP project ID containing the secret
    - secret: Secret name in Secret Manager
    - version: Secret version (e.g., 'latest', '1', '2')
  EOT
  type = list(object({
    key        = string
    project_id = string
    secret     = string
    version    = string
  }))
  default = []
}

variable "secret_volumes" {
  description = <<-EOT
    Mount secrets as volumes. Each entry should have:
    - mount_path: Path where the secret will be mounted
    - project_id: GCP project ID containing the secret
    - secret: Secret name in Secret Manager
    - versions: List of versions to mount with their paths
  EOT
  type = list(object({
    mount_path = string
    project_id = string
    secret     = string
    versions = list(object({
      version = string
      path    = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Networking & Security Variables
# -----------------------------------------------------------------------------

variable "ingress_settings" {
  description = "Ingress settings for the function. Controls which traffic can reach the function."
  type        = string
  default     = "ALLOW_ALL"

  validation {
    condition     = contains(["ALLOW_ALL", "ALLOW_INTERNAL_ONLY", "ALLOW_INTERNAL_AND_GCLB"], var.ingress_settings)
    error_message = "Ingress settings must be one of: ALLOW_ALL, ALLOW_INTERNAL_ONLY, ALLOW_INTERNAL_AND_GCLB."
  }
}

variable "vpc_connector" {
  description = "VPC Connector to use for private network access (format: projects/PROJECT_ID/locations/REGION/connectors/CONNECTOR_NAME)."
  type        = string
  default     = null
}

variable "vpc_connector_egress_settings" {
  description = "VPC egress settings. Controls which traffic routes through the VPC connector."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_connector_egress_settings == null ? true : contains(["PRIVATE_RANGES_ONLY", "ALL_TRAFFIC"], var.vpc_connector_egress_settings)
    error_message = "VPC connector egress settings must be one of: PRIVATE_RANGES_ONLY, ALL_TRAFFIC."
  }
}

variable "service_account_email" {
  description = "Service account email to use for the function. If not specified, a new service account will be created."
  type        = string
  default     = null
}

variable "invoker_members" {
  description = "List of IAM members that can invoke the function (e.g., ['user:admin@example.com', 'serviceAccount:sa@project.iam.gserviceaccount.com'])."
  type        = list(string)
  default     = []
}

variable "allow_unauthenticated_invocations" {
  description = "Allow unauthenticated invocations of the function. Set to true for public APIs. Use with caution."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Build Configuration Variables
# -----------------------------------------------------------------------------

variable "docker_repository" {
  description = "Docker repository for the function's container image (format: projects/PROJECT_ID/locations/REGION/repositories/REPO_NAME)."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Storage & Versioning Variables
# -----------------------------------------------------------------------------

variable "versioning_enabled" {
  description = "Enable versioning on the source code bucket to maintain history of function deployments."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow deletion of the source bucket even when it contains objects. Use with caution in production."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Traffic & Deployment Variables
# -----------------------------------------------------------------------------

variable "all_traffic_on_latest_revision" {
  description = "Whether to route all traffic to the latest revision. Set to false for gradual rollouts."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "labels" {
  description = "A map of labels to add to all resources. Use for organizing and tracking resources."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.labels :
      can(regex("^[a-z0-9_-]+$", key)) && can(regex("^[a-z0-9_-]+$", value))
    ])
    error_message = "Label keys and values must contain only lowercase letters, numbers, underscores, and hyphens."
  }
}
