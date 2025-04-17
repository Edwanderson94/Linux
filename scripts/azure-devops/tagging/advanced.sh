#!/bin/bash

set -euo pipefail

# ===============================
# 1. Configuração do Git
# ===============================
configure_git() {
  git config --global user.email "service-azuredevops@mastercctvm.com.br"
  git config --global user.name "Azure DevOps"
}

# ===============================
# 2. Validação e Inicialização de Variáveis
# ===============================
init_variables() {
  if [[ -z "${organizationName:-}" || -z "${autenticatePatSvc:-}" || -z "${projectName:-}" || -z "${repositoryName:-}" ]]; then
    printf "Erro: Variáveis obrigatórias não definidas.\n" >&2
    return 1
  fi

  ORG=$(printf '%s' "$organizationName" | xargs)
  PAT=$(printf '%s' "$autenticatePatSvc" | xargs)
  PROJECT=$(printf '%s' "$projectName" | xargs)
  PROJECT_ENCODED=$(printf '%s' "$PROJECT" | jq -sRr @uri)
  REPO=$(printf '%s' "$repositoryName" | xargs)
  REPO_URL="https://$PAT@dev.azure.com/$ORG/$PROJECT_ENCODED/_git/$REPO"
  CURRENT_BRANCH=${branchName:-"develop"}

  VERSION_TYPE_MAJOR=${versionTypeMajor:-false}
  VERSION_TYPE_MINOR=${versionTypeMinor:-false}
  VERSION_TYPE_PATCH=${versionTypePatch:-true}
}

# ===============================
# 3. Clonar repositório e buscar tags
# ===============================
clone_repository() {
  TMP_DIR=$(mktemp -d)

  if ! git clone --single-branch --branch "$CURRENT_BRANCH" "$REPO_URL" "$TMP_DIR"; then
    printf "Erro ao clonar repositório %s na branch %s\n" "$REPO_URL" "$CURRENT_BRANCH" >&2
    return 1
  fi

  cd "$TMP_DIR" || {
    printf "Erro ao acessar diretório clonado.\n" >&2
    return 1
  }

  git fetch --tags --quiet
}

# ===============================
# 4. Gerar nova versão com base nas variáveis
# ===============================
generate_new_tag() {
  local last_tag
  last_tag=$(git tag -l '[0-9]*.[0-9]*.[0-9]*' | sort -V | tail -n1)

  [[ -z "$last_tag" ]] && last_tag="0.0.0"

  IFS='.' read -r major minor patch <<< "$last_tag"

  if [[ "$VERSION_TYPE_MAJOR" == "true" ]]; then
    ((major++))
    minor=0
    patch=0
    version_type="major"
  elif [[ "$VERSION_TYPE_MINOR" == "true" ]]; then
    ((minor++))
    patch=0
    version_type="minor"
  else
    ((patch++))
    version_type="patch"
  fi

  NEW_TAG="${major}.${minor}.${patch}"
  PREVIOUS_TAG="$last_tag"
}

# ===============================
# 5. Criar e enviar nova tag
# ===============================
create_and_push_tag() {
  git tag -a "$NEW_TAG" -m "Release $NEW_TAG [automated - $version_type]"
  git push origin "$NEW_TAG"
}

# ===============================
# 6. Log final
# ===============================
print_summary() {
  printf "\n====================================\n"
  printf "Branch:         %s\n" "$CURRENT_BRANCH"
  printf "Tag anterior:   %s\n" "$PREVIOUS_TAG"
  printf "Tipo de versão: %s\n" "$version_type"
  printf "Nova tag:       %s\n" "$NEW_TAG"
  printf "Repositório:    %s\n" "$REPO_URL"
  printf "====================================\n"
}

# ===============================
# Execução principal
# ===============================
main() {
  configure_git
  init_variables || return 1
  clone_repository || return 1
  generate_new_tag || return 1
  create_and_push_tag || return 1
  print_summary
}

main "$@"
