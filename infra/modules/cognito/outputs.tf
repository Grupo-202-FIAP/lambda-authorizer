# modules/cognito/outputs.tf
output "customer_user_pool_id" {
  value = aws_cognito_user_pool.customer.id
}

output "internal_user_pool_id" {
  value = aws_cognito_user_pool.internal.id
}
