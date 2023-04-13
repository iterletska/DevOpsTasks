provider "aws" {
  alias = "prod"
  region = var.region
}


module "lambda-api-gateway" {
  source   = "./modules/lambda-api-gateway"
  providers = {
         aws = aws.prod
     }
  function_name = var.function_name
  handler = var.handler
  runtime = var.runtime
  account_id = var.account_id

}