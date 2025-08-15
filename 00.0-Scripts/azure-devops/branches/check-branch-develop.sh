#!/bin/bash

echo "🚀 Verificando se a branch atual é permitida..."

# Definição da branch permitida
ALLOWED_BRANCH="refs/heads/develop"

# Obtendo o nome da branch atual no Azure DevOps
CURRENT_BRANCH=${BUILD_SOURCEBRANCH}

echo "📌 Branch atual: $CURRENT_BRANCH"

# Verifica se a branch é exatamente a permitida
if [[ "$CURRENT_BRANCH" != "$ALLOWED_BRANCH" ]]; then
    echo "❌ Deploy bloqueado! Apenas a branch '$ALLOWED_BRANCH' pode executar este pipeline."
    exit 1
fi

echo "✅ Validação concluída. Continuando com o deploy..."
