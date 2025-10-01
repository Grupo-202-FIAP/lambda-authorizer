output "user_pool_id" {
  description = "O ID do Cognito User Pool."
  value       = aws_cognito_user_pool.main.id
}

output "customer_app_client_id" {
  description = "O ID do App Client para clientes."
  value       = aws_cognito_user_pool_client.customer.id
}

output "internal_app_client_id" {
  description = "O ID do App Client para usuários internos (Employee/Admin)."
  value       = aws_cognito_user_pool_client.internal.id
}