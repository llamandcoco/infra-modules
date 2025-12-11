terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# Test the module with user data script
# This demonstrates instance bootstrap configuration using cloud-init
module "test_ec2_with_user_data" {
  source = "../../"

  # Required variables
  instance_name = "test-userdata-instance"
  ami_id        = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2023 AMI
  instance_type = "t3.medium"
  subnet_id     = "subnet-12345678"

  # Use existing security group (mock)
  vpc_security_group_ids = ["sg-12345678"]

  # User data script to configure the instance at launch
  # This will be automatically base64 encoded by the module
  user_data = <<-EOF
    #!/bin/bash
    # Update system packages
    yum update -y

    # Install web server and utilities
    yum install -y nginx git docker

    # Configure nginx
    systemctl start nginx
    systemctl enable nginx

    # Create a simple web page
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <html>
      <head><title>Test Instance</title></head>
      <body>
        <h1>Instance configured via user data</h1>
        <p>Hostname: $(hostname)</p>
        <p>Instance ID: $(ec2-metadata --instance-id | cut -d ' ' -f 2)</p>
      </body>
    </html>
    HTML

    # Configure Docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Log completion
    echo "User data script completed at $(date)" >> /var/log/user-data.log
  EOF

  # Enable replace on change if user data needs to trigger instance replacement
  user_data_replace_on_change = false

  # IAM role for instance (e.g., for CloudWatch, SSM, S3 access)
  create_iam_instance_profile = true
  iam_role_name               = "test-instance-role"

  # Attach AWS managed policies
  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",      # For Systems Manager
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",       # For CloudWatch
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # For ECR access
  ]

  # Root volume configuration
  root_block_device = {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  # Enable detailed monitoring
  monitoring = true

  # IMDSv2 required (security best practice)
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Environment = "development"
    ManagedBy   = "terraform"
    Purpose     = "web-server-bootstrap"
    TestType    = "user-data"
  }
}

# Alternative example using cloud-init format (commented out)
# module "test_ec2_with_cloudinit" {
#   source = "../../"
#
#   instance_name = "test-cloudinit-instance"
#   ami_id        = "ami-0c55b159cbfafe1f0"
#   instance_type = "t3.micro"
#   subnet_id     = "subnet-12345678"
#
#   vpc_security_group_ids = ["sg-12345678"]
#
#   # Cloud-init configuration (YAML format)
#   user_data = <<-EOF
#     #cloud-config
#     packages:
#       - nginx
#       - git
#       - docker
#
#     runcmd:
#       - systemctl start nginx
#       - systemctl enable nginx
#       - systemctl start docker
#       - systemctl enable docker
#       - usermod -aG docker ec2-user
#
#     write_files:
#       - path: /usr/share/nginx/html/index.html
#         content: |
#           <h1>Configured with cloud-init</h1>
#         permissions: '0644'
#
#     final_message: "System boot completed at $TIMESTAMP"
#   EOF
#
#   tags = {
#     Environment = "development"
#     ManagedBy   = "terraform"
#     Purpose     = "cloud-init-test"
#   }
# }

# Test outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.test_ec2_with_user_data.instance_id
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = module.test_ec2_with_user_data.private_ip
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = module.test_ec2_with_user_data.iam_role_arn
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = module.test_ec2_with_user_data.iam_instance_profile_name
}
