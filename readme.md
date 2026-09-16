# setupbc250arch
Run the following scripts in order after [BIOS flashing](elektricm.github.io/amd-bc250-docs/bios/flashing)[^1][^2][^3] on Arch Linux.
1. `setup-bc250-arch-1.sh`
2. `setup-bc250-arch-2.sh`
3. `setup-llmtune.sh` (optional)

These BC-250 installation scripts set up:
- `bc250_memcfg` — lower VRAM split (VRAM minimum) to 512MB
- Disable `amd_iommu` (kernel parameter)
- Quiet boot `quiet` (kernel parameter)
- Expand `ttm` shared GPU memory limit to allow up to full physical pool (kernel parameter)
- GPU governor (`cyan-skillfish-governor-smu`)
- ACPI fix — C-States only, P-States excluded
- GPU overclock to 2230MHz @ 1100mV (`cyan-skillfish-governor-smu`)
- RADV driver (`mesa vulkan-radeon lib32-vulkan-radeon`)
- Monitors (`radeontop nvtop`)
- CPU 8-core unlock (`bc250-core-cu-unlock`)
- UMR for 40cu unlock (`umr`)
- GPU from 24 to up to 40 CU/WGP unlock (`bc250-cu-live-manager.sh`)
- CPU overclock to 3900MHz (`bc250-smu-oc`)

Additionally, `setup-llmtune.sh` installs:
- huggingface downloader
- cachenetics/llmtune
- llama-server (prism-vulkan)
- cachenetics/arieltune for monitoring

[^1]: ROM: https://gitlab.com/TuxThePenguin0/bc250-bios/-/blob/main/BC250_3.00_CHIPSETMENU.ROM
(SHA256: 48fbe5d366e6a56e2fdffdca848426216ba1f083610dab63db89d2f4e6c940b5)
[^2]: https://elektricm.github.io/amd-bc250-docs/bios/flashing
[^3]: https://bc-250.com/wiki?article=bios%2F02-bios-and-firmware
