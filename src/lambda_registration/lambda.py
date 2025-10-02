import json
import os
import boto3
from botocore.exceptions import ClientError

# --- Variáveis de Ambiente ---
USER_POOLS = os.environ.get("USER_POOLS", "customer:us-east-1_R7bhXa09B,internal:us-east-1_UNnANkTz9")  # TODO automatizar - Ex: "customer:us-east-1_abc123,internal:us-east-1_def456" TODO automatizar
REGION = os.environ.get("REGION", "us-east-1")
INTERNAL_APP_CLIENT_ID = "572r2n7ldg48vhj1tq0vq0edin"  # app client id do pool "internal"

# Converte USER_POOLS em dict { "customer": "id", "internal": "id" }
POOL_MAP = dict(item.split(":") for item in USER_POOLS.split(",") if ":" in item)

cognito_client = boto3.client("cognito-idp", region_name=REGION)

def handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
    except json.JSONDecodeError:
        return _response(400, {"message": "Corpo inválido: precisa ser JSON"})

    cpf = body.get("cpf")
    email = body.get("email")
    password = body.get("password")
    name = body.get("name")  # opcional, nome do usuário

    # Verifica se há algum campo para cadastro
    if not cpf and not email:
        return _response(400, {"message": "Obrigatório enviar CPF ou Email para cadastro"})

    try:
        # --- Cadastro CPF → Customer ---
        if cpf:
            user_pool_id = POOL_MAP.get("customer")
            if not user_pool_id:
                return _response(500, {"message": "User pool de customer não configurada"})

            # Checa se usuário já existe
            existing = cognito_client.list_users(
                UserPoolId=user_pool_id,
                Filter=f'username = "{cpf}"',
                Limit=1
            )
            if existing.get("Users"):
                return _response(409, {"message": "Cliente já cadastrado"})

            # Cria usuário na pool
            response = cognito_client.admin_create_user(
                UserPoolId=user_pool_id,
                Username=cpf,
                UserAttributes=[
                    {"Name": "custom:cpf", "Value": cpf}
                ],
                MessageAction="SUPPRESS"  # Não enviar e-mail automático
            )

            return _response(201, {
                "message": "Cliente cadastrado com sucesso",
                "userId": response["User"]["Username"]
            })

        # --- Cadastro Email + Senha → Internal ---
        elif email:
            if not password:
                return _response(400, {"message": "Obrigatório enviar password para cadastro por email"})

            user_pool_id = POOL_MAP.get("internal")
            if not user_pool_id:
                return _response(500, {"message": "User pool de internal não configurada"})
            if not INTERNAL_APP_CLIENT_ID:
                return _response(500, {"message": "App Client ID interno não configurado"})

            # Cria usuário
            response = cognito_client.admin_create_user(
                UserPoolId=user_pool_id,
                Username=email,
                UserAttributes=[
                    {"Name": "email", "Value": email},
                    {"Name": "email_verified", "Value": "true"},
                    {"Name": "name", "Value": name} if name else {}
                ],
                TemporaryPassword=password,
                MessageAction="SUPPRESS"  # Não envia e-mail automático
            )

            # Força o usuário a definir a senha real imediatamente
            challenge_resp = cognito_client.admin_initiate_auth(
                UserPoolId=user_pool_id,
                ClientId=INTERNAL_APP_CLIENT_ID,
                AuthFlow="ADMIN_USER_PASSWORD_AUTH",
                AuthParameters={
                    "USERNAME": email,
                    "PASSWORD": password
                }
            )

            return _response(201, {
                "message": "Usuário interno cadastrado com sucesso",
                "username": response["User"]["Username"],
                "challenge": challenge_resp.get("ChallengeName")
            })

    except ClientError as e:
        print(f"Erro Cognito: {e}")
        return _response(500, {"message": f"Erro Cognito: {e}"})
    except Exception as e:
        print(f"Erro interno: {e}")
        return _response(500, {"message": "Erro interno do servidor"})

def _response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
