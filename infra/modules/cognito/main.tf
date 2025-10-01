resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"

  # Configuração de Login
  # Cognito exige pelo menos um atributo para login.
  # Usuários internos usam EMAIL.
  # Usuários externos podem usar CPF (que pode ser mapeado como um atributo customizado) ou e-mail/nome.
  # Vamos definir 'email' como atributo de login padrão, mas permitiremos logins sem e-mail verificado.
  username_attributes = ["email"]

  # Como ROLE_CUSTOMER pode usar CPF, podemos permitir o login com um atributo customizado, mas
  # para simplificar a criação inicial, focaremos no EMAIL/SENHA para o Cognito, e trataremos
  # o login por CPF no fluxo de autenticação (Lambda Authorizer ou um pré-autenticação)

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_group" "customer" {
  name         = "ROLE_CUSTOMER"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_group" "employee" {
  name         = "ROLE_EMPLOYEE"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_group" "admin" {
  name         = "ROLE_ADMIN"
  user_pool_id = aws_cognito_user_pool.main.id
}

# ROLE_GUEST não precisa de um grupo no Cognito, pois são usuários não autenticados/não cadastrados.
# O Guest Access geralmente é controlado na aplicação por ausência de um token JWT válido.

resource "aws_cognito_user_pool_client" "internal" {
  name         = var.internal_app_client_name
  user_pool_id = aws_cognito_user_pool.main.id

  # Habilitamos o fluxo de autenticação SECURE REMOTE PASSWORD (SRP) - Padrão de segurança
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  # Não gerar segredo para apps front-end ou mobile (é mais seguro)
  generate_secret = false
}

# 4. App Client para Usuários Clientes (Customer) - Login mais flexível
resource "aws_cognito_user_pool_client" "customer" {
  name         = var.customer_app_client_name
  user_pool_id = aws_cognito_user_pool.main.id

  # Permite o fluxo de login personalizado.
  # O login por 'CPF' (ROLE_CUSTOMER) é um caso especial que você deve implementar
  # usando um **Custom Auth Flow** no Cognito, chamando seu Lambda Authorizer
  # ou um Lambda de 'Custom Authentication Challenge'.
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_CUSTOM_AUTH"]

  generate_secret = false
}