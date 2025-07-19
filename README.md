# Tier 4. Module 6 - DevOps CI/CD

## Homework for Topic 7 - Learning Helm

### Technical task

This time the task is related to the practical use of Terraform, Docker, and Kubernetes.

#### Task description

The task is to create a Kubernetes cluster in the same network (VPC) that you configured in the previous homework assignment and implement the following components:

1. **Create a Kubernetes cluster** using Terraform.
2. **Set up an Elastic Container Registry (ECR)** to store your Django application's Docker image.
3. **Upload the Django Docker image** to the ECR.
4. **Create a helm chart** (`deployment.yaml`, `service.yaml`, `hpa.yaml`, `configmap.yaml`)
5. **Migrate the environment variables (env)** from topic 4 into a ConfigMap that your application will use.

#### Task Steps

**1. Create a Kubernetes cluster**

- Using Terraform, create a Kubernetes cluster in an existing network (VPC).
- Provide access to the cluster using `kubectl`.

**2. Configure ECR**

- Using Terraform, create a repository in Amazon Elastic Container Registry (ECR).
- Upload the Django Docker image you created in topic 4 to ECR using the AWS CLI.

**3. Create a helm. The Helm chart should implement:**

- **Deployment** — with the Django image with ECR and a `ConfigMap` connection (via `envFrom`).
- **Service** — of type `LoadBalancer` for external access.
- **HPA (Horizontal Pod Autoscaler)** — scaling pods from 2 to 6 when load is > 70%.
- **ConfigMap** — for environment variables (carried over from topic 4).
- **values.yaml** — with image, service, configuration, and autoscaler parameters.

**Project Structure**

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

#### Execution Results

- A Kubernetes cluster has been created in your AWS account.
- The ECR contains the uploaded Docker image of the Django application.
- The application is deployed to the cluster using a Helm chart.
- The Service provides access to the application via a public IP address.
- The ConfigMap is connected to the application via Helm.
- HPA dynamically scales the number of pods.

#### Acceptance Criteria

1. Kubernetes cluster created via Terraform and running.
2. ECR created and contains Docker image uploaded.
3. Deployment, Service and HPA created and running in cluster using helm.
4. ConfigMap created and used by application.
5. Project pushed to GitHub repository in `lesson-7` branch with documentation in `README.md`.
