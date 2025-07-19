# IaC (Terraform)
## Project Documentation

This project provisions AWS infrastructure for:
- **S3 + DynamoDB** (Terraform backend)
- **VPC** (public and private subnets)
- **ECR** (Elastic Container Registry)
- **EKS** (Elastic Kubernetes Service)

### Project Structure

```
lesson-7/
│
├── main.tf                  # Main file for connecting modules
├── backend.tf               # Setting up the backend for states (S3 + DynamoDB)
├── outputs.tf               # General resource extraction
│
├── modules/                 # Catalog with all modules
│   │
│   ├── s3-backend/          # Module for S3 and DynamoDB
│   │   ├── s3.tf            # Creating an S3 bucket
│   │   ├── dynamodb.tf      # Creating DynamoDB
│   │   ├── variables.tf     # Variables for S3
│   │   └── outputs.tf       # S3 and DynamoDB data output
│   │
│   ├── vpc/                 # Module for VPC
│   │   ├── vpc.tf           # Creating VPC, subnets, Internet Gateway
│   │   ├── routes.tf        # Routing settings
│   │   ├── variables.tf     # Variables for VPC
│   │   └── outputs.tf       # VPC data output
│   │
│   ├── ecr/                 # Module for ECR
│   │   ├── ecr.tf           # Creating an ECR repository
│   │   ├── variables.tf     # Variables for ECR
│   │   └── outputs.tf       # ECR repository URL output
│   │
│   └── eks/                 # Module for Kubernetes cluster
│       ├── eks.tf           # Creating a cluster
│       ├── node.tf          # Creating EKS nodes (EC2 instances)
│       ├── variables.tf     # Variables for EKS
│       └── outputs.tf       # Displaying cluster information
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml      # ConfigMap with environment variables
|
└── README.md                # Project documentation
```

### Initialization and Launch:

1. Temporarily comment out all the content in the backend.tf file

```T
# terraform {
#   backend "s3" {
#     bucket         = "lesson-5-state-bucket"
#     key            = "lesson-5/terraform.tfstate"
#     region         = "eu-central-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
```

2. Initialize Terraform: from the lesson-5 directory run in console

Enter the directory with the main.tf file
```bash
cd lesson-7
```

Initialize Terraform
```bash
terraform init
```

This will download the AWS provider, initialize the modules (s3-backend, vpc, ecr, etc.) and set up Terraform to use a local state file for now.

3. Plan infrastructure

```bash
terraform plan
```

Terraform will create an S3 bucket for the backend, a DynamoDB table for state locking, VPC, subnets, ECR repo, etc.

4. Apply infrastructure

```bash
terraform apply
```

Approve with yes when prompted.

Terraform will create the S3 bucket and DynamoDB table, VPC and ECR repo, etc. The state is still stored locally in terraform.tfstate.

5. Enable the backend (migrate state to S3) in the backend.tf

```T
terraform {
  backend "s3" {
    bucket         = "lesson-5-state-bucket"
    key            = "lesson-5/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

6. Reinitialize Terraform with backend

```bash
terraform init -migrate-state
```

Approve with yes when prompted.

7. Check that Terraform is now using the remote backend

```bash
terraform state list
```

This confirms Terraform can read/write the state in S3.

8. Authenticate Docker with ECR

```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 375004071644.dkr.ecr.eu-central-1.amazonaws.com
```

9. Tag and push the Docker image

```bash
docker tag 04-django:latest 375004071644.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest

docker push 375004071644.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest
```

10. Configure Kubernetes to use the actual cluster

```bash
aws eks update-kubeconfig --region eu-central-1 --name lesson-7-eks-cluster
```

11. Verify cluster

```bash
kubectl get nodes
```

12. Install Django Helm chart

```bash
cd charts\django-app
```

```bash
helm install django-app . --set secretKey="django-secret-key"
```

Or if some changes to be applied to already installed Helm Chart

```bash
helm upgrade django-app . --set secretKey="django-secret-key"
```

13. Get the Django App URL for testing and verification

```bash
kubectl get pod -A
```

```bash
kubectl get svc
```

After running the above command, copy the application URL from the console to your browser and check if it works.

```bash
kubectl logs -f deploy/django-app
```

To check the logs of the deployed application.

14. Delete all AWS resources created by Terraform

```bash
cd lesson-7
```

```bash
terraform destroy
```

Approve with yes when prompted.

### Module Explanations
#### s3-backend
This module sets up:
- An S3 bucket with versioning enabled to store Terraform state files.
- A DynamoDB table to manage state locking and prevent concurrent modifications.

#### vpc
This module creates:
- A VPC with a CIDR block.
- 3 public and 3 private subnets across different availability zones.
- An Internet Gateway for public subnets.
- A NAT Gateway for private subnets.
- Route tables for proper traffic routing.

#### ecr
This module provisions:
- An ECR repository with image scanning on push enabled.
- Access policies for secure image storage and retrieval.

#### eks
This module defines:
- AWS EKS cluster (control plane).
- Node Group (EC2 worker nodes).
- IAM roles for the cluster and node group.
- Outputs connection info to be used with `kubectl`: cluster name, endpoint, base64 CA certificate data.
