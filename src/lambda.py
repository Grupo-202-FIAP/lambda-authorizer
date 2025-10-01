import json
import os
import boto3
import jwt
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError

# --- Variáveis de Ambiente ---
USER_POOLS = os.environ.get("USER_POOLS", "")  # Ex: "customer:us-east-1_abc123,internal:us-east-1_def456"
JWT_SECRET = os.environ.get("JWT_SECRET")
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
INTERNAL_APP_CLIENT_ID = os.environ.get("INTERNAL_APP_CLIENT_ID")  # necessário para login real

# Converte USER_POOLS em dict { "customer": "id", "internal": "id" }
POOL_MAP = dict(item.split(":") for item in USER_POOLS.split(",") if ":" in item)

cognito_client = boto3.client("cognito-identity-provider", region_name=AWS_REGION)


def handler(event, context):
    """
    Lambda que trata autenticação por CPF (customer) ou Email+Senha (internal),
    consultando a user pool correta e emitindo um JWT ou retornando tokens Cognito.
    """

    # 1. Parse da request
    try:
        body = json.loads(event.get("body", "{}"))
    except json.JSONDecodeError:
        return _response(400, {"message": "Corpo inválido: precisa ser JSON"})

    cpf = body.get("cpf")
    email = body.get("email")
    password = body.get("password")  # necessário para login via email

    if not cpf and not email:
        return _response(400, {"message": "Obrigatório enviar CPF ou Email"})

    try:
        # 2. Se for CPF → pool customer (fluxo custom)
        if cpf:
            user_pool_id = POOL_MAP.get("customer")
            if not user_pool_id:
                return _response(500, {"message": "User pool de customer não configurada"})

            response = cognito_client.list_users(
                UserPoolId=user_pool_id,
                Filter=f'username = "{cpf}"',
                Limit=1
            )
            role = "ROLE_CUSTOMER"

            users = response.get("Users", [])
            if not users:
                return _response(404, {"message": "Cliente não encontrado"})

            user = users[0]

            # Cria JWT custom
            payload = {
                "sub": user["Username"],
                "role": role,
                "userPoolId": user_pool_id,
                "iat": int(datetime.now(timezone.utc).timestamp()),
                "exp": int((datetime.now(timezone.utc) + timedelta(hours=1)).timestamp())
            }
            token = jwt.encode(payload, JWT_SECRET, algorithm="HS256")

            return _response(200, {
                "message": "Autenticação por CPF bem-sucedida",
                "token": token,
                "userId": user["Username"]
            })

        # 3. Se for Email → pool internal (login real)
        elif email:
            if not password:
                return _response(400, {"message": "Obrigatório enviar password para login por email"})

            user_pool_id = POOL_MAP.get("internal")
            if not user_pool_id:
                return _response(500, {"message": "User pool de internal não configurada"})
            if not INTERNAL_APP_CLIENT_ID:
                return _response(500, {"message": "App Client ID interno não configurado"})

            # Autenticação real no Cognito
            response = cognito_client.admin_initiate_auth(
                UserPoolId=user_pool_id,
                ClientId=INTERNAL_APP_CLIENT_ID,
                AuthFlow="ADMIN_USER_PASSWORD_AUTH",
                AuthParameters={
                    "USERNAME": email,
                    "PASSWORD": password
                }
            )

            auth_result = response.get("AuthenticationResult", {})
            if not auth_result:
                return _response(401, {"message": "Falha na autenticação"})

            role = "ROLE_EMPLOYEE"  # ou ROLE_ADMIN dependendo da lógica

            return _response(200, {
                "message": "Login por email bem-sucedido",
                "idToken": auth_result.get("IdToken"),
                "accessToken": auth_result.get("AccessToken"),
                "refreshToken": auth_result.get("RefreshToken"),
                "role": role
            })

    except ClientError as e:
        print(f"Erro Cognito: {e}")
        return _response(500, {"message": "Erro ao consultar Cognito"})
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
