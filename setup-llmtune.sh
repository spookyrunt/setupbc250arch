#!/bin/bash
set -euo pipefail

# RADV Driver
sudo sed -i '/^[[:space:]]*#\[multilib\]/,/^[[:space:]]*#Include[[:space:]]*=.*mirrorlist/ s/^[[:space:]]*#//' /etc/pacman.conf
sudo pacman -Syu --noconfirm mesa vulkan-radeon lib32-vulkan-radeon
sudo pacman -S --needed --noconfirm vulkan-tools mesa-utils

# hf download
sudo pacman -S --needed --noconfirm python-huggingface-hub

# llmtune
[ -d build/llmtune ] || git clone https://github.com/cachenetics/llmtune.git build/llmtune
(
  cd build/llmtune
  ./install.sh # cargo build --release, installs to /usr/local/bin
)
sudo pacman -S --needed --noconfirm base-devel cmake git vulkan-headers vulkan-icd-loader spirv-headers shaderc vulkan-radeon
llmtune setup
sudo llmtune build install vulkan
sudo llmtune build install prism-vulkan
# sudo llmtune build update vulkan --ref=master # unstable for bc250

# link
[ -f /usr/local/bin/llama-server ] || sudo ln -s /var/lib/llmtune/src/vulkan/build/bin/llama-server /usr/local/bin/llama-server
[ -f /usr/local/bin/prism-llama-server ] || sudo ln -s /var/lib/llmtune/src/prism-vulkan/build/bin/llama-server /usr/local/bin/prism-llama-server
[ -d ~/models ] || ln -s /var/lib/llmtune/models ~/models
[ -d ~/config ] || ln -s ~/.config/llmtune ~/config
(
  cd ~/.config/llmtune
  [ -f profile.toml ] && mv profile.toml profile.toml.bak
)
cp profile.toml ~/.config/llmtune/profile.toml

# arieltune
[ -d build/project-ariel ] || git clone https://github.com/cachenetics/project-ariel.git build/project-ariel
(
  cd project-ariel
  ./install.sh # release build + install to /usr/local/bin
)
