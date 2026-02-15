output "id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.this.id
}

output "arn" {
  description = "The ARN of the launch template"
  value       = aws_launch_template.this.arn
}

output "latest_version" {
  description = "The latest version of the launch template"
  value       = aws_launch_template.this.latest_version
}

output "default_version" {
  description = "The default version of the launch template"
  value       = aws_launch_template.this.default_version
}

output "name" {
  description = "The name of the launch template"
  value       = aws_launch_template.this.name
}
