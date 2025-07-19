# IAM role for EKS cluster
resource "aws_iam_role" "eks" {
  # IAM role name for the EKS cluster
  name = "${var.cluster_name}-eks-cluster"

  # Policy that allows the EKS service to "assume" this IAM role
  # Allows AssumeRole (use of role)
  # Allowed for EKS service
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# Binding an IAM role to the AmazonEKSClusterPolicy policy
resource "aws_iam_role_policy_attachment" "eks" {
  # ARN of the policy that grants permissions for the EKS cluster
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  # IAM role to which the policy is attached
  role       = aws_iam_role.eks.name
}

# Security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For API access (tighten for prod)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating an EKS cluster
resource "aws_eks_cluster" "eks" {
  # Cluster name
  name = var.cluster_name

  # ARN of the IAM role required to manage the cluster
  role_arn = aws_iam_role.eks.arn
  
  # Network settings (VPC)
  vpc_config {
    endpoint_private_access = true   # Enables private access to the API server
    endpoint_public_access  = true   # Enables public access to the API server
    subnet_ids = var.subnet_ids      # List of subnets where EKS will run
  }

  # Configuring access to the EKS cluster
  access_config {
    authentication_mode                         = "API"  # Authentication via API
    bootstrap_cluster_creator_admin_permissions = true   # Grants administrative rights to the user who created the cluster
  }

  # Dependency on IAM policy for EKS role
  depends_on = [aws_iam_role_policy_attachment.eks]
}
