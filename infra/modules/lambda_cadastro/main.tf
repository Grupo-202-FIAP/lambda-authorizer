provider "aws" {
  region = var.region
}

# Empacotamento do código
data "archive_file" "lambda_registration_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "./lambda_registration_code.zip"
}

# Lambda de cadastro
resource "aws_lambda_function" "lambda_registration" {
  function_name = var.lambda_name
  handler       = "lambda.handler"
  runtime       = var.lambda_runtime
  role          = "arn:aws:iam::975049999399:role/LabRole" # LabRole para contas de estudante
  filename         = data.archive_file.lambda_registration_zip.output_path
  source_code_hash = data.archive_file.lambda_registration_zip.output_base64sha256

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      USER_POOLS = "customer:${var.user_pools["customer"]},internal:${var.user_pools["internal"]}"
      REGION     = var.region
    }
  }
}
