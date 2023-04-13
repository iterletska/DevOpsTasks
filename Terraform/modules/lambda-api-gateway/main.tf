# Generates an archive from content, a file, or directory of files

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_dir = "${path.module}/${var.source_dir}"
  output_path = "${path.module}/tmp/python.zip"
}
# In terraform ${path.module} is the current directory

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "/aws/lambda/${aws_lambda_function.lambda_api_gateway.function_name}"
  retention_in_days = 30

  tags = {
    "created" = "terraform"
  }
}

resource "aws_iam_policy" "lambda_execution" {
  name = "lambda_execution_${var.function_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:*"
      },
      {
        Action   = ["logs:CreateLogStream","logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudwatch_log_group.name}:*"
      },
      {
        Action   = ["sns:Publish","sns:GetTopicAttributes"]
        Effect   = "Allow"
        Resource = "arn:aws:sns:${var.region}:${var.account_id}:*"
      },
      {
        Action   = ["sns:ListTopics"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_execution" {
  name = "lambda_execution_${var.function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  policy_arn = aws_iam_policy.lambda_execution.arn
  role       = aws_iam_role.lambda_execution.name
}

# Create the Lambda function
resource "aws_lambda_function" "lambda_api_gateway" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_execution.arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = data.archive_file.lambda_archive.output_path
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "healthcheck_api" {
  name = "healthcheck_api"
}

# Create a resource for the API Gateway
resource "aws_api_gateway_resource" "healthcheck_resource" {
  rest_api_id = aws_api_gateway_rest_api.healthcheck_api.id
  parent_id   = aws_api_gateway_rest_api.healthcheck_api.root_resource_id
  path_part   = "healthcheck"
}

# Create a method for the resource
resource "aws_api_gateway_method" "healthcheck_method" {
  rest_api_id   = aws_api_gateway_rest_api.healthcheck_api.id
  resource_id   = aws_api_gateway_resource.healthcheck_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create an integration between the method and the Lambda function
resource "aws_api_gateway_integration" "healthcheck_integration" {
  rest_api_id             = aws_api_gateway_rest_api.healthcheck_api.id
  resource_id             = aws_api_gateway_resource.healthcheck_resource.id
  http_method             = aws_api_gateway_method.healthcheck_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_api_gateway.invoke_arn
}

# # Create a deployment for the API Gateway
# resource "aws_api_gateway_deployment" "healthcheck_deployment" {
#   rest_api_id = aws_api_gateway_rest_api.healthcheck_api.id
#   stage_name  = "prod"
# }

resource "aws_lambda_permission" "lambda_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_api_gateway.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.healthcheck_api.execution_arn}/*/${aws_api_gateway_method.healthcheck_method.http_method}${aws_api_gateway_resource.healthcheck_resource.path}"
}
