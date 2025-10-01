module "cognito" {
  source = "./modules/cognito"

  project_name = "backend-app"
}


module "lambda" {
  source = "./modules/lambda"

  lambda_name       = "lambda_authorizer"
  user_pool_id       = module.cognito.user_pool_id
}
