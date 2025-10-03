variable "lambda_name" {
  description = "Nome da Lambda Registration Customer"
  type        = string
}

variable "lambda_source_dir" {
  description = "Diretório do código da Lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "python3.9"
}

variable "lambda_memory_size" {
  description = "Memória da Lambda"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout da Lambda"
  type        = number
  default     = 10
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "user_pools" {
  description = "Mapeamento dos user pools"
  type        = map(string)
}
