provider "aws" {
  region = "us-east-1"
}

resource "aws_cognito_user_pool" "this" {
  name = "backend-app-user-pool"

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