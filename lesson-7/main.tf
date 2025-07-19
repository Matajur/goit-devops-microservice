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

# Connecting the Kubernetes module
module "eks" {
  source       = "./modules/eks"                  # Path to EKS module
  cluster_name = "lesson-7-eks-cluster"           # Cluster name
  subnet_ids      = module.vpc.public_subnets     # Subnet IDs
  vpc_id          = module.vpc.vpc_id             # VPC ID where EKS cluster will be deployed
  instance_type   = "t3.medium"                   # Instance type
  desired_size    = 2                             # Desired number of nodes
  max_size        = 2                             # Maximum number of nodes
  min_size        = 6                             # Minimum number of nodes
}
