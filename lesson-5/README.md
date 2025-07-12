# IaC (Terraform)
## Project Documentation

This project provisions AWS infrastructure for:
- **S3 + DynamoDB** (Terraform backend)
- **VPC** (public and private subnets)
- **ECR** (Elastic Container Registry)

### Project Structure

```
lesson-5/
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
│   └── ecr/                 # Module for ECR
│       ├── ecr.tf           # Creating an ECR repository
│       ├── variables.tf     # Variables for ECR
│       └── outputs.tf       # ECR repository URL output
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

8. Delete all AWS resources created by Terraform

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
