terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Mock Google provider for testing without credentials
provider "google" {
  project                     = "test-project-12345"
  region                      = "us-central1"
  credentials                 = "test"
  access_token                = "test"
  skip_credentials_validation = true
}

# -----------------------------------------------------------------------------
# Test 1: Basic GCS bucket with default security settings
# -----------------------------------------------------------------------------

module "basic_bucket" {
  source = "../../"

  bucket_name = "test-basic-bucket-12345"
  location    = "us-central1"

  labels = {
    environment = "test"
    managed_by  = "terraform"
    purpose     = "basic-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: GCS bucket with CMEK encryption
# -----------------------------------------------------------------------------

module "cmek_encrypted_bucket" {
  source = "../../"

  bucket_name = "test-cmek-bucket-12345"
  location    = "us-central1"

  # Use mock KMS key resource name for testing
  encryption_key_name = "projects/test-project/locations/us-central1/keyRings/test-keyring/cryptoKeys/test-key"

  labels = {
    environment = "test"
    managed_by  = "terraform"
    purpose     = "cmek-encryption-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: GCS bucket with lifecycle rules
# -----------------------------------------------------------------------------

module "lifecycle_bucket" {
  source = "../../"

  bucket_name = "test-lifecycle-bucket-12345"
  location    = "us"  # Multi-region

  lifecycle_rules = [
    {
      action_type          = "SetStorageClass"
      action_storage_class = "NEARLINE"
      age                  = 30
      matches_prefix       = ["logs/"]
      with_state          = "LIVE"
    },
    {
      action_type          = "SetStorageClass"
      action_storage_class = "COLDLINE"
      age                  = 90
      matches_prefix       = ["logs/"]
      with_state          = "LIVE"
    },
    {
      action_type          = "SetStorageClass"
      action_storage_class = "ARCHIVE"
      age                  = 180
      matches_prefix       = ["logs/"]
      with_state          = "LIVE"
    },
    {
      action_type    = "Delete"
      age            = 365
      matches_prefix = ["logs/"]
      with_state    = "LIVE"
    },
    {
      action_type    = "Delete"
      age            = 7
      matches_prefix = ["temp/"]
    },
    {
      action_type        = "Delete"
      num_newer_versions = 3
      with_state        = "ARCHIVED"
    },
    {
      action_type = "AbortIncompleteMultipartUpload"
      age         = 7
    }
  ]

  labels = {
    environment = "test"
    managed_by  = "terraform"
    purpose     = "lifecycle-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: GCS bucket with versioning disabled
# -----------------------------------------------------------------------------

module "no_versioning_bucket" {
  source = "../../"

  bucket_name        = "test-no-version-bucket-12345"
  location           = "us-central1"
  versioning_enabled = false

  labels = {
    environment = "test"
    managed_by  = "terraform"
    purpose     = "no-versioning-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 5: Multi-region bucket with different storage class
# -----------------------------------------------------------------------------

module "multiregion_bucket" {
  source = "../../"

  bucket_name   = "test-multiregion-bucket-12345"
  location      = "EU"  # Multi-region
  storage_class = "STANDARD"

  labels = {
    environment = "test"
    managed_by  = "terraform"
    purpose     = "multiregion-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_bucket_name" {
  description = "Name of the basic test bucket"
  value       = module.basic_bucket.bucket_name
}

output "basic_bucket_url" {
  description = "URL of the basic test bucket"
  value       = module.basic_bucket.bucket_url
}

output "cmek_bucket_encryption" {
  description = "Encryption key used for CMEK bucket"
  value       = module.cmek_encrypted_bucket.encryption_key_name
}

output "lifecycle_bucket_name" {
  description = "Name of the lifecycle test bucket"
  value       = module.lifecycle_bucket.bucket_name
}

output "no_versioning_bucket_versioning_enabled" {
  description = "Versioning status of the no-versioning test bucket"
  value       = module.no_versioning_bucket.versioning_enabled
}

output "multiregion_bucket_location" {
  description = "Location of the multi-region test bucket"
  value       = module.multiregion_bucket.bucket_location
}
