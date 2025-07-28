variable "postgres_user" {
  type        = string
  description = "PostgreSQL username"
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL password"
  sensitive   = true
}

variable "postgres_db" {
  type        = string
  description = "PostgreSQL database name"
}

variable "db_host" {
  type        = string
  description = "Database hostname"
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 5432
}

variable "secret_key" {
  type        = string
  description = "Django SECRET_KEY"
  sensitive   = true
}

variable "debug" {
  type        = bool
  description = "Django DEBUG setting"
  default     = false
}

variable "allowed_hosts" {
  type        = string
  description = "Comma-separated list of allowed hosts"
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

variable "grafana_admin_pass" {
  type        = string
  description = "Admin password for Grafana"
}
