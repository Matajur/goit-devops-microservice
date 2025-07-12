terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Connecting the S3 and DynamoDB module
module "s3_backend" {
  source      = "./modules/s3-backend"            # Path to the module
  bucket_name = "lesson-5-state-bucket"           # S3 bucket name
  table_name  = "terraform-locks"                 # DynamoDB name
}

# Connecting the VPC module
module "vpc" {
  source             = "./modules/vpc"            # Path to VPC module
  vpc_cidr_block     = "10.0.0.0/16"              # CIDR block for VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Public subnets
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]        # Private subnets
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]  # Availability zones
  vpc_name           = "lesson-5-vpc"             # VPC name
}

# Connecting the ECR module
module "ecr" {
  source      = "./modules/ecr"                   # Path to ECR module
  ecr_name    = "lesson-5-ecr"                    # ECR name
  scan_on_push = true                             # Enable image scan on push
}
