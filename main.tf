terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
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
  max_size        = 6                             # Maximum number of nodes
  min_size        = 2                             # Minimum number of nodes
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# provider "helm" {
#   kubernetes_host                   = data.aws_eks_cluster.eks.endpoint
#   kubernetes_cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#   kubernetes_token                  = data.aws_eks_cluster_auth.eks.token
# }

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  jenkins_admin_user   = var.jenkins_admin_user
  jenkins_admin_pass   = var.jenkins_admin_pass
  github_username      = var.github_username
  github_token         = var.github_token
  github_repo_url      = var.github_repo_url
  github_branch        = var.github_branch

  depends_on        = [module.eks]
  providers    = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source       = "./modules/argo_cd"
  namespace    = "argocd"
  chart_version = "5.46.4"
  
}

module "rds" {
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = false
  aurora_instance_count      = 2

  # --- Aurora-only ---
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class             = "db.t3.medium"
  allocated_storage          = 20
  db_name                    = var.postgres_db
  username                   = var.postgres_user
  password                   = var.postgres_password
  subnet_private_ids         = module.vpc.private_subnets
  subnet_public_ids          = module.vpc.public_subnets
  vpc_id                     = module.vpc.vpc_id
  publicly_accessible        = true
  multi_az                   = true
  backup_retention_period    = 7
  parameters = {
    max_connections              = "200"
    log_min_duration_statement   = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

resource "helm_release" "django" {
  name       = "django-app"
  namespace  = "django"
  chart      = "./charts/django-app"

  set {
    name  = "image.repository"
    value = module.ecr.repository_url
  }

  set {
    name  = "image.tag"
    value = "latest"
  }

  set {
    name  = "secretKey"
    value = var.secret_key
  }

  set {
    name  = "debug"
    value = var.debug
  }

  set {
    name  = "allowedHosts"
    value = var.allowed_hosts
  }

  set {
    name  = "env[0].value"
    value = var.postgres_db
  }

  set {
    name  = "env[1].value"
    value = var.postgres_user
  }

  set {
    name  = "env[2].value"
    value = var.postgres_password
  }

  set {
    name  = "env[3].value"
    value = module.rds.db_instance_endpoint
  }

  set {
    name  = "env[4].value"
    value = var.db_port
  }
}
