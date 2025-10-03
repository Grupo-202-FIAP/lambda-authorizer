module "cognito_user_pool_customer" {
  source       = "./modules/cognito_user_pool_customer"
  project_name = var.project_name
}

module "cognito_user_pool_internal" {
  source       = "./modules/cognito_user_pool_internal"
  project_name = var.project_name
}

# --- Lambda Authorizer Customer ---
module "lambda_authorizer_customer" {
  source                          = "./modules/lambda_authorizer_customer"
  authorizer_customer_name        = var.authorizer_customer_name
  authorizer_customer_handler     = var.authorizer_customer_handler
  authorizer_customer_output_path = var.authorizer_customer_output_path
  lambda_runtime                  = var.lambda_runtime
  lambda_archive_type             = var.lambda_archive_type
  region                          = var.aws_region
  account_id                      = var.account_id
  user_pools = {
    customer = module.cognito_user_pool_customer.user_pool_id
  }
}

# --- Lambda Authorizer Internal ---
module "lambda_authorizer_internal" {
  source                          = "./modules/lambda_authorizer_internal"
  authorizer_internal_name        = var.authorizer_internal_name
  authorizer_internal_handler     = var.authorizer_internal_handler
  authorizer_internal_output_path = var.authorizer_internal_output_path
  lambda_runtime                  = var.lambda_runtime
  lambda_archive_type             = var.lambda_archive_type
  region                          = var.aws_region
  account_id                      = var.account_id
  user_pools = {
    internal = module.cognito_user_pool_internal.user_pool_id
  }

  internal_app_client_id = module.cognito_user_pool_internal.app_client_id
}

# --- Lambda Registration Customer ---
module "lambda_registration_customer" {
  source                            = "./modules/lambda_registration_customer"
  registration_customer_handler     = var.registration_customer_handler
  registration_customer_name        = var.registration_customer_name
  registration_customer_output_path = var.registration_customer_output_path
  lambda_runtime                    = var.lambda_runtime
  lambda_archive_type               = var.lambda_archive_type
  region                            = var.aws_region
  lambda_source_dir                 = "${path.module}/../src/lambda_registration_customer"
  account_id                        = var.account_id
  user_pools = {
    customer = module.cognito_user_pool_customer.user_pool_id
  }
}

# --- Lambda Registration Internal ---
module "lambda_registration_internal" {
  source                            = "./modules/lambda_registration_internal"
  registration_internal_handler     = var.registration_internal_handler
  registration_internal_name        = var.registration_internal_name
  registration_internal_output_path = var.registration_internal_output_path
  lambda_runtime                    = var.lambda_runtime
  lambda_archive_type               = var.lambda_archive_type
  region                            = var.aws_region
  lambda_source_dir                 = "${path.module}/../src/lambda_registration_internal"
  account_id                        = var.account_id
  user_pools = {
    internal = module.cognito_user_pool_internal.user_pool_id
  }
  internal_app_client_id = module.cognito_user_pool_internal.app_client_id
}
