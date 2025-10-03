output "user_pool_id" {
  value = aws_cognito_user_pool.internal.id
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.internal.id
}
