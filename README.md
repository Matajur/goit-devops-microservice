# IaC: Terraform, Kubernetes, Helm, Jenkins, Argo CD, Aurora
## Project Documentation

This project provisions AWS infrastructure for:
- **S3 + DynamoDB** (Terraform backend)
- **VPC** (public and private subnets)
- **ECR** (Elastic Container Registry)
- **EKS** (Elastic Kubernetes Service)
- **RDS** (Relational Data Base)
- **Jenkins**
- **Argo CD**
- **Prometheus**
- **Grafana**

### Project Structure

```
Project/
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
│   ├── eks/                 # Module for Kubernetes cluster
│   │   ├── eks.tf           # Creating a cluster
│   │   ├── aws_ebs_csi_driver.tf   # Installing the csi drive plugin
│   │   ├── variables.tf     # Variables for EKS
│   │   └── outputs.tf       # Displaying cluster information
│   │
│   ├── rds/                 # Module for RDS
│   │   ├── rds.tf           # Creating an RDS database
│   │   ├── aurora.tf        # Creating an aurora database cluster
│   │   ├── shared.tf        # Shared resources
│   │   ├── variables.tf     # Variables (resources, credentials, values)
│   │   └── outputs.tf
│   │
│   ├── jenkins/             # Jenkins Helm installation module
│   │   ├── jenkins.tf       # Jenkins Helm release
│   │   ├── variables.tf     # Variables (resources, credentials, values)
│   │   ├── providers.tf     # Provider declarations
│   │   ├── values.yaml      # Jenkins configuration
│   │   └── outputs.tf       # Outputs (URL, admin password)
│   │ 
│   └── argo_cd/             # Module for Helm installation of Argo CD
│       ├── argo-cd.tf       # Helm release for Jenkins
│       ├── variables.tf     # Variables (chart version, namespace, repo URL, etc.)
│       ├── providers.tf     # Kubernetes+Helm. ported from jenkins module
│       ├── values.yaml      # Custom Argo CD configuration
│       ├── outputs.tf       # Outputs (hostname, initial admin password)
│       └──charts/           # Helm chart for creating apps
│           ├── Chart.yaml
│           ├── values.yaml  # List of applications, repositories
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
├── charts/
│   ├── django-app/
│   │   ├── templates/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── configmap.yaml
│   │   │   └── hpa.yaml
│   │   ├── Chart.yaml
│   │   └── values.yaml      # ConfigMap with environment variables for Django web application
│   │
│   └── monitoring/
│       ├── templates/
│       │   ├── application.yaml
│       │   ├── servicemonitor.yaml
│       ├── Chart.yaml
│       └── values.yaml      # ConfigMap with environment variables for Prometheus and Grafana
├──django
│			 ├── app\
│			 ├── Dockerfile
│			 ├── Jenkinsfile
│			 └── docker-compose.yaml
│
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

Initialize Terraform
```bash
terraform init
```

This will download the AWS provider, initialize the modules (s3-backend, vpc, ecr, etc.) and set up Terraform to use a local state file for now.

3. Plan infrastructure

```bash
terraform plan -var-file="secrets.auto.tfvars"
```

Terraform will create an S3 bucket for the backend, a DynamoDB table for state locking, VPC, subnets, ECR repo, etc.

4. Apply infrastructure

```bash
terraform apply -var-file="secrets.auto.tfvars"
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

8. Access Jenkins UI

```bash
kubectl get svc -n jenkins
```

Find `EXTERNAL-IP` in the console output and access it in browser.

9. Access Jenkins user interface with `secrets.auts.tfvars` credentials and approves the scripts in the Manaje Jenkins section, if requested. Run `seed-job` and `django-docker` builds. Requires the configured Pod template Kaniko in Jenkins UI.

10. Access Argo CD UI

```bash
kubectl get svc -n argocd
```

Find `EXTERNAL-IP` in the console output and access it in browser.

11. Access Argo CD user interface with login `admin` and password obtained with this console script

```bash
$secret = kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($secret))
```

12. Access Django web application with `EXTERNAL-IP` obtained with this command

```bash
kubectl get svc -n django
```

In case of errors

```bash
kubectl logs -n django -l app=django-app
```

13. Delete all AWS resources created by Terraform

```bash
terraform destroy
```

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

#### jenkins
This module is to:
- Install Argo CD into a Kubernetes cluster (usually via Helm).
- Create necessary Kubernetes manifests (namespace, RBAC, service, ingress, etc.).
- Define Argo CD applications that sync your Git repositories to the cluster.

#### argo_cd
This module is needed to:
- Install Argo CD into a Kubernetes cluster (usually via Helm).
- Create necessary Kubernetes manifests (namespace, RBAC, service, ingress, etc.).
- Define Argo CD applications that sync your Git repositories to the cluster.

#### rds
This module to:
- Create a PostgreSQL (or Aurora PostgreSQL) database.
- Configure subnets, security groups, parameter groups, and backups.
- Output credentials (via secrets.auto.tfvars, ideally).
