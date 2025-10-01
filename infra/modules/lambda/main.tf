data "archive_file" "lambda_authorizer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/"
  output_path = "./lambda_authorizer_code.zip"
}

# resource "aws_iam_role_policy_attachment" "lambda_logs" {
#   role       = "LabRole"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

resource "aws_lambda_function" "lambda_authorizer" {
  function_name = var.lambda_name
  handler       = "lambda.handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::975049999399:role/LabRole"
  filename         = data.archive_file.lambda_authorizer_zip.output_path
  source_code_hash = data.archive_file.lambda_authorizer_zip.output_base64sha256

  environment {
    variables = {
      USER_POOL_ID = var.user_pool_id
    }
  }
}