#!/bin/bash

echo "🍎 Iniciando configuração do ambiente macOS..."

# Instala Xcode Command Line Tools
echo "🔧 Verificando Command Line Tools..."
xcode-select --install 2>/dev/null

# Instala Homebrew se não existir
if ! command -v brew &> /dev/null; then
    echo "🍺 Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
    eval "$(/usr/local/bin/brew shellenv)"      # Intel
else
    echo "🍺 Homebrew já instalado."
fi

# Atualiza Homebrew
echo "🔄 Atualizando pacotes..."
brew update && brew upgrade

# Pacotes básicos
echo "🛠 Instalando pacotes essenciais..."
brew install curl wget git unzip gnupg ca-certificates

# SDKMAN
echo "☁️ Instalando SDKMAN..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Java 17 via SDKMAN
echo "☕ Instalando Java 17 (Zulu)..."
sdk install java 17.0.13-zulu
sdk default java 17.0.13-zulu

# NVM + Node + Yarn
echo "🌍 Instalando NVM e Node..."
brew install nvm
export NVM_DIR="$HOME/.nvm"
mkdir -p $NVM_DIR
source "$(brew --prefix nvm)/nvm.sh"
nvm install node
npm install -g yarn

# Docker Desktop
echo "🐳 Instalando Docker Desktop..."
brew install --cask docker

# DBeaver
echo "🐘 Instalando DBeaver..."
brew install --cask dbeaver-community

# Ferramentas de desenvolvimento
echo "💻 Instalando VS Code..."
brew install --cask visual-studio-code

echo "💻 Instalando Eclipse Installer..."
brew install --cask eclipse-installer

echo "💡 Instalando IntelliJ IDEA Community..."
brew install --cask intellij-idea-ce

echo "📮 Instalando Postman..."
brew install --cask postman

echo "🧹 Limpando caches..."
brew cleanup

echo "✅ Ambiente configurado! Reinicie o sistema para finalizar."
