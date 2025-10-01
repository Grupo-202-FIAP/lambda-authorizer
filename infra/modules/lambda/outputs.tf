output "lambda_authorizer_name" {
  description = "O nome da função Lambda Authorizer."
  value       = aws_lambda_function.lambda_authorizer.function_name
}

output "lambda_authorizer_invoke_arn" {
  description = "O ARN da função Lambda Authorizer para invocação."
  value       = aws_lambda_function.lambda_authorizer.invoke_arn
}