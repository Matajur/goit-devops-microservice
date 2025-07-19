output "s3_bucket_name" {
  description = "S3 bucket name for states"
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value = aws_dynamodb_table.terraform_locks.id
}
