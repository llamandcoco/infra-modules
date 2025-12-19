terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# Mock Google provider for testing without credentials
# Using obviously fake credentials for testing purposes only
provider "google" {
  project = "test-project-12345"
  region  = "us-central1"
  credentials = jsonencode({
    type           = "service_account"
    project_id     = "FAKE_TEST_PROJECT"
    private_key_id = "FAKE_KEY_ID_FOR_TESTING"
    # Avoid real/marker private key to satisfy pre-commit detect-private-key
    private_key                 = "FAKE_PRIVATE_KEY_FOR_TESTING_ONLY"
    client_email                = "fake-test-sa@fake-test-project.iam.gserviceaccount.com"
    client_id                   = "000000000000000000000"
    auth_uri                    = "https://accounts.google.com/o/oauth2/auth"
    token_uri                   = "https://oauth2.googleapis.com/token"
    auth_provider_x509_cert_url = "https://www.googleapis.com/oauth2/v1/certs"
  })
  user_project_override = true
}

# -----------------------------------------------------------------------------
# Test 1: Basic HTTP Cloud Function with Python
# -----------------------------------------------------------------------------

module "basic_python_function" {
  source = "../../"

  function_name         = "test-python-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "python311"
  entry_point           = "handle_request"
  source_archive_object = "function-source.zip"
  description           = "Basic Python HTTP function for testing"

  labels = {
    environment = "test"
    managed-by  = "terraform"
    purpose     = "basic-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: Node.js Function with Environment Variables
# -----------------------------------------------------------------------------

module "nodejs_function_with_env" {
  source = "../../"

  function_name         = "test-nodejs-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "nodejs20"
  entry_point           = "handleRequest"
  source_archive_object = "nodejs-function.zip"
  description           = "Node.js function with environment variables"

  available_memory = "512M"
  timeout_seconds  = 120

  environment_variables = {
    NODE_ENV    = "production"
    LOG_LEVEL   = "info"
    API_VERSION = "v2"
  }

  labels = {
    environment = "test"
    runtime     = "nodejs"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Go Function with Scaling Configuration
# -----------------------------------------------------------------------------

module "go_function_with_scaling" {
  source = "../../"

  function_name         = "test-go-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "go121"
  entry_point           = "HandleRequest"
  source_archive_object = "go-function.zip"
  description           = "Go function with custom scaling"

  available_memory                 = "1G"
  available_cpu                    = "1"
  timeout_seconds                  = 300
  max_instance_count               = 50
  min_instance_count               = 2
  max_instance_request_concurrency = 10

  labels = {
    environment = "test"
    runtime     = "go"
    performance = "optimized"
  }
}

# -----------------------------------------------------------------------------
# Test 4: Function with Secret Manager Integration
# -----------------------------------------------------------------------------

module "function_with_secrets" {
  source = "../../"

  function_name         = "test-secure-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "python311"
  entry_point           = "process_secure_data"
  source_archive_object = "secure-function.zip"
  description           = "Function with Secret Manager integration"

  secret_environment_variables = [
    {
      key        = "DATABASE_PASSWORD"
      project_id = "test-project-12345"
      secret     = "db-password"
      version    = "latest"
    },
    {
      key        = "API_KEY"
      project_id = "test-project-12345"
      secret     = "api-key"
      version    = "1"
    }
  ]

  secret_volumes = [
    {
      mount_path = "/etc/secrets"
      project_id = "test-project-12345"
      secret     = "service-credentials"
      versions = [
        {
          version = "latest"
          path    = "credentials.json"
        }
      ]
    }
  ]

  labels = {
    environment = "test"
    security    = "high"
  }
}

# -----------------------------------------------------------------------------
# Test 5: Private Function with VPC and Restricted Access
# -----------------------------------------------------------------------------

module "private_function" {
  source = "../../"

  function_name         = "test-private-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "java21"
  entry_point           = "com.example.Handler"
  source_archive_object = "java-function.jar"
  description           = "Private function with VPC connectivity"

  ingress_settings               = "ALLOW_INTERNAL_ONLY"
  vpc_connector                  = "projects/test-project-12345/locations/us-central1/connectors/test-connector"
  vpc_connector_egress_settings  = "PRIVATE_RANGES_ONLY"
  all_traffic_on_latest_revision = true

  # Custom service account
  service_account_email = "test-sa@test-project-12345.iam.gserviceaccount.com"

  # Specific invokers only
  invoker_members = [
    "serviceAccount:backend@test-project-12345.iam.gserviceaccount.com",
    "user:admin@example.com"
  ]

  labels = {
    environment = "test"
    network     = "private"
    access      = "restricted"
  }
}

# -----------------------------------------------------------------------------
# Test 6: Public Function (unauthenticated access)
# -----------------------------------------------------------------------------

module "public_function" {
  source = "../../"

  function_name         = "test-public-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "nodejs20"
  entry_point           = "publicWebhook"
  source_archive_object = "webhook.zip"
  description           = "Public webhook endpoint"

  allow_unauthenticated_invocations = true

  labels = {
    environment = "test"
    access      = "public"
  }
}

# -----------------------------------------------------------------------------
# Test 7: Function with Build Environment Variables
# -----------------------------------------------------------------------------

module "function_with_build_env" {
  source = "../../"

  function_name         = "test-build-env-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "python312"
  entry_point           = "main"
  source_archive_object = "custom-build.zip"
  description           = "Function with custom build configuration"

  build_environment_variables = {
    GOOGLE_BUILDABLE       = "custom_builder"
    GOOGLE_RUNTIME_VERSION = "3.12"
  }

  environment_variables = {
    APP_MODE = "production"
  }

  labels = {
    environment = "test"
    build       = "custom"
  }
}

# -----------------------------------------------------------------------------
# Test 8: Function with No Versioning and Force Destroy
# -----------------------------------------------------------------------------

module "temp_function" {
  source = "../../"

  function_name         = "test-temp-function"
  project_id            = "test-project-12345"
  region                = "us-central1"
  runtime               = "ruby33"
  entry_point           = "handler"
  source_archive_object = "ruby-function.zip"
  description           = "Temporary function for development"

  versioning_enabled = false
  force_destroy      = true

  labels = {
    environment = "development"
    temporary   = "true"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_function_url" {
  description = "URL of the basic Python function"
  value       = module.basic_python_function.function_url
}

output "basic_function_id" {
  description = "ID of the basic Python function"
  value       = module.basic_python_function.function_id
}

output "nodejs_function_service_account" {
  description = "Service account of the Node.js function"
  value       = module.nodejs_function_with_env.service_account_email
}

output "go_function_max_instances" {
  description = "Maximum instances configured for Go function"
  value       = module.go_function_with_scaling.max_instance_count
}

output "secure_function_bucket" {
  description = "Source bucket for secure function"
  value       = module.function_with_secrets.source_bucket_name
}

output "private_function_ingress" {
  description = "Ingress settings for private function"
  value       = module.private_function.ingress_settings
}

output "public_function_allow_unauth" {
  description = "Whether public function allows unauthenticated access"
  value       = module.public_function.allow_unauthenticated
}

output "temp_function_state" {
  description = "State of temporary function"
  value       = module.temp_function.state
}
