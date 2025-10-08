project_name = "backend-app"
lambda_runtime = "python3.9"
lambda_archive_type = "zip"

authorizer_customer_name = "lambda_authorizer_customer"
authorizer_customer_output_path = "./lambda_authorizer_customer_code.zip"
authorizer_customer_handler = "lambda_authorizer_customer.handler"

authorizer_internal_name = "lambda_authorizer_internal"
authorizer_internal_handler = "lambda_authorizer_internal.handler"
authorizer_internal_output_path = "./lambda_authorizer_internal_code.zip"

registration_customer_name = "lambda_registration_customer"
registration_customer_handler = "lambda_registration_customer.handler"
registration_customer_output_path = "./lambda_registration_customer_code.zip"

registration_internal_name = "lambda_registration_internal"
registration_internal_handler = "lambda_registration_internal.handler"
registration_internal_output_path = "./lambda_registration_internal_code.zip"

sync_internal_name = "lambda_sync_internal"
sync_internal_handler = "lambda_sync_internal.handler"
sync_internal_output_path = "./lambda_sync_internal_code.zip"

sync_customer_name = "lambda_sync_customer"
sync_customer_handler = "lambda_sync_customer.handler"
sync_customer_output_path = "./lambda_sync_customer_code.zip"

account_id="189094178766"

