variable "lambda_name" {
  description = "O nome da lambda para prefixar os recursos."
  type        = string
}

variable "user_pools" {
  type = map(string)
}
