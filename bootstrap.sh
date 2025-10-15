#!/bin/bash

# ==============================================================================
# Bootstrap Script for a Developer Environment
# ==============================================================================
#
# This script automates the setup of a development environment on a fresh
# Ubuntu system. It installs essential tools, development languages, and
# configures the shell with personal dotfiles.
#
# It will:
# 1. Update system packages.
# 2. Install core dependencies (git, stow, curl, build-essential, zsh).
# 3. Install Zsh and Oh My Zsh.
# 4. Clone your dotfiles repository (if not already present).
# 5. Symlink your configurations using GNU Stow.
# 6. Install Neovim (Nightly), Go, NVM, and Tmux.
# 7. Change the default shell to Zsh.
#
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# Define variables for versions and paths
GO_VERSION="1.22.5"
DOTFILES_REPO="https://github.com/your-username/dotfiles.git" # <-- CHANGE THIS
DOTFILES_DIR="$HOME/dotfiles"

# --- 1. PRE-RUN CHECKS AND SUDO PROMPT ---
echo "🚀 Starting setup..."
echo "This script will set up your development environment."
echo "Requesting sudo privileges for installation..."
# "Prime" sudo by asking for the password upfront
sudo -v
# Keep sudo session alive while the script is running
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# --- 2. SYSTEM UPDATE & CORE DEPENDENCIES ---
echo "🔄 Updating packages and installing core dependencies..."
sudo apt-get update
sudo apt-get install -y git stow curl build-essential zsh


# --- 3. INSTALL ZSH & OH MY ZSH ---
echo "셸 Installing Zsh and Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # The installer will try to run zsh at the end, so we use 'sh -c'
  # It will create a default .zshrc, which we will replace with our own via stow.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi


# --- 4. CLONE DOTFILES REPO ---
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repository from $DOTFILES_REPO..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "Dotfiles repository already exists at $DOTFILES_DIR."
fi
cd "$DOTFILES_DIR"


# --- 5. SYMLINK DOTFILES WITH STOW ---
echo "🔗 Symlinking dotfiles with GNU Stow..."
# Remove the default .zshrc created by Oh My Zsh before stowing our own
rm -f "$HOME/.zshrc"
# Stow all packages. This will link your custom .zshrc, .tmux.conf, etc.
stow */


# --- 6. INSTALL APPLICATIONS AND TOOLCHAINS ---

## Install Neovim (Nightly AppImage)
echo "👾 Installing Neovim (Nightly)..."
# Download the AppImage to a temporary location
curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage -o /tmp/nvim.appimage
# Make it executable
chmod +x /tmp/nvim.appimage
# Move it to a location in the system's PATH
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim

## Install Go
echo "Installing Go v$GO_VERSION..."
# Download the tarball
wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
# Remove any previous Go installation
sudo rm -rf /usr/local/go
# Extract the new version
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
# Clean up
rm /tmp/go.tar.gz
# Note: The PATH for Go should be set in your .zshrc file, like so:
# export PATH=$PATH:/usr/local/go/bin

## Install Tmux
echo "Installing Tmux..."
sudo apt-get install -y tmux

## Install Docker and Docker Compose
echo "🐳 Installing Docker..."
# Add Docker's official GPG key and set up the repository (the 'keyring' step)
sudo apt-get install -y ca-certificates
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Add current user to the docker group to run docker without sudo
sudo usermod -aG docker $USER
echo "Docker installed. You may need to log out and log back in for group changes to take effect."

## Install NVM (Node Version Manager)
echo "Installing NVM (Node Version Manager)..."
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  echo "NVM is already installed."
fi
# Note: The sourcing of nvm.sh should be handled by your .zshrc


# --- 7. CHANGE DEFAULT SHELL ---
if [ "$SHELL" != "/usr/bin/zsh" ]; then
  echo "Changing default shell to Zsh..."
  chsh -s "$(which zsh)"
  echo "Default shell changed to Zsh."
else
  echo "Default shell is already Zsh."
fi


# --- FINAL MESSAGE ---
echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Close and reopen your terminal to start using Zsh."
echo "2. If you are not in a new zsh session, you may need to log out and log back in."
echo "3. Run 'source ~/.zshrc' to load your new configuration."
echo "4. Run 'nvm install --lts' to install the latest LTS version of Node.js."


