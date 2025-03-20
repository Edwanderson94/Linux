script para bloqueio de uma branch especifica pra dev <> azure devops.



#!/bin/bash

echo "🚀 Verificando se a branch atual é refs/heads/dev/beta..."

# Obtendo o nome da branch atual no Azure DevOps
CURRENT_BRANCH=${BUILD_SOURCEBRANCH}

echo "📌 Branch atual: $CURRENT_BRANCH"

# Verifica se a branch é exatamente refs/heads/dev/beta
if [[ "$CURRENT_BRANCH" != "refs/heads/dev/beta" ]]; then
    echo "❌ Deploy bloqueado! Apenas a branch 'refs/heads/dev/beta' pode executar este pipeline."
    exit 1
fi

echo "✅ Validação concluída. Continuando com o deploy..."
