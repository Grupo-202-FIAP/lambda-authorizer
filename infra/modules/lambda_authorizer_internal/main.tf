data "archive_file" "lambda_authorizer_internal_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/lambda_authorizer_internal"
  output_path = "./lambda_authorizer_internal_code.zip"
}

resource "aws_lambda_function" "lambda_authorizer_internal" {
  function_name = "${var.lambda_name}"
  handler       = "lambda_authorizer_internal.handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::975049999399:role/LabRole"
  filename         = data.archive_file.lambda_authorizer_internal_zip.output_path
  source_code_hash = data.archive_file.lambda_authorizer_internal_zip.output_base64sha256

  environment {
    variables = {
      USER_POOLS             = "internal:${var.user_pools["internal"]}"
      REGION                 = "us-east-1"
      INTERNAL_APP_CLIENT_ID = var.internal_app_client_id
    }
  }
}