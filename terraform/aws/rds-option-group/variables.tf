# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the option group. Must be lowercase alphanumeric characters or hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Option group name must contain only lowercase alphanumeric characters and hyphens."
  }

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 255
    error_message = "Option group name must be between 1 and 255 characters."
  }
}

variable "engine_name" {
  description = "Database engine name (e.g., mysql, mariadb, oracle-ee, oracle-se2, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web)."
  type        = string

  validation {
    condition     = contains(["mysql", "mariadb", "oracle-ee", "oracle-ee-cdb", "oracle-se2", "oracle-se2-cdb", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"], var.engine_name)
    error_message = "Engine name must be a valid RDS option group engine: mysql, mariadb, oracle-ee, oracle-ee-cdb, oracle-se2, oracle-se2-cdb, sqlserver-ee, sqlserver-se, sqlserver-ex, or sqlserver-web."
  }
}

variable "major_engine_version" {
  description = "Major version of the database engine (e.g., 5.7 for MySQL 5.7.x, 19 for Oracle 19c)."
  type        = string
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the option group. Defaults to 'Option group for {engine_name} {major_engine_version}'."
  type        = string
  default     = null
}

variable "options" {
  description = <<-EOT
    List of options to apply to the option group. Each option can have settings, port, version, and security groups.
    
    Example:
      options = [
        {
          option_name = "MEMCACHED"
          port        = 11211
          vpc_security_group_memberships = ["sg-12345678"]
          option_settings = [
            {
              name  = "CHUNK_SIZE"
              value = "32"
            }
          ]
        }
      ]
  EOT
  type = list(object({
    option_name                    = string
    port                           = optional(number)
    version                        = optional(string)
    vpc_security_group_memberships = optional(list(string))
    db_security_group_memberships  = optional(list(string))
    option_settings = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Tagging Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Map of tags to assign to the option group. Use for resource organization, cost allocation, and governance."
  type        = map(string)
  default     = {}
}
