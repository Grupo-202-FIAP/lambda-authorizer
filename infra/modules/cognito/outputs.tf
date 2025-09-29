output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.this.id
}

output "employee_group" {
  value = aws_cognito_user_group.employee.name
}

output "customer_group" {
  value = aws_cognito_user_group.customer.name
}

output "guest_group" {
  value = aws_cognito_user_group.guest.name
}
