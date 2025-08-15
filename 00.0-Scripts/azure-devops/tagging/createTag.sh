#!/bin/bash

set -ex

# 1. Configuração do Git
git config --global user.email "service@domminio.com.br"
git config --global user.name "Azure DevOps"

# 2. Definição de Variaveis.
ORG=$organizationName
PAT=$autenticatePatSvc
# 2.1 Remove espaços extras e codifica para URL (ex: "Projeto DevOps" → "Projeto%20DevOps")
PROJECT=$projectName               # Nome do projeto
PROJECT=$(echo "$PROJECT" | xargs) # Remove espaços no início/fim
PROJECT=${PROJECT// /%20}          # Substitui espaços internos por %20
REPO=$repositoryName               # Nome do repositório
REPO_URL="https://$PAT@dev.azure.com/$ORG/$PROJECT/_git/$REPO"

# 3. Pega última tag ou inicia em 0.0.0
git fetch --tags
LATEST_TAG=$(git tag -l '[0-9]*.[0-9]*.[0-9]*' | sort -V | tail -n1)
if [[ -z "$LATEST_TAG" ]]; then
  LATEST_TAG="0.0.0"
fi
IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST_TAG"

# 4. Cria nova tag
NEW_TAG="$MAJOR.$MINOR.$((PATCH + 1))"
git tag -a "$NEW_TAG" -m "Release $NEW_TAG [Automated]"

# 5. Push da tag
echo "Enviando tag $NEW_TAG para $REPO_URL"
git push "$REPO_URL" "$NEW_TAG"

# 6. Log
echo "===================================="
echo "Tag anterior: $LATEST_TAG"
echo "Nova tag:     $NEW_TAG"
echo "Repositório:  $REPO_URL"
echo "===================================="
