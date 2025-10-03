provider "aws" {
  region = var.region
}

# Empacotamento do código da Lambda Customer
data "archive_file" "lambda_registration_customer_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "./lambda_registration_customer_code.zip"
}

resource "aws_lambda_function" "lambda_registration_customer" {
  function_name = var.lambda_name
  handler       = "lambda_registration_customer.handler"
  runtime       = var.lambda_runtime
  role          = "arn:aws:iam::975049999399:role/LabRole"

  filename         = data.archive_file.lambda_registration_customer_zip.output_path
  source_code_hash = data.archive_file.lambda_registration_customer_zip.output_base64sha256

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      USER_POOL_ID = var.user_pools["customer"]
      REGION     = var.region
    }
  }
}
