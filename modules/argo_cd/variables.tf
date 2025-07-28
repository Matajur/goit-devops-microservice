variable "name" {
  description = "Helm release name"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Chart Version"
  type        = string
  default     = "5.46.4" 
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
