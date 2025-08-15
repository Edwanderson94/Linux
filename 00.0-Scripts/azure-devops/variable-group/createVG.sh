#!/bin/bash

# Ativa debug + falha imediata em erros
set -ex

# --- 0. Valores recebidos pelas variáveis de ambiente ---

# Importanto variaveis de ambiente para o script.
export AZURE_DEVOPS_PAT="$AZURE_DEVOPS_PAT"
export PROJECT="$PROJECT_NAME"
export ORG_URL="https://dev.azure.com/$ORG"
export ORG="$ORGANIZATION_NAME"
export GROUP="$GROUP_NAME"
export VAR_NAME1="$VAR_NAME1"
export VAR_VALUE1="$VAR_VALUE1"

# --- 1.0 Instalação de extenção azure devops ---
az extension add --name azure-devops -y

# --- 1.1 Validação do PAT ---
if [[ -z "$AZURE_DEVOPS_PAT" ]]; then
  echo "❌ PAT não encontrado. Por favor, exporte a variável AZURE_DEVOPS_PAT."
  exit 1
fi

if [[ -z "$PROJECT" ]]; then
  echo "❌ Nome do projeto não foi definido. Por favor, defina a variável projectName no YAML."
  exit 1
fi

# --- 2.0 Login no Azure DevOps ---
echo "$AZURE_DEVOPS_PAT" | az devops login --organization $ORG_URL

# --- 3. Setar o contexto do projeto ---
az devops configure --defaults organization="https://dev.azure.com/$ORG" project="$PROJECT"

# --- 4. Criar o grupo de variáveis ---
az pipelines variable-group create \
  --name "$GROUP" \
  --variables "$VAR_NAME1=$VAR_VALUE1" \
  --description "Variáveis para pipeline templatizada de changelog." \
  --project "$PROJECT" \
  --org "$ORG_URL" \
  --authorize true \
  --output json > output.json

# --- 4.1 Verificações ---
echo "Diretório atual"
pwd

echo "Listando arquivos do diretório atual"
ls -lha

echo "Verificando o output.json"
cat output.json

echo "Coletando o ID do GroupID"
jq -r '.id' output.json

echo "Coletando o ID do GroupID"
ID=$(jq -r '.id' output.json)
echo "ID coletado: $ID"

# --- 5. Atualizar variavel de changelog no grupo de variavel criado ---
az pipelines variable-group variable update \
  --group-id "$ID" \
  --name "$GROUP" \
  --org "$ORG_URL" \
  --project "$PROJECT" \
  --value "teste"