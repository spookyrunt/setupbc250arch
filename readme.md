# setupbc250arch
Run all scripts one by one after [BIOS flashing](https://elektricm.github.io/amd-bc250-docs/bios/flashing)[^1][^2][^3] on Arch Linux. This project includes two BC-250 install scripts setting up:
- `bc250_memcfg` — lower VRAM split (VRAM minimum) to 512MB
- Disable `amd_iommu` (kernel parameter)
- Quiet boot `quiet` (kernel parameter)
- Expand `ttm` shared GPU memory limit to allow up to full physical pool (kernel parameter)
- Install `cyan-skillfish-governor-smu` and `radeontop`
- ACPI fix — C-States only, P-States excluded
- GPU overclock to 2230MHz @ 1100mV (`cyan-skillfish-governor-smu`)
- CPU 8-core unlock (`bc250-core-cu-unlock`)
- GPU from 24 to up to 40 CU/WGP unlock (`bc250-cu-live-manager.sh`)
- CPU overclock to 3900MHz (`bc250-smu-oc`)

The following script is `setup-llmtune.sh` installing:
- RADV driver
- huggingface downloader
- cachenetics/llmtune

[^1]: ROM: https://gitlab.com/TuxThePenguin0/bc250-bios/-/blob/main/BC250_3.00_CHIPSETMENU.ROM
(SHA256: 48fbe5d366e6a56e2fdffdca848426216ba1f083610dab63db89d2f4e6c940b5)
[^2]: https://elektricm.github.io/amd-bc250-docs/bios/flashing
[^3]: https://bc-250.com/wiki?article=bios%2F02-bios-and-firmware
