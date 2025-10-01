variable "lambda_name" {
  description = "O nome da lambda para prefixar os recursos."
  type        = string
}

variable "user_pool_id" {
  description = "O ID do User Pool do Cognito para validação de tokens."
  type        = string
}
