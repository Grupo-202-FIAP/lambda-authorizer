# ECR Outputs
output "ecr_repository_urls" {
  description = "URLs dos repositórios ECR criados"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ARNs dos repositórios ECR criados"
  value       = module.ecr.repository_arns
}

output "ecr_repository_names" {
  description = "Nomes dos repositórios ECR criados"
  value       = module.ecr.repository_names
}

output "ecr_registry_id" {
  description = "ID do registry ECR"
  value       = module.ecr.registry_id
}

# Cognito Outputs
output "cognito_customer_user_pool_id" {
  description = "ID do User Pool do Cognito para clientes"
  value       = module.cognito_user_pool_customer.user_pool_id
  sensitive   = false
}

output "cognito_customer_user_pool_client_id" {
  description = "ID do cliente do User Pool do Cognito para clientes"
  value       = module.cognito_user_pool_customer.user_pool_client_id
  sensitive   = false
}

output "cognito_internal_user_pool_id" {
  description = "ID do User Pool do Cognito para usuários internos"
  value       = module.cognito_user_pool_internal.user_pool_id
  sensitive   = false
}

output "cognito_internal_user_pool_client_id" {
  description = "ID do cliente do User Pool do Cognito para usuários internos"
  value       = module.cognito_user_pool_internal.user_pool_client_id
  sensitive   = false
}
