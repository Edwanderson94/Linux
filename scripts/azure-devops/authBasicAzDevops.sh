#!/bin/bash

set -ex

# --- 1.0 Configuração do Git ---
git config --global user.email "service-azuredevops@mastercctvm.com.br"
git config --global user.name "Azure DevOps"

# --- 2.0 Definição de Variaveis.  ---
ORG=$organizationName
ORG_URL="https://dev.azure.com/$ORG"
BRANCHTARGET=$sourceBranchDefaultGitflowPRD  # Branch alvo do PR
BRANCHOURCE=$sourceBranchDefaultDEV # Branch de origem do PR
PAT=$autenticatePatSvc

# --- 3.0 Autenticação ---
echo "$PAT" | az devops login --organization "$ORG_URL"

# --- 4.0 Remove espaços extras e codifica para URL (ex: "Master DevOps" → "Master%20DevOps") ---
PROJECT=                        # Nome do projeto (pode ser utilizado com espaço)
PROJECT=$(echo "$PROJECT" | xargs)           # Remove espaços no início/fim
REPO=$repositoryName                         # Nome do repositório
REPO_URL="https://$PAT@dev.azure.com/$ORG/$PROJECT/_git/$REPO"

# --- 5.0 Setar o contexto do projeto ---
az devops configure --defaults organization="$REPO_URL" project="$PROJECT"
