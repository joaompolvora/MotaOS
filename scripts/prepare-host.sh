#!/bin/bash
set -Eeuo pipefail
[[ $EUID == 0 ]] || { echo 'Execute com sudo.' >&2; exit 1; }
source /etc/os-release
[[ $ID == debian && $VERSION_CODENAME == trixie && $(dpkg --print-architecture) == amd64 ]] || {
  echo 'Use uma VM Debian 13 trixie amd64 dedicada ao build.' >&2; exit 1;
}
apt-get update
apt-get install --yes live-build debootstrap ca-certificates squashfs-tools xorriso \
  isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin mtools dosfstools \
  qemu-system-x86 qemu-utils ovmf virt-viewer git rsync python3 python3-yaml shellcheck
echo 'Ambiente preparado. Execute sudo bash scripts/build.sh.'
