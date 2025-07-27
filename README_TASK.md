# Tier 4. Module 6 - DevOps CI/CD

## Homework for Topics 8-9 - Studing Jenkins CI and ArgoCD + CD

### Technical task

This time, the task is to bring together Jenkins, Terraform, ECR, Helm, and Argo CD and build a true deployment pipeline that works without manual intervention.

This hands-on exercise will show you how modern DevOps teams ensure fast, stable, and predictable delivery of changes to production.

#### Task description

The goal is to implement a complete CI/CD process using **Jenkins + Helm + Terraform + Argo CD** that:

1. **Automatically builds a Docker image** for a Django application;
2. **Publishes the image to Amazon ECR**;
3. **Updates the Helm chart** in the repository with the correct tag;
4. **Synchronizes the application across the cluster via Argo CD**, which picks up changes from Git.

#### Task Steps

**1. Jenkins + Helm + Terraform**

- Install Jenkins via Helm, automating the installation via Terraform.
- Deploy Jenkins via Kubernetes Agent (Kaniko + Git).
- Implement a pipeline (via Jenkinsfile) that:
- Builds an image from a Dockerfile;
- Pushes it to ECR;
- Updates a tag in another repository's `values.yaml`;
- Pushes changes to `main`.

**2. Argo CD + Helm + Terraform**

- Install Argo CD via Helm using Terraform.
- Configure an Argo CD Application that tracks Helm chart updates.
- Argo CD should automatically sync changes to the cluster after Git updates.

**Project Structure**

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
│   ├── jenkins/             # Jenkins Helm installation module
│   │   ├── jenkins.tf       # Jenkins Helm release
│   │   ├── variables.tf     # Variables (resources, credentials, values)
│   │   ├── providers.tf     # Provider declarations
│   │   ├── values.yaml      # Jenkins configuration
│   │   └── outputs.tf       # Outputs (URL, admin password)
│   │ 
│   └── argo_cd/ # Module for Helm installation of Argo CD
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
