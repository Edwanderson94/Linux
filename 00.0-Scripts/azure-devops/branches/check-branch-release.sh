#!/bin/bash

echo "🚀 Verificando se a branch atual é permitida..."

# Definição do padrão de branch permitida
ALLOWED_BRANCH="^refs/heads/release/.*$"

# Obtendo o nome da branch atual no Azure DevOps
CURRENT_BRANCH=${BUILD_SOURCEBRANCH}

echo "📌 Branch atual: $CURRENT_BRANCH"

# Verifica se a branch começa com "refs/heads/release/"
if [[ "$CURRENT_BRANCH" =~ $ALLOWED_BRANCH ]]; then
    echo "✅ Validação concluída. Continuando com o deploy..."
else
    echo "❌ Deploy bloqueado! Apenas branches que começam com 'refs/heads/release/' são permitidas."
    exit 1
fi
