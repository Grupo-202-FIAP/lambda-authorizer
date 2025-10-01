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

