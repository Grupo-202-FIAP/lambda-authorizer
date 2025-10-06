# Como o Workflow Determina o Registry ECR

## 🎯 Resumo Rápido

O workflow **automaticamente detecta** qual registry ECR usar através da combinação de:
1. **Account ID AWS** (obtido via `aws sts get-caller-identity`)
2. **Região AWS** (definida na variável `AWS_REGION`)
3. **Nome do projeto** (definido na variável `PROJECT_NAME`)

## 🔍 Processo Detalhado

### 1. **Variáveis de Ambiente Definidas**
```yaml
env:
  AWS_REGION: us-east-1              # Região onde estão os repositórios ECR
  PROJECT_NAME: lambda-authorizer    # Prefixo usado nos nomes dos repositórios
```

### 2. **Detecção Automática do Account ID**
```yaml
- name: Get AWS Account ID
  run: |
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo "account-id=$ACCOUNT_ID" >> $GITHUB_OUTPUT
```
**Resultado**: `123456789012` (exemplo)

### 3. **Construção do Registry URL**
```yaml
- name: Get repository information
  run: |
    ECR_REGISTRY="${{ steps.get-account-id.outputs.account-id }}.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com"
```
**Resultado**: `123456789012.dkr.ecr.us-east-1.amazonaws.com`

### 4. **Nome Completo do Repositório**
```yaml
REPOSITORY_NAME="${{ env.PROJECT_NAME }}-${{ matrix.name }}"
```
**Exemplos**:
- `lambda-authorizer-lambda-authorizer-customer`
- `lambda-authorizer-lambda-authorizer-internal`
- `lambda-authorizer-lambda-registration-customer`

### 5. **URL Final da Imagem**
```bash
$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```
**Exemplo completo**:
```
123456789012.dkr.ecr.us-east-1.amazonaws.com/lambda-authorizer-lambda-authorizer-customer:abc123def
```

## 📋 Exemplo de Log do Workflow

Quando o workflow executa, você verá logs assim:

```
=== Build Information ===
Account ID: 123456789012
Region: us-east-1
ECR Registry: 123456789012.dkr.ecr.us-east-1.amazonaws.com
Repository Name: lambda-authorizer-lambda-authorizer-customer
Repository URI: 123456789012.dkr.ecr.us-east-1.amazonaws.com/lambda-authorizer-lambda-authorizer-customer
Image Tag: abc123def456
Branch: main
=========================
```

## ⚙️ Configuração Personalizada

### Para Mudar a Região:
```yaml
env:
  AWS_REGION: sa-east-1  # Mude para sua região preferida
```

### Para Mudar o Nome do Projeto:
```yaml
env:
  PROJECT_NAME: meu-projeto  # Deve match com o Terraform
```

### Para Usar Account ID Específico (Opcional):
Se você quiser hardcodar o Account ID em vez de detectar automaticamente:

```yaml
env:
  AWS_ACCOUNT_ID: "123456789012"  # Seu Account ID específico
```

E então use:
```yaml
ECR_REGISTRY="${{ env.AWS_ACCOUNT_ID }}.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com"
```

## 🔐 Segurança

- O Account ID é obtido das credenciais AWS configuradas nos secrets
- Não é necessário expor o Account ID como secret separado
- O workflow usa as mesmas credenciais para autenticar no ECR

## ❗ Troubleshooting

### Erro: "Repository does not exist"
**Causa**: Os repositórios ECR não foram criados pelo Terraform
**Solução**:
```bash
cd infra
terraform apply
```

### Erro: "Access denied"
**Causa**: Credenciais AWS sem permissões adequadas
**Solução**: Verifique se o usuário IAM tem as permissões ECR listadas no `SECRETS-SETUP.md`

### Erro: "Invalid repository URI"
**Causa**: `PROJECT_NAME` no workflow não match com o usado no Terraform
**Solução**: Certifique-se que ambos usam o mesmo valor

## 🔄 Múltiplas Contas AWS

Se você quiser fazer deploy em diferentes contas por branch:

```yaml
- name: Set target account based on branch
  run: |
    if [ "${{ github.ref_name }}" = "main" ]; then
      echo "target-account=123456789012" >> $GITHUB_OUTPUT  # Produção
    else
      echo "target-account=098765432109" >> $GITHUB_OUTPUT  # Desenvolvimento
    fi
```

Dessa forma, o workflow **automaticamente determina** o registry correto sem necessidade de configuração manual! 🎉