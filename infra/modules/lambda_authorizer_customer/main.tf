data "archive_file" "lambda_authorizer_customer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/lambda_authorizer_customer"
  output_path = "./lambda_authorizer_customer_code.zip"
}

resource "aws_lambda_function" "lambda_authorizer_customer" {
  function_name = "${var.lambda_name}"
  handler       = "lambda_authorizer_customer.handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::975049999399:role/LabRole"
  filename         = data.archive_file.lambda_authorizer_customer_zip.output_path
  source_code_hash = data.archive_file.lambda_authorizer_customer_zip.output_base64sha256

  environment {
    variables = {
      USER_POOLS = "customer:${var.user_pools["customer"]}"
      REGION     = "us-east-1"
      JWT_SECRET = "TESTE_SECRET" # ideal usar AWS Secrets Manager
    }
  }
}