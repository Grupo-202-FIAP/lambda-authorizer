# Secrets Configuration for GitHub Actions

Para configurar o pipeline de CI/CD, você precisa adicionar os seguintes secrets no GitHub:

## 📍 Como Adicionar Secrets

1. Vá para o seu repositório no GitHub
2. Clique em **Settings**
3. No menu lateral, clique em **Secrets and variables** → **Actions**
4. Clique no botão **New repository secret**
5. Adicione cada secret listado abaixo

## 🔑 Secrets Obrigatórios

### AWS_ACCESS_KEY_ID
- **Descrição**: Access Key ID para autenticação AWS
- **Como obter**: 
  1. Acesse o AWS Console
  2. Vá para IAM → Users
  3. Selecione o usuário para CI/CD
  4. Aba **Security credentials** → **Create access key**
- **Exemplo**: `AKIA1234567890EXAMPLE`

### AWS_SECRET_ACCESS_KEY
- **Descrição**: Secret Access Key correspondente ao Access Key ID
- **Como obter**: Obtido junto com o Access Key ID (mostrará apenas uma vez)
- **Exemplo**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

## 🛡️ Permissões IAM Necessárias

O usuário AWS deve ter a seguinte policy anexada:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECRFullAccess",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchDeleteImage",
                "ecr:GetAuthorizationToken",
                "ecr:DescribeImageScanFindings"
            ],
            "Resource": "*"
        }
    ]
}
```

## ✅ Verificação

Para verificar se os secrets estão funcionando:

1. Faça um commit com mudanças em qualquer função Lambda
2. Vá para **Actions** no GitHub
3. Verifique se o workflow **Build and Push Lambda Images to ECR** executou com sucesso
4. Se houver erros de autenticação, verifique os secrets e permissões IAM

## 🔐 Segurança

- **Nunca** commite credenciais AWS no código
- Use secrets específicos para CI/CD (não reutilize credenciais pessoais)
- Revise periodicamente as permissões e rotacione as chaves
- Considere usar IAM Roles com OIDC para maior segurança (configuração mais avançada)