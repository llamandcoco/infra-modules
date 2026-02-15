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

# Test 1: Basic ActiveMQ broker with single instance
module "test_activemq_basic" {
  source = "../../"

  broker_name        = "test-activemq-broker"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18.3"
  host_instance_type = "mq.m5.large"
  deployment_mode    = "SINGLE_INSTANCE"

  # Network configuration
  subnet_ids      = ["subnet-12345678"]
  security_groups = ["sg-12345678"]

  # Users
  users = [
    {
      username       = "admin"
      password       = "AdminPassword123!"
      console_access = true
    }
  ]

  # Enable logging
  enable_general_log = true
  enable_audit_log   = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Engine      = "activemq"
  }
}

# Test 2: RabbitMQ broker with cluster deployment
module "test_rabbitmq_cluster" {
  source = "../../"

  broker_name        = "test-rabbitmq-cluster"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13.0"
  host_instance_type = "mq.m5.large"
  deployment_mode    = "CLUSTER_MULTI_AZ"

  # Network configuration (3 subnets for cluster)
  subnet_ids      = ["subnet-12345678", "subnet-23456789", "subnet-34567890"]
  security_groups = ["sg-12345678"]

  # Users
  users = [
    {
      username = "admin"
      password = "AdminPassword123!"
    }
  ]

  # Enable logging
  enable_general_log = true

  # Maintenance window
  maintenance_day_of_week = "SUNDAY"
  maintenance_time_of_day = "03:00"
  maintenance_time_zone   = "UTC"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Engine      = "rabbitmq"
    Mode        = "cluster"
  }
}

# Test 3: ActiveMQ broker with high availability (Active/Standby)
module "test_activemq_ha" {
  source = "../../"

  broker_name        = "test-activemq-ha"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18.3"
  host_instance_type = "mq.m5.xlarge"
  deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"

  # Network configuration (2 subnets for HA)
  subnet_ids      = ["subnet-12345678", "subnet-23456789"]
  security_groups = ["sg-12345678"]

  # Users
  users = [
    {
      username       = "admin"
      password       = "AdminPassword123!"
      console_access = true
    }
  ]

  # Storage configuration
  storage_type = "EFS"

  # KMS encryption (simulated ARN for mock testing)
  kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Enable logging
  enable_general_log = true
  enable_audit_log   = true

  # Auto upgrades
  auto_minor_version_upgrade = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Engine      = "activemq"
    Mode        = "ha"
  }
}

# Test 4: RabbitMQ broker with custom configuration
module "test_rabbitmq_with_config" {
  source = "../../"

  broker_name        = "test-rabbitmq-config"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13.0"
  host_instance_type = "mq.m5.large"
  deployment_mode    = "SINGLE_INSTANCE"

  # Network configuration
  subnet_ids      = ["subnet-12345678"]
  security_groups = ["sg-12345678"]

  # Users
  users = [
    {
      username = "admin"
      password = "AdminPassword123!"
    }
  ]

  # Create custom configuration
  create_configuration      = true
  configuration_description = "Custom RabbitMQ configuration for testing"
  configuration_data        = <<-EOT
    # Sample RabbitMQ configuration
    loopback_users.guest = false
    listeners.tcp.default = 5672
    management.tcp.port = 15672
  EOT

  # Publicly accessible for testing (not recommended for production)
  publicly_accessible = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Engine      = "rabbitmq"
    Feature     = "custom-config"
  }
}

# Test 5: Minimal ActiveMQ broker
module "test_activemq_minimal" {
  source = "../../"

  broker_name        = "test-activemq-minimal"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18.3"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  # Network configuration
  subnet_ids      = ["subnet-12345678"]
  security_groups = ["sg-12345678"]

  # Single user
  users = [
    {
      username = "admin"
      password = "AdminPassword123!"
    }
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Outputs for verification
output "activemq_basic_broker_id" {
  description = "ID of the basic ActiveMQ broker"
  value       = module.test_activemq_basic.broker_id
}

output "activemq_basic_broker_arn" {
  description = "ARN of the basic ActiveMQ broker"
  value       = module.test_activemq_basic.broker_arn
}

output "activemq_basic_console_url" {
  description = "Console URL of the basic ActiveMQ broker"
  value       = module.test_activemq_basic.console_url
}

output "rabbitmq_cluster_broker_id" {
  description = "ID of the RabbitMQ cluster broker"
  value       = module.test_rabbitmq_cluster.broker_id
}

output "rabbitmq_cluster_deployment_mode" {
  description = "Deployment mode of the RabbitMQ cluster"
  value       = module.test_rabbitmq_cluster.deployment_mode
}

output "activemq_ha_broker_arn" {
  description = "ARN of the HA ActiveMQ broker"
  value       = module.test_activemq_ha.broker_arn
}

output "activemq_ha_storage_type" {
  description = "Storage type of the HA ActiveMQ broker"
  value       = module.test_activemq_ha.storage_type
}

output "activemq_ha_kms_enabled" {
  description = "Whether the HA broker uses AWS-owned encryption"
  value       = module.test_activemq_ha.encryption_use_aws_owned_key
}

output "rabbitmq_config_configuration_id" {
  description = "Configuration ID for the RabbitMQ broker with custom config"
  value       = module.test_rabbitmq_with_config.configuration_id
}

output "rabbitmq_config_publicly_accessible" {
  description = "Whether the RabbitMQ config broker is publicly accessible"
  value       = module.test_rabbitmq_with_config.publicly_accessible
}

output "activemq_minimal_broker_name" {
  description = "Name of the minimal ActiveMQ broker"
  value       = module.test_activemq_minimal.broker_name
}

output "activemq_minimal_instance_type" {
  description = "Instance type of the minimal ActiveMQ broker"
  value       = module.test_activemq_minimal.host_instance_type
}
