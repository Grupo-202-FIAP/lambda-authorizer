# CI/CD Pipeline para Lambda Authorizer

Este projeto inclui um pipeline completo de CI/CD usando GitHub Actions para buildar e fazer push das imagens Docker das funções Lambda para o Amazon ECR.

## 🚀 Funcionalidades

- **Build inteligente**: Detecta mudanças em cada função Lambda e builda apenas as imagens necessárias
- **Multi-ambiente**: Suporte para branches `main` e `develop`
- **Tagging automático**: Tags baseadas em commit SHA, branch name e `latest` para main
- **Scan de vulnerabilidades**: Análise automática de segurança das imagens
- **Limpeza automática**: Remoção de imagens antigas (agendada semanalmente)

## 📋 Pré-requisitos

### 1. Secrets do GitHub

Configure os seguintes secrets no seu repositório GitHub (Settings → Secrets and variables → Actions):

| Secret Name | Descrição | Exemplo |
|-------------|-----------|---------|
| `AWS_ACCESS_KEY_ID` | Access Key ID da AWS | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key da AWS | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |

### 2. Permissões IAM

O usuário AWS deve ter as seguintes permissões:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
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

### 3. Repositórios ECR

Os repositórios ECR devem existir antes do primeiro build. Execute o Terraform para criar:

```bash
cd infra
terraform init
terraform apply
```

## 🔄 Como Funciona

### 🎯 Detecção Automática do Registry

O workflow **automaticamente detecta** qual registry ECR usar:
- **Account ID**: Obtido via `aws sts get-caller-identity`
- **Região**: Definida na variável `AWS_REGION` (us-east-1)
- **Registry final**: `{account-id}.dkr.ecr.{region}.amazonaws.com`

📖 **Detalhes completos**: Veja [REGISTRY-DETECTION.md](./REGISTRY-DETECTION.md)

### Workflows

1. **`build-and-push.yml`**: Pipeline principal de CI/CD
   - Triggers: Push para `main`/`develop` ou PR para `main` com mudanças em `src/`
   - Detecta mudanças em cada Lambda function
   - Builda e faz push apenas das imagens modificadas
   - Aplica tags apropriadas baseadas no branch

2. **`cleanup-ecr.yml`**: Limpeza automática de imagens
   - Trigger: Agendado para domingos às 2h UTC
   - Remove imagens antigas mantendo apenas as 10 mais recentes
   - Remove imagens sem tag

### Estrutura de Tags

- **Commit SHA**: `abc123def` (sempre criada)
- **Latest**: `latest` (apenas para branch `main`)
- **Branch name**: `feature-auth` (para branches que não sejam `main`)

### Dockerfiles

Cada função Lambda possui seu próprio Dockerfile otimizado:
- Base image: `public.ecr.aws/lambda/python:3.9`
- Instalação de dependências via `requirements.txt`
- Copy do código fonte específico
- Configuração do handler apropriado

## 🛠️ Configuração Inicial

### 1. Configure os Secrets

No GitHub, vá para:
`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Adicione os secrets listados acima.

### 2. Crie a Infraestrutura

```bash
# Deploy dos repositórios ECR
cd infra
terraform init
terraform plan
terraform apply
```

### 3. Primeiro Build

Faça um commit com mudanças em qualquer Lambda function:

```bash
git add .
git commit -m "feat: add CI/CD pipeline"
git push origin main
```

O pipeline será executado automaticamente e as imagens serão buildadas e enviadas para o ECR.

## 📊 Monitoramento

### Verificar Images no ECR

```bash
# Listar imagens de um repositório
aws ecr list-images --repository-name lambda-authorizer-lambda-authorizer-customer

# Ver detalhes de uma imagem
aws ecr describe-images --repository-name lambda-authorizer-lambda-authorizer-customer --image-ids imageTag=latest
```

### Logs do GitHub Actions

- Vá para a aba `Actions` do seu repositório
- Clique no workflow desejado para ver os logs detalhados
- Cada step mostra informações sobre o build e push das imagens

## 🔍 Troubleshooting

### Erro de Permissões AWS
- Verifique se os secrets estão configurados corretamente
- Confirme que a IAM policy inclui todas as permissões necessárias

### Repositório ECR não encontrado
- Execute `terraform apply` para criar os repositórios
- Verifique se o nome do projeto no Terraform match com `PROJECT_NAME` no workflow

### Build falha
- Verifique se os Dockerfiles estão corretos
- Confirme que os `requirements.txt` existem em cada diretório Lambda
- Verifique os logs do GitHub Actions para erros específicos

## 🔄 Workflows Manuais

### Executar Cleanup Manual

1. Vá para `Actions` → `Cleanup Old ECR Images`
2. Clique em `Run workflow`
3. Selecione o branch e clique em `Run workflow`

### Re-buildar Imagem Específica

1. Faça uma mudança pequena no código da função Lambda
2. Commit e push
3. O pipeline detectará a mudança e rebuildará apenas essa imagem