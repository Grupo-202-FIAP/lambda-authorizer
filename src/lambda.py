import json
import os
import boto3
import jwt
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError

# --- Variáveis de Ambiente ---
USER_POOLS = os.environ.get("USER_POOLS", "customer:us-east-1_R7bhXa09B,internal:us-east-1_UNnANkTz9")  # TODO automatizar - Ex: "customer:us-east-1_abc123,internal:us-east-1_def456" TODO automatizar
JWT_SECRET = "TESTE_SECRET"      # TODO criar secret na organizacao segredo usado para assinar JWT (fluxo CPF)
REGION = os.environ.get("REGION", "us-east-1")
INTERNAL_APP_CLIENT_ID = "572r2n7ldg48vhj1tq0vq0edin"  # TODO automatizar - app client id do pool "internal"

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
    new_password = body.get("new_password")  # senha para trocar caso NEW_PASSWORD_REQUIRED

    # Verifica se há algum campo para autenticação
    if not cpf and not email:
        return _response(400, {"message": "Obrigatório enviar CPF ou Email"})

    try:
        # LOGIN POR CPF → customer
        if cpf:
            user_pool_id = POOL_MAP.get("customer")
            if not user_pool_id:
                return _response(500, {"message": "User pool de customer não configurada"})

            response = cognito_client.list_users(
                UserPoolId=user_pool_id,
                Filter=f'username = "{cpf}"',
                Limit=1
            )
            users = response.get("Users", [])
            if not users:
                return _response(404, {"message": "Cliente não encontrado"})

            user = users[0]
            payload = {
                "sub": user["Username"],
                "role": "ROLE_CUSTOMER",
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

        # LOGIN POR EMAIL + SENHA → internal
        elif email:
            if not password:
                return _response(400, {"message": "Obrigatório enviar password para login por email"})

            user_pool_id = POOL_MAP.get("internal")
            if not user_pool_id:
                return _response(500, {"message": "User pool de internal não configurada"})
            if not INTERNAL_APP_CLIENT_ID:
                return _response(500, {"message": "App Client ID interno não configurado"})

            # Inicia autenticação
            response = cognito_client.admin_initiate_auth(
                UserPoolId=user_pool_id,
                ClientId=INTERNAL_APP_CLIENT_ID,
                AuthFlow="ADMIN_USER_PASSWORD_AUTH",
                AuthParameters={
                    "USERNAME": email,
                    "PASSWORD": password
                }
            )

            # Se o usuário precisa trocar a senha temporária
            if response.get("ChallengeName") == "NEW_PASSWORD_REQUIRED":
                if not new_password:
                    return _response(403, {
                        "message": "Usuário precisa trocar a senha",
                        "challenge": "NEW_PASSWORD_REQUIRED",
                        "session": response.get("Session")
                    })
                # Responde ao desafio com a nova senha
                challenge_resp = cognito_client.admin_respond_to_auth_challenge(
                    UserPoolId=user_pool_id,
                    ClientId=INTERNAL_APP_CLIENT_ID,
                    ChallengeName="NEW_PASSWORD_REQUIRED",
                    ChallengeResponses={
                        "USERNAME": email,
                        "NEW_PASSWORD": new_password
                    },
                    Session=response["Session"]
                )
                auth_result = challenge_resp.get("AuthenticationResult")
            else:
                auth_result = response.get("AuthenticationResult")

            if not auth_result:
                return _response(401, {"message": "Falha na autenticação"})

            return _response(200, {
                "message": "Login por email bem-sucedido",
                "idToken": auth_result.get("IdToken"),
                "accessToken": auth_result.get("AccessToken"),
                "refreshToken": auth_result.get("RefreshToken"),
                "role": "ROLE_EMPLOYEE"
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