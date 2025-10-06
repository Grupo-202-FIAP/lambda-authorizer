module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  account_id   = var.account_id
}

module "cognito_user_pool_customer" {
  source            = "./modules/cognito_user_pool_customer"
  project_name      = var.project_name
  post_confirmation = module.lambda_sync_customer.lambda_sync_customer_arn
}

module "cognito_user_pool_internal" {
  source            = "./modules/cognito_user_pool_internal"
  project_name      = var.project_name
  post_confirmation = module.lambda_sync_internal.lambda_sync_internal_arn
}


