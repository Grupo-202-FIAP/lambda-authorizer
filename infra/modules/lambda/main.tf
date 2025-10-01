data "archive_file" "lambda_authorizer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/"
  output_path = "./lambda_authorizer_code.zip"
}

resource "aws_lambda_function" "lambda_authorizer" {
  function_name = var.lambda_name
  handler       = "lambda.handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::975049999399:role/LabRole"
  filename         = data.archive_file.lambda_authorizer_zip.output_path
  source_code_hash = data.archive_file.lambda_authorizer_zip.output_base64sha256

  environment {
    variables = {
      USER_POOLS = "customer:${var.user_pools["customer"]},internal:${var.user_pools["internal"]}"
      REGION = "us-east-1"
    }

  }
}