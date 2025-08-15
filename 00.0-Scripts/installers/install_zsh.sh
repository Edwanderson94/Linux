#!/bin/bash

# Atualizar pacotes
echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instalar Zsh
echo "Instalando Zsh..."
sudo apt install zsh -y

# Definir Zsh como shell padrão
echo "Definindo Zsh como shell padrão..."
chsh -s $(which zsh)

# Instalar Oh My Zsh
echo "Instalando Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Criar pasta custom de plugins
echo "Criando pasta de plugins..."
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins

# Instalar plugins
echo "Instalando plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Instalar Powerlevel10k
echo "Instalando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Configurar .zshrc
echo "Configurando ~/.zshrc..."
cat << 'EOF' > ~/.zshrc
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Aliases úteis
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias devrepo='cd ~/Documents/repo'
alias tree='tree -C -L 2'
EOF

# Recarregar Zsh
echo "Finalizando configuração..."
source ~/.zshrc

echo "Instalação concluída! Abra um novo terminal WSL para ver o Powerlevel10k em ação."
