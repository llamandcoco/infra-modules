terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = var.group_name
  policy_arn = var.policy_arn
}
