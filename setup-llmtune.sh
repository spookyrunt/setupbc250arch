#!/bin/bash
set -euo pipefail

# RADV Driver
sudo sed -i '/^[[:space:]]*#\[multilib\]/,/^[[:space:]]*#Include[[:space:]]*=.*mirrorlist/ s/^[[:space:]]*#//' /etc/pacman.conf
sudo pacman -Syu --noconfirm mesa vulkan-radeon lib32-vulkan-radeon
sudo pacman -S --needed --noconfirm vulkan-tools mesa-utils

# hf download
sudo pacman -S --needed --noconfirm python-huggingface-hub

# llmtune
[ -d llmtune ] || git clone https://github.com/cachenetics/llmtune
(
  cd llmtune
  ./install.sh # cargo build --release, installs to /usr/local/bin
)
sudo pacman -S --needed --noconfirm base-devel cmake git vulkan-headers vulkan-icd-loader spirv-headers shaderc vulkan-radeon
llmtune setup
llmtune build install vulkan
llmtune build install prism-vulkan
