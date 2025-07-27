variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for deploying Jenkins"
  type        = string
  default     = "jenkins"
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL"
  type        = string
}

variable "jenkins_admin_user" {
  type        = string
  description = "Admin username for Jenkins"
}

variable "jenkins_admin_pass" {
  type        = string
  description = "Admin password for Jenkins"
}

variable "github_username" {
  type        = string
  description = "GitHub username for Jenkins pipeline"
}

variable "github_token" {
  type        = string
  description = "GitHub token (personal access token)"
  sensitive   = true
}

variable "github_repo_url" {
  description = "The URL of the GitHub repository containing the Django app"
  type        = string
}

variable "github_branch" {
  description = "The branch to track in the GitHub repository"
  type        = string
}
