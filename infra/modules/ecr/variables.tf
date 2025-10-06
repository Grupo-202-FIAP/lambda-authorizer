variable "project_name" {
  description = "Nome do projeto ou aplicação principal (usado para prefixar recursos)."
  type        = string
}

variable "account_id" {
  description = "ID da conta AWS onde os recursos serão criados."
  type        = string
}

variable "repositories" {
  description = "Lista de repositórios ECR a serem criados"
  type = list(object({
    name                 = string
    image_tag_mutability = string
    scan_on_push         = bool
  }))
  default = [
    {
      name                 = "lambda-authorizer-customer"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    },
    {
      name                 = "lambda-authorizer-internal"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    },
    {
      name                 = "lambda-registration-customer"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    },
    {
      name                 = "lambda-registration-internal"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    },
    {
      name                 = "lambda-sync-customer"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    },
    {
      name                 = "lambda-sync-internal"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    }
  ]
}