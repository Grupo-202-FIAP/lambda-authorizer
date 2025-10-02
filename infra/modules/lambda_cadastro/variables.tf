variable "lambda_name" {
  description = "O nome da lambda para prefixar os recursos."
  type        = string
}

variable "user_pools" {
  description = "Map de user pools (ex: { customer = \"id\", internal = \"id\" })"
  type        = map(string)
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "lambda_runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_memory_size" {
  description = "Memória da Lambda"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout da Lambda em segundos"
  type        = number
  default     = 10
}

variable "lambda_source_dir" {
  description = "Caminho do código da Lambda"
  type        = string
}
