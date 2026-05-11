#!/bin/bash
set -e

# Colores para la terminal
-n "\e[32m" && echo "--- Iniciando instalación de Skalanea OS ---" && echo -ne "\e[0m"

# 1. Instalar lo mínimo para arrancar
sudo pacman -Syu --needed --noconfirm git ansible chezmoi base-devel

# 2. Clonar tu repositorio de configuración (Ansible + Dotfiles)
# Reemplaza con tu repo real
export DOTFILES_REPO="https://github.com/skalanux/puntofiles.git"
export DOTFILES_DIR="$HOME/.local/share/chezmoi"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Clonando configuraciones..."
    chezmoi init --apply $DOTFILES_REPO
else
    echo "El repositorio ya existe, actualizando..."
    chezmoi update
fi

# 3. Ejecutar Ansible desde dentro del repo clonado por Chezmoi
if [ -f "$DOTFILES_DIR/ansible/main.yml" ]; then
    echo "Ejecutando Ansible para configurar el sistema..."
    cd "$DOTFILES_DIR/ansible"
    ansible-galaxy collection install community.general kewlfft.aur
    ansible-playbook -K main.yml
fi

echo "--- Proceso completado. Reinicia la terminal o la sesión. ---"
