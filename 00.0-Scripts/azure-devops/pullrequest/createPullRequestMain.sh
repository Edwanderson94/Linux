#!/bin/bash

# Ativa debug + falha imediata em erros
set -ex

# 1.0 Configuração do Git
git config --global user.email "service-azuredevops@dominio.com.br"
git config --global user.name "Azure DevOps"

# 1.1 Definição de Variaveis.
ORG=$organizationName
ORG_URL="https://dev.azure.com/$ORG"
BRANCHTARGET=$sourceBranchDefaultGitflowPRD  # Branch alvo do PR
BRANCHOURCE=$sourceBranchDefaultDEV # Branch de origem do PR
PAT=$autenticatePatSvc

# 2.0 Login no Azure DevOps
echo "$PAT" | az devops login --organization "$ORG_URL"

# 2.1 Remove espaços extras e codifica para URL (ex: "Projeto DevOps" → "Projeto%20DevOps")
PROJECT=$projectName                         # Nome do projeto
PROJECT=$(echo "$PROJECT" | xargs)           # Remove espaços no início/fim

REPO=$repositoryName        # Nome do repositório
REPO_URL="https://$PAT@dev.azure.com/$ORG/$PROJECT/_git/$REPO"

# 3. Setar o contexto do projeto
az devops configure --defaults organization="$REPO_URL" project="$PROJECT"

# 4. Criação de Pull Request
az repos pr create \
  --title "Meu Pull Request [automate]" \
  --description "Descrição das alterações [automate]" \
  --source-branch "$BRANCHOURCE" \
  --target-branch "$BRANCHTARGET" \
  --repository "$REPO" \
  --project "$PROJECT" \
  --organization $ORG_URL