#!/bin/bash
set -e

# Definición de variables
USER_NAME="skalanux"
REPO_NAME="puntofiles"
DOTFILES_REPO="https://github.com/$USER_NAME/$REPO_NAME.git"
DOTFILES_DIR="$HOME/.local/share/chezmoi"

echo "🚀 Iniciando instalación de Skalanea OS..."

# 1. Preparación del sistema base
sudo pacman -Syu --needed --noconfirm git ansible chezmoi base-devel

# 2. Configurar sudoers para evitar bloqueos en la automatización
if [ ! -f /etc/sudoers.d/ska-automation ]; then
    echo "🔧 Configurando permisos de sudoers para pacman y yay..."
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/yay" | sudo tee /etc/sudoers.d/ska-automation
fi

# 3. Inicializar Chezmoi
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "🏠 Clonando dotfiles desde $DOTFILES_REPO..."
    chezmoi init --apply "$DOTFILES_REPO"
else
    echo "🔄 Actualizando dotfiles existentes..."
    chezmoi update
fi

# 4. Ejecutar el Playbook de Ansible
# Chezmoi descarga el repo en $DOTFILES_DIR
ANSIBLE_MAIN="$DOTFILES_DIR/ansible/main.yml"

if [ -f "$ANSIBLE_MAIN" ]; then
    echo "🤖 Ejecutando Ansible Playbook..."
    ansible-galaxy collection install community.general kewlfft.aur
    ansible-playbook "$ANSIBLE_MAIN"
else
    echo "⚠️ No se encontró el playbook en $ANSIBLE_MAIN"
fi

echo "✅ Instalación completada. Se recomienda reiniciar la sesión para aplicar cambios de grupo (docker)."
