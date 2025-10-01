###############################################
# USER POOL - CUSTOMER (Login via CPF)
###############################################
resource "aws_cognito_user_pool" "customer" {
  name = "${var.project_name}-customer-pool"

  # Login por CPF (custom auth)
  username_attributes = [] # Desabilitamos email/phone como username
  auto_verified_attributes = [] # Não verifica email automático

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  # Atributo customizado CPF
  schema {
    name                       = "custom:cpf"
    attribute_data_type        = "String"
    developer_only_attribute   = false
    mutable                    = false
    required                   = false # não pode ser true no custom
    string_attribute_constraints {
      min_length = 11
      max_length = 14
    }
  }
}

# App Client para Customer
resource "aws_cognito_user_pool_client" "customer" {
  name         = var.customer_app_client_name
  user_pool_id = aws_cognito_user_pool.customer.id

  # Habilita custom auth (para autenticação via CPF)
  explicit_auth_flows = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  generate_secret = false
}

# Grupo para Customer
resource "aws_cognito_user_group" "customer" {
  name         = "ROLE_CUSTOMER"
  user_pool_id = aws_cognito_user_pool.customer.id
}


###############################################
# USER POOL - INTERNAL (Employee/Admin via EMAIL)
###############################################
resource "aws_cognito_user_pool" "internal" {
  name = "${var.project_name}-internal-pool"

  # Login via email
  username_attributes = ["email"]

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }
}

# App Client para Employee/Admin
resource "aws_cognito_user_pool_client" "internal" {
  name         = var.internal_app_client_name
  user_pool_id = aws_cognito_user_pool.internal.id

  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  generate_secret = false
}

# Grupos para Internal
resource "aws_cognito_user_group" "employee" {
  name         = "ROLE_EMPLOYEE"
  user_pool_id = aws_cognito_user_pool.internal.id
}

resource "aws_cognito_user_group" "admin" {
  name         = "ROLE_ADMIN"
  user_pool_id = aws_cognito_user_pool.internal.id
}