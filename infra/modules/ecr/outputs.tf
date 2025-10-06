output "repository_urls" {
  description = "URLs dos repositórios ECR criados"
  value = {
    for name, repo in aws_ecr_repository.repositories : name => repo.repository_url
  }
}

output "repository_arns" {
  description = "ARNs dos repositórios ECR criados"
  value = {
    for name, repo in aws_ecr_repository.repositories : name => repo.arn
  }
}

output "repository_names" {
  description = "Nomes dos repositórios ECR criados"
  value = {
    for name, repo in aws_ecr_repository.repositories : name => repo.name
  }
}

output "registry_id" {
  description = "ID do registry ECR"
  value       = element([for repo in aws_ecr_repository.repositories : repo.registry_id], 0)
}