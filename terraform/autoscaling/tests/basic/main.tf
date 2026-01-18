terraform {
  required_version = ">= 1.3.0"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "asg" {
  source = "../../" # local module path for tests

  name              = "example"
  vpc_subnet_ids    = ["subnet-123", "subnet-456"]
  target_group_arns = []

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  instance_type = "t3.micro"

  # In CI, do not resolve real AMI
  use_ssm_ami_lookup = false
  ami_id             = "ami-00000000000000000" # dummy

  security_group_ids        = ["sg-123456"]
  iam_instance_profile_name = null

  enable_target_tracking_cpu = true
  cpu_target_value           = 50
}

output "asg_name" {
  value = module.asg.asg_name
}
