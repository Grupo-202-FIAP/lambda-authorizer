data "archive_file" "lambda_authorizer_zip" {
  type        = "zip"
  source_dir  = "../../../src/"
  output_path = "../../../src.zip"
}

resource "aws_iam_role" "lambda_authorizer_role" {
  name = var.lambda_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_authorizer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_authorizer" {
  function_name = var.lambda_name
  handler       = "lambda.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_authorizer_role.arn
  filename         = data.archive_file.lambda_authorizer_zip.output_path
  source_code_hash = data.archive_file.lambda_authorizer_zip.output_base64sha256

  environment {
    variables = {
      USER_POOL_ID = var.user_pool_id
    }
  }
}