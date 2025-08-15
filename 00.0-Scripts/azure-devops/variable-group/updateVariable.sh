#!/bin/bash

# Ativa debug + falha imediata em erros
set -ex

# --- 0. Valores recebidos pelas variáveis de ambiente ---

# Importanto variaveis de ambiente para o script.
export AZURE_DEVOPS_PAT="$AZURE_DEVOPS_PAT"
export PROJECT="$PROJECT_NAME"
export ORG="$ORGANIZATION_NAME"
export GROUP_ID="$GROUP_ID"
export VAR_NAME1="$VAR_NAME1"
export VAR_VALUE1="$VAR_VALUE1"

# --- 1. Validação do PAT ---
if [[ -z "$AZURE_DEVOPS_PAT" ]]; then
  echo "❌ PAT não encontrado. Por favor, exporte a variável AZURE_DEVOPS_PAT."
  exit 1
fi

if [[ -z "$PROJECT" ]]; then
  echo "❌ Nome do projeto não foi definido. Por favor, defina a variável projectName no YAML."
  exit 1
fi

# --- 2. Login no Azure DevOps ---
echo "$AZURE_DEVOPS_PAT" | az devops login --organization "https://dev.azure.com/$ORG" --only-show-errors

# --- 3. Setar o contexto do projeto ---
az devops configure --defaults organization="https://dev.azure.com/$ORG" project="$PROJECT"

# --- 4. Criar variaveis dentro do grupo de variaveis ---
az pipelines variable-group variable update \
  --group-id "$GROUP_ID" \
  --name "variableGroupChangeLogID" \
  --value "teste" \
  --project "$PROJECT" \
  --org "https://dev.azure.com/$ORG"