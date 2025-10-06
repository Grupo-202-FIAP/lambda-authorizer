variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto ou aplicação principal (usado para prefixar recursos)."
  type        = string
}

variable "account_id" {
  description = "ID da conta AWS onde os recursos serão criados."
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime do AWS Lambda a ser usado (ex: python3.9)."
  type        = string
}

variable "authorizer_customer_name" {
  description = "Nome da função Lambda Authorizer para clientes externos."
  type        = string
}

variable "authorizer_customer_output_path" {
  description = "Caminho local para o arquivo .zip de deploy do Authorizer Customer."
  type        = string
}

variable "authorizer_customer_handler" {
  description = "Nome do handler da função Authorizer Customer (ex: arquivo.funcao)."
  type        = string
}

variable "authorizer_internal_name" {
  description = "Nome da função Lambda Authorizer para usuários internos/admin."
  type        = string
}

variable "authorizer_internal_output_path" {
  description = "Caminho local para o arquivo .zip de deploy do Authorizer Internal."
  type        = string
}

variable "authorizer_internal_handler" {
  description = "Nome do handler da função Authorizer Internal."
  type        = string
}

variable "registration_customer_name" {
  description = "Nome da função Lambda para o registro de clientes externos."
  type        = string
}

variable "lambda_archive_type" {
  description = "Tipo de arquivo do pacote de código Lambda (ex: zip, Image)."
  type        = string
}

variable "registration_customer_output_path" {
  description = "Caminho local para o arquivo .zip de deploy do Registration Customer."
  type        = string
}

variable "registration_customer_handler" {
  description = "Nome do handler da função Registration Customer."
  type        = string
}

variable "registration_internal_name" {
  description = "Nome da função Lambda para o registro de usuários internos/admin."
  type        = string
}

variable "registration_internal_output_path" {
  description = "Caminho local para o arquivo .zip de deploy do Registration Internal."
  type        = string
}

variable "registration_internal_handler" {
  description = "Nome do handler da função Registration Internal."
  type        = string
}

variable "sync_internal_name" {
  description = "Nome da função Lambda para o registro de usuários internos/admin."
  type        = string
}

variable "sync_internal_output_path" {
  description = "Caminho local para o arquivo .zip de deploy do Sync Internal."
  type        = string
}

variable "sync_internal_handler" {
  description = "Nome do handler da função Sync Internal."
  type        = string
}

variable "sync_customer_name" {
  description = "Nome da função Lambda para o sync de usuários"
  type        = string
}

variable "sync_customer_output_path" {
  description = "Caminho local para o arquivo .zip de deploy do Sync Internal."
  type        = string
}

variable "sync_customer_handler" {
  description = "Nome do handler da função Sync Internal."
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets privadas para rodar a Lambda dentro da VPC"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lista de Security Groups que a Lambda deve usar"
  type        = list(string)
}

