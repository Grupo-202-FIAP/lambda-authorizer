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

# --- Lambda Sync Internal ---
module "lambda_sync_internal" {
  source                    = "./modules/lambda_sync_internal"
  sync_internal_handler     = var.sync_internal_handler
  sync_internal_name        = var.sync_internal_name
  sync_internal_output_path = var.sync_internal_output_path
  lambda_runtime            = var.lambda_runtime
  lambda_archive_type       = var.lambda_archive_type
  region                    = var.aws_region
  lambda_source_dir         = "${path.module}/../src/lambda_sync_internal"
  account_id                = var.account_id
  subnet_ids                = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids        = [data.terraform_remote_state.network.outputs.security_group_postgres_id]
}

resource "aws_lambda_permission" "allow_cognito_invoke_internal" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_sync_internal.lambda_sync_internal_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool_internal.cognito_internal_arn
}

# --- Lambda Sync Customer ---
module "lambda_sync_customer" {
  source                    = "./modules/lambda_sync_customer"
  sync_customer_handler     = var.sync_customer_handler
  sync_customer_name        = var.sync_customer_name
  sync_customer_output_path = var.sync_customer_output_path
  lambda_runtime            = var.lambda_runtime
  lambda_archive_type       = var.lambda_archive_type
  region                    = var.aws_region
  lambda_source_dir         = "${path.module}/../src/lambda_sync_customer"
  account_id                = var.account_id
  subnet_ids                = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids        = [data.terraform_remote_state.network.outputs.security_group_postgres_id]
}

resource "aws_lambda_permission" "allow_cognito_invoke_customer" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_sync_customer.lambda_sync_customer_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool_customer.cognito_customer_arn
}
