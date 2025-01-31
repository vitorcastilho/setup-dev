#!/bin/bash

# Atualiza pacotes do sistema
echo "🔄 Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instala pacotes essenciais
echo "🛠 Instalando pacotes básicos..."
sudo apt install -y curl wget git unzip build-essential apt-transport-https ca-certificates gnupg

# Instala SDKMAN
echo "☁️ Instalando SDKMAN..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Instala Java via SDKMAN (versão mais recente do Temurin 21)
echo "☕ Instalando Java via SDKMAN..."
sdk install java 21-temurin
sdk default java 21-temurin

# Instala Node.js e NVM
echo "🌍 Instalando Node.js e NVM..."
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install node
nvm use node
npm install --global yarn

# Instala Docker e adiciona ao grupo do usuário
echo "🐳 Instalando Docker..."
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Instala VS Code, Postman e Notepad++ via Snap
echo "💻 Instalando VSCode, Postman e Notepad++..."
sudo snap install --classic code
sudo snap install postman
sudo snap install notepad-plus-plus

# Instala DBeaver
echo "🐘 Instalando DBeaver..."
wget -O dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
sudo apt install -y ./dbeaver.deb
rm dbeaver.deb

# Instala Google Chrome
echo "🌍 Instalando Google Chrome..."
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./chrome.deb
rm chrome.deb

# Instala Eclipse
echo "☀️ Instalando Eclipse..."
wget -O eclipse.tar.gz https://ftp.fau.de/eclipse/technology/epp/downloads/release/latest/eclipse-jee-latest-linux-gtk-x86_64.tar.gz
sudo tar -xzf eclipse.tar.gz -C /opt/
sudo ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse
rm eclipse.tar.gz

# Limpeza final
echo "🧹 Limpando pacotes desnecessários..."
sudo apt autoremove -y
sudo apt clean

echo "✅ Instalação concluída! Reinicie o sistema para aplicar todas as configurações."

