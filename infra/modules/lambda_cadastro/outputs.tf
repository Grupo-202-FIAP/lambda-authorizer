output "lambda_registration_name" {
  description = "O nome da função Lambda de cadastro"
  value       = aws_lambda_function.lambda_registration.function_name
}

output "lambda_registration_invoke_arn" {
  description = "O ARN da função Lambda de cadastro para invocação"
  value       = aws_lambda_function.lambda_registration.invoke_arn
}
