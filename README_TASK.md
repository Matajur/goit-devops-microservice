# Tier 4. Module 6 - DevOps CI/CD

## Homework for Topic 10 - Database administration

### Technical task

The task is to create a **production-ready Terraform module** that can create:

- **A regular RDS database (PostgreSQL / MySQL)**
- **Or an Aurora cluster**, depending on the `use_aurora = true flag`

This task will teach you how to work with conditional logic in Terraform, dependencies between resources, and structured variables.

#### Task description

Implement a universal `rds` module that:

1. Brings up an **Aurora Cluster** or a **regular RDS instance** based on the `use_aurora` value;
2. Automatically creates:

- **DB Subnet Group**
- **Security Group**
- **Parameter Group** for the selected DB type;

3. Works with minimal variable changes and supports multiple uses.

#### Project structure

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

#### Module functionality:

- `use_aurora = true` → Aurora Cluster + writer is created;
- `use_aurora = false` → one `aws_db_instance` is created;

In both cases:
- `aws_db_subnet_group` is created;
- `aws_security_group` is created;
- `parameter group` is created with basic parameters (`max_connections`, `log_statement`, `work_mem`);
- The `engine`, `engine_version`, `instance_class`, `multi_az` parameters are specified through variables.

#### README.md should contain:

- An example of using the module (`module "rds" { ... }`);
- A description of all variables with an explanation;
- A description of how to change the database type, engine, instance class, etc.
