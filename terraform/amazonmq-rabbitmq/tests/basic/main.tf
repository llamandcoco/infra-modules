terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# Test 1: Basic RabbitMQ configuration with default memory settings
module "test_basic_config" {
  source = "../../"

  configuration_name = "test-rabbitmq-basic-config"
  engine_version     = "3.13"
  description        = "Basic RabbitMQ configuration for testing"

  # Basic configuration with memory and disk settings
  configuration_data = base64encode(<<-EOT
    [
      {rabbit, [
        {vm_memory_high_watermark, 0.4},
        {disk_free_limit, {mem_relative, 1.0}}
      ]}
    ].
  EOT
  )

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    ConfigType  = "basic"
  }
}

# Test 2: Advanced configuration with queue settings and logging
module "test_advanced_config" {
  source = "../../"

  configuration_name = "test-rabbitmq-advanced-config"
  engine_version     = "3.12"
  description        = "Advanced RabbitMQ configuration with custom queue and logging settings"

  # Advanced configuration with queue policies and logging
  configuration_data = base64encode(<<-EOT
    [
      {rabbit, [
        {vm_memory_high_watermark, 0.5},
        {disk_free_limit, {mem_relative, 1.5}},
        {default_vhost, <<"/">>},
        {default_user, <<"admin">>},
        {default_permissions, [<<".*">>, <<".*">>, <<".*">>]},
        {log, [
          {file, [{level, info}]},
          {console, [{level, info}]}
        ]}
      ]}
    ].
  EOT
  )

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    ConfigType  = "advanced"
  }
}

# Test 3: Production-ready configuration with optimized settings
module "test_production_config" {
  source = "../../"

  configuration_name = "test-rabbitmq-production-config"
  engine_version     = "3.13"
  description        = "Production-optimized RabbitMQ configuration"

  # Production configuration with connection limits and heartbeat settings
  configuration_data = base64encode(<<-EOT
    [
      {rabbit, [
        {vm_memory_high_watermark, 0.6},
        {disk_free_limit, {mem_relative, 2.0}},
        {heartbeat, 60},
        {channel_max, 2048},
        {log, [
          {file, [{level, warning}]},
          {console, [{level, error}]}
        ]}
      ]}
    ].
  EOT
  )

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    ConfigType  = "production"
    Compliance  = "soc2"
  }
}

# Test 4: Legacy version configuration
module "test_legacy_version_config" {
  source = "../../"

  configuration_name = "test-rabbitmq-legacy-config"
  engine_version     = "3.8"
  description        = "RabbitMQ configuration for legacy version 3.8"

  # Minimal configuration for legacy version
  configuration_data = base64encode(<<-EOT
    [
      {rabbit, [
        {vm_memory_high_watermark, 0.4},
        {disk_free_limit, 1000000000}
      ]}
    ].
  EOT
  )

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Version     = "legacy"
  }
}

# Outputs for verification
output "basic_config_id" {
  description = "ID of the basic configuration"
  value       = module.test_basic_config.configuration_id
}

output "basic_config_arn" {
  description = "ARN of the basic configuration"
  value       = module.test_basic_config.configuration_arn
}

output "basic_config_latest_revision" {
  description = "Latest revision of the basic configuration"
  value       = module.test_basic_config.latest_revision
}

output "advanced_config_id" {
  description = "ID of the advanced configuration"
  value       = module.test_advanced_config.configuration_id
}

output "advanced_config_engine_version" {
  description = "Engine version of the advanced configuration"
  value       = module.test_advanced_config.engine_version
}

output "production_config_name" {
  description = "Name of the production configuration"
  value       = module.test_production_config.configuration_name
}

output "production_config_tags" {
  description = "Tags applied to the production configuration"
  value       = module.test_production_config.tags
}

output "legacy_config_engine_version" {
  description = "Engine version of the legacy configuration"
  value       = module.test_legacy_version_config.engine_version
}
