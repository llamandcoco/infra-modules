terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# RDS Option Group
# Manages an RDS DB option group for database engine-specific features
# Options vary by engine (e.g., Oracle NATIVE_NETWORK_ENCRYPTION, MySQL MEMCACHED)
resource "aws_db_option_group" "this" {
  name                     = var.name
  option_group_description = coalesce(var.description, "Option group for ${var.engine_name} ${var.major_engine_version}")
  engine_name              = var.engine_name
  major_engine_version     = var.major_engine_version

  # Dynamic block for options
  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = try(option.value.port, null)
      version                        = try(option.value.version, null)
      vpc_security_group_memberships = try(option.value.vpc_security_group_memberships, null)
      db_security_group_memberships  = try(option.value.db_security_group_memberships, null)

      # Dynamic block for option settings
      dynamic "option_settings" {
        for_each = try(option.value.option_settings, [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
