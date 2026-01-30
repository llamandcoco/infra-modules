# -----------------------------------------------------------------------------
# EKS Node IAM Role Module
# Creates IAM role for EKS worker nodes with required AWS managed policies
# -----------------------------------------------------------------------------

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
# IAM Role for EKS Worker Nodes
# -----------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name = var.role_name
    }
  )
}

# Trust policy for EC2 service (EKS nodes run on EC2)
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# -----------------------------------------------------------------------------
# Required AWS Managed Policies for EKS Nodes
# -----------------------------------------------------------------------------

# Core policy for EKS worker nodes
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this.name
}

# CNI policy for pod networking
resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this.name
}

# ECR policy for pulling container images
resource "aws_iam_role_policy_attachment" "container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this.name
}

# -----------------------------------------------------------------------------
# Optional Policies
# -----------------------------------------------------------------------------

# SSM for node access (optional)
resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.enable_ssm ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.this.name
}

# CloudWatch for enhanced monitoring (optional)
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.enable_cloudwatch ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.this.name
}
