# EC2 Terraform Module

Production-ready Terraform module for deploying AWS EC2 instances with comprehensive configuration options.

## Features

- **Flexible Instance Configuration**: Support for on-demand and spot instances
- **Storage Options**: Configurable root volumes and additional EBS volumes with encryption
- **Network Configuration**: VPC integration, security groups, Elastic IPs, and public/private networking
- **IAM Integration**: Automatic IAM role and instance profile creation with policy attachment
- **Security Best Practices**: IMDSv2 by default, EBS encryption, and security group management
- **User Data Support**: Bootstrap instances with shell scripts or cloud-init
- **Spot Instance Support**: Cost-effective compute for fault-tolerant workloads
- **Comprehensive Outputs**: All resource IDs, ARNs, and configuration details

## Usage Examples

### Basic EC2 Instance

Minimal configuration for a private EC2 instance:

```hcl
module "basic_instance" {
  source = "../../terraform/ec2"

  instance_name = "my-app-server"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678"

  vpc_security_group_ids = ["sg-12345678"]

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Web Server with Elastic IP

Public-facing web server with custom security group and Elastic IP:

```hcl
module "web_server" {
  source = "../../terraform/ec2"

  instance_name = "web-server"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.small"
  subnet_id     = "subnet-public123"

  # Network configuration
  vpc_id                      = "vpc-12345678"
  associate_public_ip_address = true
  create_eip                  = true

  # Security group
  create_security_group = true
  security_group_name   = "web-server-sg"

  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from internet"
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from internet"
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound"
    }
  ]

  key_name = "my-ssh-key"

  tags = {
    Environment = "production"
    Purpose     = "web-server"
  }
}
```

### Database Server with Additional EBS Volumes

Instance with multiple EBS volumes for database workloads:

```hcl
module "database_server" {
  source = "../../terraform/ec2"

  instance_name = "database-server"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "r6i.large"
  subnet_id     = "subnet-private123"

  vpc_security_group_ids = ["sg-database123"]

  # Root volume
  root_block_device = {
    volume_size = 50
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
    encrypted   = true
  }

  # Additional data volumes
  ebs_volumes = [
    {
      device_name = "/dev/sdf"
      volume_size = 500
      volume_type = "io2"
      iops        = 10000
      encrypted   = true
    },
    {
      device_name = "/dev/sdg"
      volume_size = 1000
      volume_type = "st1"
      encrypted   = true
    }
  ]

  monitoring = true

  tags = {
    Environment = "production"
    Purpose     = "database"
  }

  volume_tags = {
    BackupPolicy = "daily"
  }
}
```

### Instance with IAM Role and User Data

Bootstrap instance with user data and IAM permissions:

```hcl
module "app_server" {
  source = "../../terraform/ec2"

  instance_name = "app-server"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  subnet_id     = "subnet-12345678"

  vpc_security_group_ids = ["sg-12345678"]

  # IAM configuration
  create_iam_instance_profile = true
  iam_role_name               = "app-server-role"

  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  iam_inline_policies = [
    {
      name = "s3-access"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::my-app-bucket",
              "arn:aws:s3:::my-app-bucket/*"
            ]
          }
        ]
      })
    }
  ]

  # Bootstrap script
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
  EOF

  tags = {
    Environment = "production"
    Purpose     = "application-server"
  }
}
```

### Spot Instance for Batch Processing

Cost-effective spot instance for fault-tolerant workloads:

```hcl
module "batch_processor" {
  source = "../../terraform/ec2"

  instance_name = "batch-processor"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "c6i.xlarge"
  subnet_id     = "subnet-12345678"

  vpc_security_group_ids = ["sg-12345678"]

  # Spot instance configuration
  enable_spot_instance                = true
  spot_price                          = "0.10"
  spot_instance_interruption_behavior = "terminate"

  root_block_device = {
    volume_size = 100
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Environment = "development"
    Purpose     = "batch-processing"
    CostCenter  = "engineering"
  }
}
```

## AMI Selection Guide

### Finding the Latest AMIs

**Amazon Linux 2023:**
```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023.*-x86_64" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
  --output table
```

**Ubuntu 22.04 LTS:**
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
  --output table
```

**Ubuntu 24.04 LTS:**
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
  --output table
```

**Red Hat Enterprise Linux 9:**
```bash
aws ec2 describe-images \
  --owners 309956199498 \
  --filters "Name=name,Values=RHEL-9.*-x86_64-*" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
  --output table
```

**Windows Server 2022:**
```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=Windows_Server-2022-English-Full-Base-*" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
  --output table
```

## Instance Sizing Guide

### General Purpose (T3/T3a)
- **t3.micro**: 2 vCPU, 1 GB RAM - Dev/test, low-traffic applications
- **t3.small**: 2 vCPU, 2 GB RAM - Small web apps, development environments
- **t3.medium**: 2 vCPU, 4 GB RAM - Small databases, web servers
- **t3.large**: 2 vCPU, 8 GB RAM - Medium-traffic applications
- **t3.xlarge**: 4 vCPU, 16 GB RAM - Application servers

### Compute Optimized (C6i)
- **c6i.large**: 2 vCPU, 4 GB RAM - Batch processing, media encoding
- **c6i.xlarge**: 4 vCPU, 8 GB RAM - High-performance web servers
- **c6i.2xlarge**: 8 vCPU, 16 GB RAM - Compute-intensive applications

### Memory Optimized (R6i)
- **r6i.large**: 2 vCPU, 16 GB RAM - In-memory caches, databases
- **r6i.xlarge**: 4 vCPU, 32 GB RAM - Large databases, analytics
- **r6i.2xlarge**: 8 vCPU, 64 GB RAM - Enterprise applications

### Storage Optimized (I3)
- **i3.large**: 2 vCPU, 15.25 GB RAM, 1x475 GB NVMe SSD - NoSQL databases
- **i3.xlarge**: 4 vCPU, 30.5 GB RAM, 1x950 GB NVMe SSD - Data warehousing

## Storage Configuration

### Volume Types

**gp3 (General Purpose SSD v3)** - Default, recommended
- **Use Cases**: Boot volumes, development, medium-traffic databases
- **Performance**: 3,000 IOPS baseline, 125 MB/s throughput
- **Configurable**: Up to 16,000 IOPS and 1,000 MB/s throughput
- **Cost**: Most cost-effective for general workloads

**gp2 (General Purpose SSD v2)** - Legacy
- **Use Cases**: Legacy applications, existing configurations
- **Performance**: 3 IOPS per GB (min 100, max 16,000)
- **Note**: Prefer gp3 for new deployments

**io2 (Provisioned IOPS SSD v2)**
- **Use Cases**: High-performance databases, critical applications
- **Performance**: Up to 64,000 IOPS, 99.999% durability
- **Cost**: Higher cost, pay for provisioned IOPS
- **Best For**: Production databases requiring consistent performance

**st1 (Throughput Optimized HDD)**
- **Use Cases**: Big data, log processing, data warehousing
- **Performance**: Up to 500 MB/s throughput
- **Cost**: Lower cost per GB
- **Note**: Cannot be used as boot volume

**sc1 (Cold HDD)**
- **Use Cases**: Infrequent access, archival storage
- **Performance**: Up to 250 MB/s throughput
- **Cost**: Lowest cost per GB
- **Note**: Cannot be used as boot volume

### Volume Configuration Examples

**High-Performance Database:**
```hcl
root_block_device = {
  volume_size = 100
  volume_type = "io2"
  iops        = 10000
  encrypted   = true
}
```

**Cost-Optimized Development:**
```hcl
root_block_device = {
  volume_size = 20
  volume_type = "gp3"
  encrypted   = true
}
```

**Big Data Processing:**
```hcl
ebs_volumes = [
  {
    device_name = "/dev/sdf"
    volume_size = 1000
    volume_type = "st1"
    encrypted   = true
  }
]
```

## User Data Examples

### Bash Script (Amazon Linux / Ubuntu)

```bash
#!/bin/bash
# Update system
yum update -y  # or: apt-get update && apt-get upgrade -y

# Install packages
yum install -y nginx docker git

# Start services
systemctl start nginx
systemctl enable nginx
systemctl start docker
systemctl enable docker

# Configure application
mkdir -p /opt/myapp
cd /opt/myapp
git clone https://github.com/myorg/myapp.git .

# Set up environment
cat > /etc/environment <<EOF
APP_ENV=production
APP_PORT=8080
EOF
```

### Cloud-Init Format

```yaml
#cloud-config
packages:
  - nginx
  - docker
  - git

runcmd:
  - systemctl start nginx
  - systemctl enable nginx
  - systemctl start docker
  - systemctl enable docker
  - usermod -aG docker ec2-user

write_files:
  - path: /opt/myapp/config.json
    content: |
      {
        "environment": "production",
        "port": 8080
      }
    permissions: '0644'

final_message: "System configured successfully"
```

### Using with Terraform

```hcl
user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y nginx
  systemctl start nginx
EOF
```

## IAM Role Best Practices

### Systems Manager Access

```hcl
iam_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
]
```

Enables:
- Session Manager (SSH alternative)
- Run Command
- Patch Manager

### CloudWatch Monitoring

```hcl
iam_policy_arns = [
  "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
]
```

Enables:
- Publish custom metrics
- Send logs to CloudWatch Logs

### S3 Access

```hcl
iam_inline_policies = [
  {
    name = "s3-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::my-bucket/*"
        }
      ]
    })
  }
]
```

### ECR Access

```hcl
iam_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
]
```

## Security Group Patterns

### Web Server (Public)

```hcl
security_group_rules = [
  {
    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  },
  {
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  },
  {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }
]
```

### Application Server (Private)

```hcl
security_group_rules = [
  {
    type        = "ingress"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "App from VPC"
  },
  {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }
]
```

### Bastion Host

```hcl
security_group_rules = [
  {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["1.2.3.4/32"]  # Your IP
    description = "SSH from admin"
  },
  {
    type        = "egress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "SSH to VPC"
  }
]
```

## Security Best Practices

### IMDSv2 (Instance Metadata Service v2)

Always require IMDSv2 for enhanced security:

```hcl
metadata_options = {
  http_endpoint = "enabled"
  http_tokens   = "required"  # Requires IMDSv2
}
```

### EBS Encryption

Enable encryption for all volumes:

```hcl
root_block_device = {
  encrypted = true
  # Optional: Use customer-managed key
  # kms_key_id = "arn:aws:kms:region:account:key/key-id"
}

ebs_volumes = [
  {
    device_name = "/dev/sdf"
    volume_size = 100
    encrypted   = true
  }
]
```

### Termination Protection

Enable for production instances:

```hcl
disable_api_termination = true
```

## Testing

The module includes comprehensive test scenarios:

### Run Basic Test
```bash
cd tests/basic
terraform init
terraform plan
```

### Run EBS Test
```bash
cd tests/with_ebs
terraform init
terraform plan
```

### Run All Tests
```bash
for test in tests/*/; do
  echo "Testing $test"
  cd "$test"
  terraform init && terraform plan
  cd ../..
done
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Contributing

When contributing to this module:

1. Update tests for new features
2. Run `terraform fmt -recursive`
3. Update documentation
4. Test with `terraform plan` in all test scenarios

## License

MIT License - See LICENSE file for details
