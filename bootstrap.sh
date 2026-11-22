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
# Clone over HTTPS (a fresh machine has no SSH key yet); push goes over SSH.
DOTFILES_REPO="https://github.com/FlipLucky/dotfiles.git"
DOTFILES_PUSH="git@github.com:FlipLucky/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
export NVM_DIR="$HOME/.config/nvm"   # must match zsh/.zshrc

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
sudo apt-get install -y git stow curl wget build-essential zsh git-delta
# Neovim runtime deps: pickers (rg/fd), clipboard (Wayland + X11),
# Mason (unzip, python venvs for pip-based tools)
sudo apt-get install -y ripgrep fd-find wl-clipboard xclip unzip python3-venv
# Ubuntu ships fd as `fdfind`; plugins look for `fd`
mkdir -p "$HOME/.local/bin"
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"


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
  git -C "$DOTFILES_DIR" remote set-url --push origin "$DOTFILES_PUSH"
else
  echo "Dotfiles repository already exists at $DOTFILES_DIR."
fi
cd "$DOTFILES_DIR"


# --- 5. SYMLINK DOTFILES WITH STOW ---
echo "🔗 Symlinking dotfiles with GNU Stow..."
# A fresh install ships its own .bashrc (and Oh My Zsh just wrote a .zshrc).
# Stow refuses to overwrite real files, so move them aside first.
for f in .zshrc .bashrc .gitconfig .tmux.conf; do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$HOME/$f.pre-stow"
  fi
done
# Stow all packages. This will link your custom .zshrc, .tmux.conf, etc.
stow */


# --- 6. INSTALL APPLICATIONS AND TOOLCHAINS ---

## Install Neovim (Nightly tarball: vim.pack needs 0.12+)
# The tarball avoids the AppImage's libfuse2 dependency. The old
# `nvim.appimage` asset name is gone (404); -f makes curl fail instead of
# saving the error page as the "binary".
echo "👾 Installing Neovim (Nightly)..."
curl -fL https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz
sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf /tmp/nvim.tar.gz
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm /tmp/nvim.tar.gz

## Install Go: latest stable unless GO_VERSION is set (GO_VERSION=1.27.4 ./bootstrap.sh)
GO_VERSION="${GO_VERSION:-$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1 | sed 's/^go//')}"
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

## Install NVM (Node Version Manager) + Node LTS
# Into ~/.config/nvm (NVM_DIR above), which is where .zshrc looks; the
# installer's default ~/.nvm would leave nvm "not found" in the shell.
# Node is needed by Mason for npm-based language servers.
echo "Installing NVM (Node Version Manager)..."
mkdir -p "$NVM_DIR"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
else
  echo "NVM is already installed."
fi
set +e   # nvm.sh isn't safe under `set -e`
. "$NVM_DIR/nvm.sh"
nvm install --lts
set -e


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
echo "3. Start nvim and accept the plugin install prompt (vim.pack), then restart it."
echo "   Mason installs the language servers in the background; check with :Mason."
echo "   blink.cmp downloads its prebuilt fuzzy binary, no Rust needed."
echo "4. Copy your SSH key to ~/.ssh before pushing dotfiles (push goes over SSH)."


