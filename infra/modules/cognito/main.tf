resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "cpf"
    attribute_data_type = "String"
    mutable             = false
    string_attribute_constraints {
      min_length = 11
      max_length = 14
    }
  }
}

# App client
resource "aws_cognito_user_pool_client" "this" {
  name           = "${var.user_pool_name}-client"
  user_pool_id   = aws_cognito_user_pool.this.id
  generate_secret = false
}

# Groups
resource "aws_cognito_user_group" "employee" {
  name         = "employee"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Grupo de funcionários"
}

resource "aws_cognito_user_group" "customer" {
  name         = "customer"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Grupo de clientes"
}

resource "aws_cognito_user_group" "guest" {
  name         = "guest"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Grupo de usuários convidados"
}

# Usuário padrão
resource "aws_cognito_user" "default_user" {
  user_pool_id = aws_cognito_user_pool.this.id
  username     = var.default_user_email

  attributes = {
    email = var.default_user_email
    name  = "Default User"
    cpf   = "00000000000"
  }
}
