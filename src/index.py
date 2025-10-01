import json
import os
import boto3
import jwt
from botocore.exceptions import ClientError

# --- Variáveis de Ambiente (Configurar na AWS) ---
USER_POOL_ID = os.environ.get('USER_POOL_ID')
JWT_SECRET = os.environ.get('JWT_SECRET')
AWS_REGION = os.environ.get('AWS_REGION')

cognito_client = boto3.client('cognito-identity-provider', region_name=AWS_REGION)

def handler(event, context):
    """
    Função Lambda para receber o CPF do API Gateway, consultar o Cognito
    e retornar um JWT para identificação do cliente.
    """
    # 1. Validar e parsear o corpo da requisição
    try:
        # O corpo da requisição do API Gateway (JSON) precisa ser parseado
        body = json.loads(event.get('body', '{}'))
    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Requisição inválida: corpo deve ser JSON.'})
        }

    cpf = body.get('cpf')

    if not cpf:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'O campo CPF é obrigatório no corpo da requisição.'})
        }
    
    try:
        # 2. Consultar o Cognito
        # Usamos list_users para buscar o usuário cujo 'username' (onde armazenamos o CPF)
        response = cognito_client.list_users(
            UserPoolId=USER_POOL_ID,
            Filter=f'username = "{cpf}"',
            Limit=1
        )

        users = response.get('Users', [])
        if not users:
            # Cliente não encontrado (Falha na identificação)
            return {
                'statusCode': 404,
                'body': json.dumps({'message': 'Cliente não encontrado ou CPF inválido.'})
            }

        user = users[0]
        
        # 3. Gerar o Token JWT
        payload = {
            'sub': user['Username'],  # ID do cliente (CPF)
            'role': 'cliente_lanchonete',
            'iat': jwt.exceptions.get_int_from_datetime(datetime.now(timezone.utc)),
            'exp': jwt.exceptions.get_int_from_datetime(datetime.now(timezone.utc) + timedelta(hours=1))  # Expira em 1 hora
        }

        # O JWT_SECRET precisa ser a mesma chave usada para assinar e verificar os tokens
        token = jwt.encode(payload, JWT_SECRET, algorithm='HS256')

        # 4. Retornar a resposta com o Token
        return {
            'statusCode': 200,
            'headers': { 
                "Content-Type": "application/json",
                # Permite chamadas de qualquer origem (Ajustar em produção)
                "Access-Control-Allow-Origin": "*" 
            },
            'body': json.dumps({
                'message': 'Identificação bem-sucedida',
                'token': token,
                'userId': user['Username']  # Retorna o CPF como ID
            })
        }

    except ClientError as e:
        print(f"Erro do cliente Boto3: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Erro ao processar a identificação.'})
        }
    except Exception as e:
        print(f"Erro interno do servidor: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Erro ao processar a identificação.'})
        }