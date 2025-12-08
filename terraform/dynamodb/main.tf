terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DynamoDB Table
# Creates the main DynamoDB table with configurable billing mode, encryption, and optional features
resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  # Table class (STANDARD or STANDARD_INFREQUENT_ACCESS)
  table_class = var.table_class

  # TTL Configuration (optional)
  dynamic "ttl" {
    for_each = var.ttl_attribute_name != null ? [1] : []

    content {
      attribute_name = var.ttl_attribute_name
      enabled        = var.ttl_enabled
    }
  }

  # Point-in-Time Recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Server-Side Encryption
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  # Hash Key Attribute
  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  # Range Key Attribute (optional)
  dynamic "attribute" {
    for_each = var.range_key != null ? [1] : []

    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  # Additional attributes for GSI and LSI
  dynamic "attribute" {
    for_each = var.attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes (optional)
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes

    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = try(global_secondary_index.value.range_key, null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = try(global_secondary_index.value.non_key_attributes, null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? coalesce(try(global_secondary_index.value.read_capacity, null), var.read_capacity) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? coalesce(try(global_secondary_index.value.write_capacity, null), var.write_capacity) : null
    }
  }

  # Local Secondary Indexes (optional)
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes

    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = try(local_secondary_index.value.non_key_attributes, null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )
}

# Auto Scaling Target for Read Capacity (PROVISIONED mode only)
resource "aws_appautoscaling_target" "read" {
  count = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_read_max_capacity
  min_capacity       = var.autoscaling_read_min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy for Read Capacity
resource "aws_appautoscaling_policy" "read" {
  count = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0

  name               = "${var.table_name}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_read_target_value
  }
}

# Auto Scaling Target for Write Capacity (PROVISIONED mode only)
resource "aws_appautoscaling_target" "write" {
  count = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_write_max_capacity
  min_capacity       = var.autoscaling_write_min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy for Write Capacity
resource "aws_appautoscaling_policy" "write" {
  count = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0

  name               = "${var.table_name}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_write_target_value
  }
}

# Auto Scaling for Global Secondary Indexes (PROVISIONED mode only)
resource "aws_appautoscaling_target" "gsi_read" {
  for_each = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? {
    for idx in var.global_secondary_indexes :
    idx.name => idx
    if try(idx.enable_autoscaling, true)
  } : {}

  max_capacity       = coalesce(try(each.value.autoscaling_read_max_capacity, null), var.autoscaling_read_max_capacity)
  min_capacity       = coalesce(try(each.value.autoscaling_read_min_capacity, null), var.autoscaling_read_min_capacity)
  resource_id        = "table/${aws_dynamodb_table.this.name}/index/${each.key}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "gsi_read" {
  for_each = aws_appautoscaling_target.gsi_read

  name               = "${var.table_name}-${each.key}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_read_target_value
  }
}

resource "aws_appautoscaling_target" "gsi_write" {
  for_each = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? {
    for idx in var.global_secondary_indexes :
    idx.name => idx
    if try(idx.enable_autoscaling, true)
  } : {}

  max_capacity       = coalesce(try(each.value.autoscaling_write_max_capacity, null), var.autoscaling_write_max_capacity)
  min_capacity       = coalesce(try(each.value.autoscaling_write_min_capacity, null), var.autoscaling_write_min_capacity)
  resource_id        = "table/${aws_dynamodb_table.this.name}/index/${each.key}"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "gsi_write" {
  for_each = aws_appautoscaling_target.gsi_write

  name               = "${var.table_name}-${each.key}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_write_target_value
  }
}
