#!/bin/bash

set -euo pipefail

# --- 1.0 Configuração do Git ---
configure_git() {
  git config --global user.email "service-azuredevops@dominio.com.br"
  git config --global user.name "Azure DevOps"
}

# --- 2.0 Validação e definição das variáveis ---
initialize_variables() {
  if [[ -z "${organizationName:-}" || -z "${autenticatePatSvc:-}" || -z "${projectName:-}" || -z "${repositoryName:-}" ]]; then
    printf "Erro: Variáveis de ambiente necessárias não definidas.\n" >&2
    return 1
  fi

  ORG=$(printf '%s' "$organizationName" | xargs)
  PAT=$(printf '%s' "$autenticatePatSvc" | xargs)
  PROJECT=$(printf '%s' "$projectName" | xargs)
  REPO=$(printf '%s' "$repositoryName" | xargs)

  PROJECT_ENCODED=$(printf '%s' "$PROJECT" | jq -sRr @uri)
  REPO_URL="https://$PAT@dev.azure.com/$ORG/$PROJECT_ENCODED/_git/$REPO"
  ORG_URL="https://dev.azure.com/$ORG"
  AUTH_HEADER=$(printf 'Authorization: Basic %s' "$(printf ':%s' "$PAT" | base64 | tr -d '\r\n')")
  CURRENT_BRANCH="feature/mapToReleases"
  RELEASES_FILE="releases-${PROJECT_ENCODED}.csv"
  API_URL="https://vsrm.dev.azure.com/$ORG/$PROJECT_ENCODED/_apis/release/releases?api-version=7.1"
}

# --- 3.0 Autenticação com Azure DevOps CLI ---
azure_login() {
  echo "$PAT" | az devops login --organization "$ORG_URL" || {
    printf "Erro ao autenticar com Azure DevOps CLI.\n" >&2
    return 1
  }
}

# --- 4.0 Requisição da API de Releases ---
fetch_releases() {
  if ! RELEASES_JSON=$(curl --http1.1 -sS -H "Content-Type: application/json" -H "$AUTH_HEADER" "$API_URL"); then
    printf "Erro ao buscar releases na API.\n" >&2
    return 1
  fi

  if [[ -z "$RELEASES_JSON" || "$RELEASES_JSON" == "null" ]]; then
    printf "Nenhum dado de release retornado pela API.\n" >&2
    return 1
  fi
}

# --- 5.0 Exportar Releases para CSV ---
export_releases_to_csv() {
  if ! printf '%s' "$RELEASES_JSON" | jq -r '
    .value[]? |
    [.id, .name, .status, .createdBy.displayName, .createdOn, .releaseDefinition.name] |
    @csv
  ' > "$RELEASES_FILE"; then
    printf "Erro ao exportar releases para CSV.\n" >&2
    return 1
  fi
}

# --- 6.0 Clonar Repositório ---
clone_repo() {
  if ! git clone --branch "$CURRENT_BRANCH" "$REPO_URL"; then
    printf "Erro ao clonar o repositório na branch %s\n" "$CURRENT_BRANCH" >&2
    return 1
  fi
}

# --- 7.0 Commit e Push do CSV ---
commit_and_push_csv() {
  cd "$REPO" || {
    printf "Erro ao acessar diretório do repositório clonado.\n" >&2
    return 1
  }

  mkdir -p ./export_report/release/
  cp "../$RELEASES_FILE" ./export_report/release/

  git add "export_report/release/$RELEASES_FILE"

  if git diff --cached --quiet; then
    printf "Nenhuma alteração detectada no arquivo CSV, commit ignorado.\n"
    return 0
  fi

  git commit -m "Exportação automática de releases para CSV"
  git push origin "$CURRENT_BRANCH"
}

# --- 8.0 Execução Principal ---
main() {
  configure_git
  initialize_variables || return 1
  azure_login || return 1
  fetch_releases || return 1
  export_releases_to_csv || return 1
  clone_repo || return 1
  commit_and_push_csv || return 1
}

main "$@"
