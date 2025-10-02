module "cognito" {
  source = "./modules/cognito"

  project_name = "backend-app"
}

module "lambda" {
  source = "./modules/lambda"

  lambda_name   = "lambda_authorizer"
  user_pools = {
    customer = module.cognito.customer_user_pool_id
    internal = module.cognito.internal_user_pool_id
  }
}

module "lambda_registration" {
  source = "./modules/lambda_cadastro"

  lambda_name   = "lambda_registration"
  lambda_source_dir = "${path.module}/../src/lambda_registration" # pasta com o código Python da Lambda
  user_pools = {
    customer = module.cognito.customer_user_pool_id
    internal = module.cognito.internal_user_pool_id
  }
}