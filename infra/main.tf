module "cognito_user_pool_customer" {
  source = "./modules/cognito_user_pool_customer"
  project_name = "backend-app"
}

module "cognito_user_pool_internal" {
  source = "./modules/cognito_user_pool_internal"
  project_name = "backend-app"
}

# --- Lambda Authorizer Customer ---
module "lambda_authorizer_customer" {
  source = "./modules/lambda_authorizer_customer"

  lambda_name = "lambda_authorizer_customer"
  user_pools = {
    customer = module.cognito_user_pool_customer.user_pool_id
  }
  # JWT_SECRET poderia vir de Secrets Manager/SSM
}

# --- Lambda Authorizer Internal ---
module "lambda_authorizer_internal" {
  source = "./modules/lambda_authorizer_internal"

  lambda_name = "lambda_authorizer_internal"
  user_pools = {
    internal = module.cognito_user_pool_internal.user_pool_id
  }

  internal_app_client_id = module.cognito_user_pool_internal.app_client_id
}


# --- Lambda Registration Customer ---
module "lambda_registration_customer" {
  source = "./modules/lambda_registration_customer"

  lambda_name       = "lambda_registration_customer"
  lambda_source_dir = "${path.module}/../src/lambda_registration_customer"
  user_pools = {
    customer = module.cognito_user_pool_customer.user_pool_id
  }
}

# --- Lambda Registration Internal ---
module "lambda_registration_internal" {
  source = "./modules/lambda_registration_internal"

  lambda_name           = "lambda_registration_internal"
  lambda_source_dir     = "${path.module}/../src/lambda_registration_internal"
  user_pools = {
    internal = module.cognito_user_pool_internal.user_pool_id
  }
  internal_app_client_id = module.cognito_user_pool_internal.app_client_id
}
