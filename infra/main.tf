module "cognito" {
  source = "./modules/cognito"

  user_pool_name     = "backend-app-user-pool"
  default_user_email = "admin@example.com"
}
