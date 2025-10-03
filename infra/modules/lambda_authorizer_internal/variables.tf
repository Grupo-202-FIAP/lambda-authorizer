variable "lambda_name" {
  description = "Prefixo para as funções Lambda Authorizer."
  type        = string
}

variable "user_pools" {
  description = "Mapa com os IDs dos user pools."
  type        = map(string)
}

variable "internal_app_client_id" {
  description = "App Client ID do pool internal."
  type        = string
}