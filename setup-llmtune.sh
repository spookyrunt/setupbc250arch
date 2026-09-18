#!/bin/bash
set -euo pipefail

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

# profiles.toml overrides.toml under user
(
  cd ~/.config/llmtune
  [ -f profiles.toml ] && mv profiles.toml profiles.toml.bak
  [ -f overrides.toml ] && mv overrides.toml overrides.toml.bak
)
cp profiles.toml ~/.config/llmtune/profiles.toml
cp overrides.toml ~/.config/llmtune/overrides.toml

# history.json under root
sudo mkdir -p /var/lib/llmtune/localhost
(
  cd /var/lib/llmtune/localhost
  [ -f history.json ] && sudo mv history.json history.json.bak
)
sudo cp history.json /var/lib/llmtune/localhost/history.json

# arieltune
[ -d build/project-ariel ] || git clone https://github.com/cachenetics/project-ariel.git build/project-ariel
(
  cd project-ariel
  ./install.sh # release build + install to /usr/local/bin
)
