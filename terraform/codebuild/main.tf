terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------

locals {
  role_name = "${var.project_name}-role"
  log_group = "/aws/codebuild/${var.project_name}"
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "logs" {
  name              = local.log_group
  retention_in_days = var.logs_retention_days
  tags              = var.tags
}

# -----------------------------------------------------------------------------
# IAM Role and Policies
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

# Policy: ECR Push
data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr" {
  name   = "${var.project_name}-ecr-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.ecr.json
}

# Policy: CloudWatch Logs
data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.logs.arn}:*"]
  }
}

resource "aws_iam_role_policy" "logs" {
  name   = "${var.project_name}-logs-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.logs.json
}

# Policy: S3 (for CodePipeline artifacts)
data "aws_iam_policy_document" "s3" {
  count = var.enable_artifact_bucket_access && var.artifact_bucket_arn != null ? 1 : 0

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${var.artifact_bucket_arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [var.artifact_bucket_arn]
  }
}

resource "aws_iam_role_policy" "s3" {
  count  = var.enable_artifact_bucket_access && var.artifact_bucket_arn != null ? 1 : 0
  name   = "${var.project_name}-s3-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3[0].json
}

# -----------------------------------------------------------------------------
# GitHub Source Credentials
# -----------------------------------------------------------------------------
resource "aws_codebuild_source_credential" "github" {
  count       = var.source_type == "GITHUB" && var.github_token != "" ? 1 : 0
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}

# -----------------------------------------------------------------------------
# CodeBuild Project
# -----------------------------------------------------------------------------
resource "aws_codebuild_project" "this" {
  name           = var.project_name
  service_role   = aws_iam_role.this.arn
  source_version = var.github_branch

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository_name
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.logs.name
    }
  }

  source {
    type      = var.source_type
    location  = var.github_location
    buildspec = var.buildspec_path
    git_submodules_config {
      fetch_submodules = false
    }
    dynamic "auth" {
      for_each = var.source_type == "GITHUB" && var.github_token != "" ? [1] : []
      content {
        type     = "OAUTH"
        resource = aws_codebuild_source_credential.github[0].arn
      }
    }
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# GitHub Webhook
# -----------------------------------------------------------------------------
resource "aws_codebuild_webhook" "github" {
  count        = var.github_webhook && var.source_type == "GITHUB" ? 1 : 0
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH,PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "^refs/heads/${var.github_branch}$"
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_region" "current" {}
