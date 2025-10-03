variable "lambda_name" {
  description = "Prefixo para as funções Lambda Authorizer."
  type        = string
}

variable "user_pools" {
  type = map(string)
}
