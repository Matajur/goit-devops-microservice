output "vpc_id" {
  description = "Virtual Privat Cloud ID for state locking"
  value = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "URL of the repository for Elastic Container Registry"
  value = module.ecr.repository_url
}

output "s3_bucket_name" {
  description = "S3 bucket name for states"
  value = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value = module.s3_backend.dynamodb_table_name
}
