#!/bin/bash
set -euo pipefail

# https://elektricm.github.io/amd-bc250-docs/bios/flashing/#post-flash-configuration

# memcfg
[ -d bc250_memcfg ] || git clone https://github.com/fanoush/bc250_memcfg
(
  cd bc250_memcfg
  make
  sudo ./bc250memcfg UMA_SIZE 512
)

# amd iommu off
grep -qw amd_iommu=off /etc/kernel/cmdline || echo -n ' amd_iommu=off' | sudo tee -a /etc/kernel/cmdline
grep -qw quiet /etc/kernel/cmdline || echo -n ' quiet' | sudo tee -a /etc/kernel/cmdline
# sudo mkinitcpio -P

# kernel parameters for maximum GPU memory access (16GB / full physical pool)
sudo sed -i -E \
  -e 's/ *amdgpu\.gttsize=[0-9]*//g' \
  -e 's/ *ttm\.pages_limit=[0-9]*//g' \
  -e 's/ *ttm\.page_pool_size=[0-9]*//g' \
  /etc/kernel/cmdline
echo -n ' ttm.pages_limit=4194304' | sudo tee -a /etc/kernel/cmdline
echo -n ' ttm.page_pool_size=4194304' | sudo tee -a /etc/kernel/cmdline
sudo sed -i -E -e 's/[[:space:]]+/ /g' -e 's/^[[:space:]]+//' -e 's/[[:space:]]+$//' /etc/kernel/cmdline
# sudo mkinitcpio -P

# gpu governor & radeontop
if ! command -v yay >/dev/null 2>&1; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (
    cd /tmp/yay
    makepkg -si --noconfirm
  )
  rm -rf /tmp/yay
fi
yay -S --needed --noconfirm cyan-skillfish-governor-smu
sudo systemctl enable --now cyan-skillfish-governor-smu.service
sudo pacman -S --needed --noconfirm radeontop

# acpi fix (C-states only, P-states doesn't work per upstream README)
[ -d bc250-acpi-fix-updated-8c ] || git clone https://github.com/mendesrr/bc250-acpi-fix-updated-8c
sudo mkdir -p /etc/initcpio/acpi_override
sudo cp bc250-acpi-fix-updated-8c/SSDT-CST.aml /etc/initcpio/acpi_override/
if ! grep -qw acpi_override /etc/mkinitcpio.conf; then
  sudo sed -i 's/^HOOKS=(\(.*\))/HOOKS=(acpi_override \1)/' /etc/mkinitcpio.conf
fi
sudo mkinitcpio -P

# governer gpu clock boost
sudo sed -i '/^\[frequency-range\]/,/^\[/ s/^max = [0-9]*/max = 2230/' /etc/cyan-skillfish-governor-smu/config.toml
sudo sed -i '/frequency = 2000/{n;s/voltage = [0-9]*/voltage = 1000/}' /etc/cyan-skillfish-governor-smu/config.toml
if ! grep -q "frequency = 2230" /etc/cyan-skillfish-governor-smu/config.toml; then
  cat <<'EOF' | sudo tee -a /etc/cyan-skillfish-governor-smu/config.toml

[[safe-points]]
frequency = 2050
voltage = 1050

[[safe-points]]
frequency = 2100
voltage = 1050

[[safe-points]]
frequency = 2125
voltage = 1050

[[safe-points]]
frequency = 2150
voltage = 1100

[[safe-points]]
frequency = 2200
voltage = 1100

[[safe-points]]
frequency = 2230
voltage = 1100

[[safe-points]]
frequency = 2300
voltage = 1150
EOF
fi
sudo systemctl restart cyan-skillfish-governor-smu

# 8 core cpu unlock
[ -d bc250-core-cu-unlock ] || git clone https://github.com/GabriWar/bc250-core-cu-unlock
cd bc250-core-cu-unlock
sudo systemctl stop cyan-skillfish-governor-smu
sudo ./bc250-8core-unlock.sh status  # show the current mask
sudo ./bc250-8core-unlock.sh apply   # unlock now
sudo ./bc250-8core-unlock.sh install # persist: installs and enables a systemd unit
sudo systemctl start cyan-skillfish-governor-smu
cd ..

# 24+ ~40 cu gpu unlock
yay -S --needed --noconfirm umr
echo ""
echo "Do: e - w - i witin bc250-cu-live-manager.sh"
curl -L -o bc250-cu-live-manager.sh https://raw.githubusercontent.com/WinnieLV/bc250-cu-live-manager/refs/heads/main/bc250-cu-live-manager.sh
chmod +x bc250-cu-live-manager.sh
sudo ./bc250-cu-live-manager.sh

echo ""
echo "Done. Please reboot."
