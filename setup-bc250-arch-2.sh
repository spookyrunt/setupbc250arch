#!/bin/bash
set -euo pipefail

# Verify 8 physical cores are active
CORES=$(lscpu --parse=CORE | grep -v '^#' | sort -u | wc -l)
if [ "$CORES" -ne 8 ]; then
  echo "Only ${CORES} physical cores active (8 required)."
  if [ "$CORES" -eq 6 ]; then
    echo "Please warm-reboot in order to enable 8 cores unlocked."
  fi
  exit 1
fi

# cpu overclock
sudo pacman -S --needed python-pipx stress
[ -d ~/bc250_smu_oc ] || git clone https://github.com/bc250-collective/bc250_smu_oc.git ~/bc250_smu_oc
cd ~/bc250_smu_oc
pipx install --force .
export PATH="$HOME/.local/bin:$PATH"
bc250-detect --frequency 3900 --vid 1300
bc250-apply --install overclock.conf
sudo systemctl enable --now bc250-smu-oc.service
echo ""
echo "Result:"
cat /etc/bc250-smu-oc.conf
# grep 'cpu MHz' /proc/cpuinfo | head -8

echo ""
echo "Done."
