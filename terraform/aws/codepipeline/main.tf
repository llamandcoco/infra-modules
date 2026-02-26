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
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {
  count = var.skip_data_source_lookup ? 0 : 1
}

data "aws_region" "current" {
  count = var.skip_data_source_lookup ? 0 : 1
}

data "aws_ssm_parameter" "github_token" {
  count = var.skip_data_source_lookup || var.source_provider != "GitHub" ? 0 : 1
  name  = "/${var.env}/${var.app}/github-token"
}

locals {
  account_id          = var.skip_data_source_lookup ? var.mock_account_id : data.aws_caller_identity.current[0].account_id
  region              = var.skip_data_source_lookup ? "us-east-1" : data.aws_region.current[0].name
  github_token        = var.skip_data_source_lookup ? var.mock_github_token : (var.source_provider == "GitHub" ? data.aws_ssm_parameter.github_token[0].value : null)
  github_full_repo_id = var.github_full_repository_id != null ? var.github_full_repository_id : "${var.github_owner}/${var.github_repo}"
  artifact_bucket     = var.create_artifact_bucket ? aws_s3_bucket.pipeline_artifacts[0].bucket : var.artifact_bucket_name
  pipeline_role_arn   = var.create_service_role ? aws_iam_role.pipeline[0].arn : var.service_role_arn
}

# -----------------------------------------------------------------------------
# S3 Bucket for Pipeline Artifacts
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "pipeline_artifacts" {
  count = var.create_artifact_bucket ? 1 : 0

  bucket = "${var.env}-${var.app}-artifacts-${local.account_id}"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  count = var.create_artifact_bucket ? 1 : 0

  bucket = aws_s3_bucket.pipeline_artifacts[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  count = var.create_artifact_bucket ? 1 : 0

  bucket = aws_s3_bucket.pipeline_artifacts[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  count = var.create_artifact_bucket ? 1 : 0

  bucket = aws_s3_bucket.pipeline_artifacts[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# IAM Role and Policy for CodePipeline
# -----------------------------------------------------------------------------

resource "aws_iam_role" "pipeline" {
  count = var.create_service_role ? 1 : 0

  name = "${var.pipeline_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "pipeline" {
  count = var.create_service_role ? 1 : 0

  name = "${var.pipeline_name}-policy"
  role = aws_iam_role.pipeline[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::${local.artifact_bucket}/*"
        },
        {
          Effect = "Allow"
          Action = [
            "s3:ListBucket"
          ]
          Resource = "arn:aws:s3:::${local.artifact_bucket}"
        },
        {
          Effect = "Allow"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ]
          Resource = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${var.env}/*"
        }
      ],
      var.source_provider == "CodeStarSourceConnection" && var.codestar_connection_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "codestar-connections:UseConnection"
          ]
          Resource = var.codestar_connection_arn
        }
      ] : [],
      var.enable_build_stage && var.codebuild_project_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ]
          Resource = var.codebuild_project_arn
        }
      ] : [],
      var.enable_deploy_stage && length(var.codedeploy_applications) > 0 ? [
        {
          Effect = "Allow"
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision"
          ]
          Resource = "*"
        }
      ] : [],
      var.kms_key_id != null ? [
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:Encrypt",
            "kms:GenerateDataKey",
            "kms:DescribeKey"
          ]
          Resource = var.kms_key_id
        }
      ] : []
    )
  })
}

# -----------------------------------------------------------------------------
# CodePipeline
# -----------------------------------------------------------------------------

resource "aws_codepipeline" "this" {
  name           = var.pipeline_name
  role_arn       = local.pipeline_role_arn
  pipeline_type  = var.pipeline_type
  execution_mode = var.pipeline_type == "V2" ? var.execution_mode : null

  artifact_store {
    location = local.artifact_bucket
    type     = "S3"
  }

  # Source Stage
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = var.source_provider == "CodeStarSourceConnection" ? "AWS" : "ThirdParty"
      provider         = var.source_provider
      version          = "1"
      output_artifacts = [var.source_output_artifact_name]
      namespace        = var.source_action_namespace

      configuration = var.source_provider == "CodeStarSourceConnection" ? {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = local.github_full_repo_id
        BranchName           = var.github_branch
        DetectChanges        = tostring(var.detect_changes)
        OutputArtifactFormat = var.output_artifact_format
        } : {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = local.github_token
      }
    }
  }

  # Build Stage (Optional)
  dynamic "stage" {
    for_each = var.enable_build_stage ? [1] : []
    content {
      name = "Build"

      action {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = [var.source_output_artifact_name]
        output_artifacts = [var.build_output_artifact_name]

        configuration = {
          ProjectName = var.codebuild_project_name
        }
      }
    }
  }

  # Deploy Stage (Optional)
  dynamic "stage" {
    for_each = var.enable_deploy_stage && length(var.codedeploy_applications) > 0 ? [1] : []
    content {
      name = "Deploy"

      dynamic "action" {
        for_each = var.codedeploy_applications
        content {
          name            = action.value.action_name != null ? action.value.action_name : (length(var.codedeploy_applications) == 1 ? "Deploy" : "Deploy-${action.value.deployment_group_name}")
          category        = "Deploy"
          owner           = "AWS"
          provider        = "CodeDeploy"
          version         = "1"
          input_artifacts = [var.enable_build_stage ? var.build_output_artifact_name : var.source_output_artifact_name]
          namespace       = action.value.namespace != null ? action.value.namespace : (action.key == 0 ? var.deploy_action_namespace : null)
          run_order       = action.value.run_order != null ? action.value.run_order : (action.key + 1)

          configuration = {
            ApplicationName     = action.value.application_name
            DeploymentGroupName = action.value.deployment_group_name
          }
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.create_service_role || var.service_role_arn != null
      error_message = "service_role_arn must be provided when create_service_role is false."
    }

    precondition {
      condition     = var.create_artifact_bucket || var.artifact_bucket_name != null
      error_message = "artifact_bucket_name must be provided when create_artifact_bucket is false."
    }

    precondition {
      condition     = var.source_provider != "CodeStarSourceConnection" || var.codestar_connection_arn != null
      error_message = "codestar_connection_arn must be provided when source_provider is CodeStarSourceConnection."
    }

    precondition {
      condition     = !var.enable_build_stage || (var.codebuild_project_name != null && var.codebuild_project_arn != null)
      error_message = "codebuild_project_name and codebuild_project_arn must be provided when enable_build_stage is true."
    }

    precondition {
      condition     = !var.enable_deploy_stage || length(var.codedeploy_applications) > 0
      error_message = "codedeploy_applications must be provided when enable_deploy_stage is true."
    }
  }

  tags = var.tags
}
