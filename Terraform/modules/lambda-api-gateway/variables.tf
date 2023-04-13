variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type    = string
  default = "883126580074"
}

variable "source_dir" {
  type    = string
  default = "files"
}

variable "function_name" {
  type    = string
  default = "lambda_health_check"
}

variable "handler" {
  type    = string
  default = "health_check.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.8"
}