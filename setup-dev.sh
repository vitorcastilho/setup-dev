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
sdk install java 21.0.6-zulu
sdk default java 21.0.6-zulu

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
echo "☀️ Baixando e instalando Eclipse..."
wget -O eclipse-installer.tar.gz https://ftp.osuosl.org/pub/eclipse/oomph/epp/2024-12/R/eclipse-inst-jre-linux64.tar.gz
tar -xzf eclipse-installer.tar.gz
cd eclipse-installer
./eclipse-inst
cd ..
rm -rf eclipse-installer eclipse-installer.tar.gz

# Limpeza final
echo "🧹 Limpando pacotes desnecessários..."
sudo apt autoremove -y
sudo apt clean

echo "✅ Instalação concluída! Reinicie o sistema para aplicar todas as configurações."

