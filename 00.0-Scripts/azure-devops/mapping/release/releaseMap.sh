#!/bin/bash

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# 1.0 Configuração do Git
# ─────────────────────────────────────────────────────────────
git config --global user.email "service-azuredevops@dominio.com.br"
git config --global user.name "Azure DevOps"

# ─────────────────────────────────────────────────────────────
# 2.0 Definição de Variáveis
# ─────────────────────────────────────────────────────────────
ORG=$(printf '%s' "${organizationName:-}" | xargs)
PAT=$(printf '%s' "${autenticatePatSvc:-}" | xargs)
PROJECT=$(printf '%s' "${projectName:-}" | xargs)
PROJECT_ENCODED=$(printf '%s' "$PROJECT" | jq -sRr @uri)
PROJECT_ENCODED_DEVOPS=$(printf '%s' "Master DevOps" | jq -sRr @uri)

REPO=${repositoryName:?Variável 'repositoryName' não definida}
REPO_URL="https://$PAT@dev.azure.com/$ORG/$PROJECT_ENCODED_DEVOPS/_git/$REPO"
ORG_URL="https://dev.azure.com/$ORG"
CURRENT_BRANCH="feature/mapToReleases"
EXPORT_FOLDER="./export_report/release"

# ─────────────────────────────────────────────────────────────
# 3.0 Autenticação Azure CLI
# ─────────────────────────────────────────────────────────────
echo "$PAT" | az devops login --organization "$ORG_URL"

# ─────────────────────────────────────────────────────────────
# 4.0 Header de Autorização (Base64 sem quebras de linha)
# ─────────────────────────────────────────────────────────────
AUTH_HEADER=$(printf 'Authorization: Basic %s' "$(printf ':%s' "$PAT" | base64 | tr -d '\r\n')")

# ─────────────────────────────────────────────────────────────
# 5.0 URL da API de Releases
# ─────────────────────────────────────────────────────────────
URL="https://vsrm.dev.azure.com/$ORG/$PROJECT_ENCODED/_apis/release/releases?api-version=7.1"

# ─────────────────────────────────────────────────────────────
# 6.0 Requisição via curl e captura de JSON de resposta
# ─────────────────────────────────────────────────────────────
RELEASES_JSON=$(curl --http1.1 -sS \
  -H "Content-Type: application/json" \
  -H "$AUTH_HEADER" \
  "$URL")

# ─────────────────────────────────────────────────────────────
# 7.0 Exporta dados das releases para arquivo CSV
# ─────────────────────────────────────────────────────────────
CSV_FILE="releases-${PROJECT_ENCODED}.csv"

echo "$RELEASES_JSON" | jq -r '
  .value[] |
  [.id, .name, .status, .createdBy.displayName, .createdOn, .releaseDefinition.name] |
  @csv
' > "$CSV_FILE"

# ─────────────────────────────────────────────────────────────
# 8.0 Envia CSV para o repositório Git
# ─────────────────────────────────────────────────────────────
git clone --branch "$CURRENT_BRANCH" "$REPO_URL"
cd "$REPO"

# Debug opcional: mostra estrutura do repositório clonado
ls -R -lha

# Copia o CSV gerado para a pasta definida
cp "../$CSV_FILE" "$EXPORT_FOLDER/"

# Adiciona e commita o arquivo no Git
git add "$EXPORT_FOLDER/$CSV_FILE"
git commit -m "Exportação automática de releases para CSV"
git push origin "$CURRENT_BRANCH"
