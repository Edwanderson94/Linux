#!/bin/bash

# Script genérico para geração de chave SSH
# Versão: 1.0

# Configurações padrão
ALGORITMO="ed25519"  # Algoritmo padrão (alternativas: rsa, ecdsa)
BITS=4096            # Tamanho padrão da chave para RSA
ARQUIVO_PADRAO="$HOME/.ssh/id_$ALGORITMO"
COMENTARIO="$USER@$(hostname)-$(date +%Y-%m-%d)"

# Cores para saída
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
NC='\033[0m' # Sem cor

echo -e "${AMARELO}=== Gerador de Chave SSH ===${NC}"

# Menu interativo
echo "Escolha o algoritmo:"
echo "1) ed25519 (recomendado)"
echo "2) RSA"
echo "3) ECDSA"
read -p "Opção [1]: " opcao_algoritmo

case $opcao_algoritmo in
    2)
        ALGORITMO="rsa"
        read -p "Tamanho da chave (2048, 3072, 4096) [4096]: " bits_input
        BITS=${bits_input:-4096}
        ARQUIVO_PADRAO="$HOME/.ssh/id_rsa"
        ;;
    3)
        ALGORITMO="ecdsa"
        read -p "Tamanho da chave (256, 384, 521) [521]: " bits_input
        BITS=${bits_input:-521}
        ARQUIVO_PADRAO="$HOME/.ssh/id_ecdsa"
        ;;
    *)
        ALGORITMO="ed25519"
        ;;
esac

# Caminho do arquivo de saída
read -p "Digite o caminho para salvar a chave [$ARQUIVO_PADRAO]: " arquivo
ARQUIVO=${arquivo:-$ARQUIVO_PADRAO}

# Comentário da chave
read -p "Digite um comentário para a chave [$COMENTARIO]: " comentario_input
COMENTARIO=${comentario_input:-$COMENTARIO}

# Confirmação antes de gerar
echo -e "\nResumo:"
echo -e "Algoritmo: ${VERDE}$ALGORITMO${NC}"
[[ "$ALGORITMO" == "rsa" || "$ALGORITMO" == "ecdsa" ]] && echo -e "Bits: ${VERDE}$BITS${NC}"
echo -e "Arquivo: ${VERDE}$ARQUIVO${NC}"
echo -e "Comentário: ${VERDE}$COMENTARIO${NC}"
echo -e "\nA chave será protegida por uma senha (recomendado)."

read -p "Deseja continuar? [s/N]: " confirmacao
if [[ ! "$confirmacao" =~ ^[sS]$ ]]; then
    echo "Operação cancelada."
    exit 1
fi

# Geração da chave
echo -e "\nGerando chave..."
if [[ "$ALGORITMO" == "rsa" ]]; then
    ssh-keygen -t rsa -b "$BITS" -C "$COMENTARIO" -f "$ARQUIVO"
elif [[ "$ALGORITMO" == "ecdsa" ]]; then
    ssh-keygen -t ecdsa -b "$BITS" -C "$COMENTARIO" -f "$ARQUIVO"
else
    ssh-keygen -t ed25519 -C "$COMENTARIO" -f "$ARQUIVO"
fi

# Ajusta permissões
echo -e "\nAjustando permissões..."
chmod 700 ~/.ssh
chmod 600 "$ARQUIVO" 2>/dev/null
chmod 644 "$ARQUIVO.pub" 2>/dev/null

# Exibe chave pública
echo -e "\n${VERDE}Chave gerada com sucesso!${NC}"
echo -e "\nChave pública (adicione ao seu servidor):"
cat "$ARQUIVO.pub"

# Instruções úteis
echo -e "\n${AMARELO}Dicas úteis:${NC}"
echo "1) Para usar a chave com o ssh-agent:"
echo "   eval \$(ssh-agent) && ssh-add $ARQUIVO"
echo "2) Para copiar a chave para um servidor:"
echo "   ssh-copy-id -i $ARQUIVO.pub usuario@servidor"