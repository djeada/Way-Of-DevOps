terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
  endpoints {
    s3       = "http://127.0.0.1:4566"
    sqs      = "http://127.0.0.1:4566"
    dynamodb = "http://127.0.0.1:4566"
  }
}
resource "aws_s3_bucket" "product_assets" { bucket = "floci-lab-iac-assets" }
resource "aws_sqs_queue" "orders" { name = "floci-lab-iac-orders" }
resource "aws_dynamodb_table" "products" {
  name         = "floci-lab-iac-products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute { name = "id", type = "S" }
}
output "queue_url" { value = aws_sqs_queue.orders.url }
