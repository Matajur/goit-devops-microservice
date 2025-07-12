# Tier 4. Module 6 - DevOps CI/CD

## Homework for Topic 5 - IaS. Terraform

### Technical task

We suggest you practice

- Setting up a backend for Terraform with guaranteed secure and centralized state storage.
- Deploying key AWS infrastructure components using Terraform.
- Documenting your actions for reuse and team convenience.

This task is as close as possible to real-world scenarios that you will encounter at work. By completing it, you will not only consolidate the theory, but also deepen your infrastructure project.

#### Task description

The task is to create a Terraform structure for the infrastructure on AWS in a **new directory** `lesson-5`.

It's required to configure:

1. **Synchronization of state files** to S3 using DynamoDB for locking.
2. **Network infrastructure (VPC)** with public and private subnets.
3. **ECR (Elastic Container Registry)** for storing Docker images.

**Project Structure**

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

#### Task Steps

**1. Create the main project structure**

In the root folder `lesson-5`, create the files:

- `main.tf` — connecting modules.
- `backend.tf` — backend settings for saving states in S3.
- `outputs.tf` — common output data from all modules.

**2. Configure S3 for states and DynamoDB**

In the `s3-backend` module:

- Configure an S3 bucket for Terraform state files.
- Enable **versioning** to save state history.
- Configure a **DynamoDB** table for locking states.
- The output should be in `outputs.tf` with the URL of the S3 bucket and the name of the DynamoDB.

**3. Build the network infrastructure (VPC)**

In the `vpc` module:

- Create a **VPC** with a CIDR block.
- Add **3 public subnets** and **3 private subnets**.
- Create an **Internet Gateway** for public subnets.
- Create a **NAT Gateway** for private subnets.
- Configure **routing** via Route Tables.

**4. Create an ECR repository**

In the `ecr` module:

- Create an ECR repository with automatic **image scanning**.
- Configure the access policy for the repository.
- **Output** the repository URL via `outputs.tf`.

**5. Connect all modules in `main.tf`**

```T
# Connecting the S3 and DynamoDB module
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "your custom name"
  table_name  = "terraform-locks"
}

# Connecting the VPC module
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-5-vpc"
}

# Connecting the ECR module
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "lesson-5-ecr"
  scan_on_push = true
}
```

**6. Configure the backend for Terraform**

Create `backend.tf` to configure S3 as the backend:

```T
terraform {
  backend "s3" {
    bucket         = "your custom name"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**7. Document the project in `README.md`**

In the `README.md` file, add:

- A description of the project structure.
- Commands for initialization and launch:

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

- Explanation of each module: `s3-backend`, `vpc`, `ecr`.

**8. Upload the project to the repository**

1. Create a new **branch** `lesson-5`.

```bash
git checkout -b lesson-5
```

2. Commit the changes to the branch.

```bash
git add .
git commit -m "Add Terraform modules for S3, VPC, and ECR"
git push origin lesson-5
```

#### Homework Acceptance Criteria

1. The `lesson-5` directory structure matches the specified one.
2. All modules are created and working.
3. Terraform creates resources in AWS.
4. The project is pushed to the repository in the `lesson-5` branch.
