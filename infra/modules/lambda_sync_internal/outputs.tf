output "lambda_sync_internal_name" {
  description = "Nome da Lambda Sync Internal"
  value       = aws_lambda_function.lambda_sync_internal.function_name
}

output "lambda_sync_internal_invoke_arn" {
  description = "ARN para invocação da Lambda Sync Internal"
  value       = aws_lambda_function.lambda_sync_internal.invoke_arn
}
