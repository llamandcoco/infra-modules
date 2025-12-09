output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "cidr_block" {
  description = "IPv4 CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "ipv6_cidr_block" {
  description = "Amazon provided IPv6 CIDR block of the VPC."
  value       = aws_vpc.this.ipv6_cidr_block
}

output "tags" {
  description = "Tags applied to the VPC."
  value       = aws_vpc.this.tags_all
}
