terraform {
  backend "s3" {
    bucket         = "lesson-5-state-bucket"          # S3 bucket name
    key            = "lesson-5/terraform.tfstate"     # Path to the state file
    region         = "eu-central-1"                   # AWS Region
    dynamodb_table = "terraform-locks"                # DynamoDB table name
    encrypt        = true                             # State file encryption
  }
}
