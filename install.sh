#!/bin/bash
set -e

# --- Configuración de variables ---
USER_NAME="skalanux"
REPO_NAME="puntofiles"
DOTFILES_REPO="https://github.com/$USER_NAME/$REPO_NAME.git"
DOTFILES_DIR="$HOME/.local/share/chezmoi"

echo "🚀 Iniciando instalación de Skalanea OS (Manjaro)..."

# 1. Actualización e instalación de herramientas base
echo "📦 Instalando dependencias críticas (Git, Ansible, Chezmoi)..."
sudo pacman -Syu --needed --noconfirm git ansible chezmoi base-devel

# 2. Configuración de sudoers para automatización
if [ ! -f /etc/sudoers.d/ska-automation ]; then
    echo "🔧 Configurando permisos de sudoers y preservación de entorno..."
    
    # Definimos el contenido en una variable para mayor claridad
    # 1. Permitimos pacman y yay sin pass
    # 2. Mantenemos variables de terminal para evitar el error de Ghostty
    read -r -d '' SUDO_CONFIG << EOM
$USER ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/yay
Defaults:$USER env_keep += "TERMINFO TERM"
EOM

    echo "$SUDO_CONFIG" | sudo tee /etc/sudoers.d/ska-automation
    sudo chmod 440 /etc/sudoers.d/ska-automation
    echo "✅ Permisos de sudo y entorno configurados."
fi

# 3. Inicialización de Chezmoi (Dotfiles)[cite: 1]
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "🏠 Clonando repositorio $REPO_NAME..."
    # --apply descarga y coloca los archivos de config inmediatamente
    chezmoi init --apply "$DOTFILES_REPO"
else
    echo "🔄 Actualizando repositorio de configuraciones..."
    chezmoi update
fi

# 4. Ejecución de Ansible Playbook[cite: 1]
ANSIBLE_MAIN="$DOTFILES_DIR/ansible/main.yml"

if [ -f "$ANSIBLE_MAIN" ]; then
    echo "🤖 Ejecutando Ansible para instalar software y servicios..."
    # Instalamos las colecciones necesarias para manejar AUR y Pacman[cite: 1]
    ansible-galaxy collection install community.general kewlfft.aur
    
    # Ejecutamos sin el flag -K porque ya tenemos NOPASSWD configurado
    ansible-playbook "$ANSIBLE_MAIN"
else
    echo "❌ Error: No se encontró el archivo $ANSIBLE_MAIN"
    exit 1
fi

echo "---"
echo "✅ ¡Proceso completado con éxito!"
echo "💡 Se recomienda reiniciar la terminal para activar el shell Fish y los grupos de Docker."
