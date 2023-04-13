terraform {
  backend "s3" {
    bucket = "iterlebucket"
    key    = "lambda-api-gateway/terraform.tfstate"
    region = "us-east-1"
  }
}