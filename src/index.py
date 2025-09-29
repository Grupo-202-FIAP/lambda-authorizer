import json
import boto3
import os
from botocore.exceptions import ClientError

# Variáveis de ambiente da Lambda:
# - COGNITO_USER_POOL_ID
# - COGNITO_CLIENT_ID

cognito_client = boto3.client("cognito-idp")

def lambda_handler(event, context):
    """
    Lambda para autenticar usuário apenas pelo CPF.
    Fluxo:
      1. Recebe CPF no body da requisição.
      2. Consulta usuário no Cognito (custom:cpf).
      3. Se existir, inicia fluxo de autenticação customizado (sem senha).
      4. Retorna JWT tokens.
    """
    try:
        body = json.loads(event.get("body", "{}"))
        cpf = body.get("cpf")

        if not cpf:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "CPF é obrigatório"})
            }

        # 1. Buscar usuário no Cognito pelo atributo custom:cpf
        response = cognito_client.list_users(
            UserPoolId=os.environ["COGNITO_USER_POOL_ID"],
            Filter=f'custom:cpf = "{cpf}"'
        )

        if not response["Users"]:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "Usuário não encontrado"})
            }

        username = response["Users"][0]["Username"]

        # 2. Iniciar autenticação customizada (sem senha)
        auth_response = cognito_client.admin_initiate_auth(
            UserPoolId=os.environ["COGNITO_USER_POOL_ID"],
            ClientId=os.environ["COGNITO_CLIENT_ID"],
            AuthFlow="CUSTOM_AUTH",
            AuthParameters={
                "USERNAME": username
            }
        )

        # 3. Se o fluxo custom exigir challenge, você pode tratar aqui
        if "ChallengeName" in auth_response:
            return {
                "statusCode": 401,
                "body": json.dumps({
                    "error": "Challenge adicional necessário",
                    "challenge": auth_response["ChallengeName"]
                })
            }

        # 4. Retornar tokens JWT
        tokens = auth_response.get("AuthenticationResult", {})

        return {
            "statusCode": 200,
            "body": json.dumps({
                "id_token": tokens.get("IdToken"),
                "access_token": tokens.get("AccessToken"),
                "refresh_token": tokens.get("RefreshToken"),
                "expires_in": tokens.get("ExpiresIn")
            })
        }

    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
