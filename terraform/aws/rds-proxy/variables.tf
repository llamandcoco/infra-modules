variable "name" {
  description = "The identifier for the RDS Proxy. Must be unique within the AWS account and region."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name)) && length(var.name) <= 63
    error_message = "Proxy name must start with a letter, contain only letters, numbers, and hyphens, and be at most 63 characters long."
  }
}

variable "engine_family" {
  description = "The kinds of databases that the proxy can connect to. Valid values: MYSQL, POSTGRESQL, SQLSERVER."
  type        = string

  validation {
    condition     = contains(["MYSQL", "POSTGRESQL", "SQLSERVER"], var.engine_family)
    error_message = "engine_family must be one of: MYSQL, POSTGRESQL, SQLSERVER."
  }
}

variable "role_arn" {
  description = "ARN of the IAM role that allows RDS Proxy to access the database credentials in AWS Secrets Manager."
  type        = string
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs for the RDS Proxy. The proxy will be accessible from these subnets."
  type        = list(string)
}

variable "auth" {
  description = <<-EOT
    List of authentication mechanisms for the proxy. Each item can contain:
    - auth_scheme: The type of authentication (default: SECRETS)
    - client_password_auth_type: The type of client password auth (e.g. MYSQL_NATIVE_PASSWORD, POSTGRES_SCRAM_SHA_256)
    - description: A description for this auth config
    - iam_auth: Whether to require IAM authentication (DISABLED or REQUIRED, default: DISABLED)
    - secret_arn: ARN of the Secrets Manager secret with database credentials
    - username: Username to use for the proxy auth (optional)
  EOT
  type = list(object({
    auth_scheme               = optional(string, "SECRETS")
    client_password_auth_type = optional(string)
    description               = optional(string)
    iam_auth                  = optional(string, "DISABLED")
    secret_arn                = optional(string)
    username                  = optional(string)
  }))
}

variable "target_db_instance_identifier" {
  description = "DB instance identifier to associate with the proxy. Specify either this or target_db_cluster_identifier, not both."
  type        = string
  default     = null
}

variable "target_db_cluster_identifier" {
  description = "Aurora cluster identifier to associate with the proxy. Specify either this or target_db_instance_identifier, not both."
  type        = string
  default     = null
}

variable "debug_logging" {
  description = "Whether to enable debug logging for the proxy. Logs include detailed information about SQL statements."
  type        = bool
  default     = false
}

variable "idle_client_timeout" {
  description = "Number of seconds a connection to the proxy can be inactive before it is closed. Valid range: 1-28800."
  type        = number
  default     = 1800

  validation {
    condition     = var.idle_client_timeout >= 1 && var.idle_client_timeout <= 28800
    error_message = "idle_client_timeout must be between 1 and 28800 seconds."
  }
}

variable "require_tls" {
  description = "Whether to require TLS encryption for connections to the proxy. Highly recommended for production."
  type        = bool
  default     = true
}

variable "max_connections_percent" {
  description = "Maximum percentage of the max_connections that RDS Proxy can open on a given DB instance. Valid range: 1-100."
  type        = number
  default     = 100

  validation {
    condition     = var.max_connections_percent >= 1 && var.max_connections_percent <= 100
    error_message = "max_connections_percent must be between 1 and 100."
  }
}

variable "max_idle_connections_percent" {
  description = "Maximum percentage of max_connections RDS Proxy can keep idle in the pool. Valid range: 0-100. Must be less than or equal to max_connections_percent."
  type        = number
  default     = 50

  validation {
    condition     = var.max_idle_connections_percent >= 0 && var.max_idle_connections_percent <= 100
    error_message = "max_idle_connections_percent must be between 0 and 100."
  }
}

variable "connection_borrow_timeout" {
  description = "Number of seconds to wait for a connection from the proxy's connection pool before returning a timeout error. Valid range: 0-3600."
  type        = number
  default     = 120

  validation {
    condition     = var.connection_borrow_timeout >= 0 && var.connection_borrow_timeout <= 3600
    error_message = "connection_borrow_timeout must be between 0 and 3600 seconds."
  }
}

variable "init_query" {
  description = "SQL statements for the proxy to run when opening a new connection to the database. Often used to set timezone or session variables."
  type        = string
  default     = null
}

variable "session_pinning_filters" {
  description = "List of SQL operations that cause the proxy to keep the client connected to the same DB instance. Set to EXCLUDE_VARIABLE_SETS to reduce pinning."
  type        = list(string)
  default     = []
}

variable "port" {
  description = "Port number the proxy listens on. Used for security group rules. Default ports: MySQL/Aurora MySQL=3306, PostgreSQL/Aurora PostgreSQL=5432, SQL Server=1433."
  type        = number
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created. Required if create_security_group is true."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the proxy. If null and create_security_group is true, a security group will be created."
  type        = list(string)
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a security group for the RDS Proxy."
  type        = bool
  default     = true
}

variable "allowed_security_groups" {
  description = "Map of security group IDs allowed to connect to the proxy. Key is a description, value is the security group ID."
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the proxy."
  type        = list(string)
  default     = []
}

variable "egress_cidr_blocks" {
  description = "List of CIDR blocks for egress traffic from the proxy security group."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
