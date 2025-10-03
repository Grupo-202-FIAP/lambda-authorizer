provider "aws" {
  region = var.region
}

# Empacotamento do código da Lambda Internal
data "archive_file" "lambda_registration_internal_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "./lambda_registration_internal_code.zip"
}

resource "aws_lambda_function" "lambda_registration_internal" {
  function_name = var.lambda_name
  handler       = "lambda_registration_internal.handler"
  runtime       = var.lambda_runtime
  role          = "arn:aws:iam::975049999399:role/LabRole"

  filename         = data.archive_file.lambda_registration_internal_zip.output_path
  source_code_hash = data.archive_file.lambda_registration_internal_zip.output_base64sha256

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      USER_POOL_ID = var.user_pools["internal"]
      INTERNAL_APP_CLIENT_ID = var.internal_app_client_id
      REGION     = var.region
    }
  }
}
