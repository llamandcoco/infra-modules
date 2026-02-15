variable "group_name" {
  description = "Name of the IAM group to attach the policy to"
  type        = string
}

variable "policy_arn" {
  description = "ARN of the IAM policy to attach to the group"
  type        = string
}
