# Tier 4. Module 6 - DevOps CI/CD

## Final Project

### Technical task

Technical Requirements

- **Infrastructure**: AWS using Terraform
- **Components**: VPC, EKS, RDS, ECR, Jenkins, Argo CD, Prometheus, Grafana

#### Execution steps

1. Prepare the environment:

- Initialize Terraform.
- Verify all required variables and parameters.

2. Deploy the infrastructure:

- Run the deployment command:

```bash
terraform apply
```

- Check the status of resources via:

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

3. Check availability:

- Jenkins:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

- Argo CD:

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

4. Monitor and check metrics:

- Grafana:

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

- Check the status of metrics in the Grafana Dashboard.

#### Project Structure

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
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml      # ConfigMap with environment variables
│
├──django
│			 ├── app\
│			 ├── Dockerfile
│			 ├── Jenkinsfile
│			 └── docker-compose.yaml
│
└── README.md                # Project documentation
```