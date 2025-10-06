output "lambda_sync_customer_name" {
  description = "Nome da Lambda Sync Internal"
  value       = aws_lambda_function.lambda_sync_customer.function_name
}

output "lambda_sync_customer_invoke_arn" {
  description = "ARN para invocação da Lambda Sync Internal"
  value       = aws_lambda_function.lambda_sync_customer.invoke_arn
}
