#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
mkdir -p "$ROOT/logs"
if [[ $EUID == 0 && -n ${SUDO_UID:-} ]]; then
  chown "$SUDO_UID:${SUDO_GID:-$SUDO_UID}" "$ROOT/logs"
fi
exec > >(tee "$ROOT/logs/build-$(date -u +%Y%m%dT%H%M%SZ).log") 2>&1
trap 'echo "ERRO: linha $LINENO; consulte logs/." >&2' ERR
[[ $(uname -s) == Linux && $EUID == 0 ]] || { echo 'Build requer Linux e sudo.'; exit 1; }
source /etc/os-release
[[ $ID == debian && $VERSION_CODENAME == trixie && $(dpkg --print-architecture) == amd64 ]] || {
  echo 'Host requerido: Debian 13 trixie amd64.'; exit 1;
}
for command in lb debootstrap xorriso rsync python3 mountpoint; do command -v "$command" >/dev/null; done
[[ $(df --output=avail -BG "$ROOT" | tail -1 | tr -dc '0-9') -ge 30 ]] || { echo 'Reserve pelo menos 30 GiB livres.'; exit 1; }
[[ ! -e "$ROOT/build" ]] || { echo 'Build existente: execute scripts/clean.sh antes de reconstruir.'; exit 1; }
bash "$ROOT/scripts/check.sh"
mkdir "$ROOT/build"
touch "$ROOT/build/.motaos-build"
rsync -a "$ROOT/auto" "$ROOT/config" "$ROOT/build/"
chmod +x "$ROOT/build/auto/config" "$ROOT/build/config/hooks/live/"*.hook.chroot
cd "$ROOT/build"
dpkg-query -W live-build debootstrap xorriso > host-versions.tsv
lb config
lb build
image=motaos-0.1-trixie-amd64.hybrid.iso
[[ -s $image ]] || { echo "ISO esperada ausente: $image"; exit 1; }
xorriso -indev "$image" -report_el_torito plain 2>&1 | tee boot-catalog.txt
grep -q BIOS boot-catalog.txt
grep -q UEFI boot-catalog.txt
mkdir -p "$ROOT/dist"
cp "$image" "$ROOT/dist/"
cp host-versions.tsv boot-catalog.txt "$ROOT/dist/"
cp chroot/usr/share/motaos/package-versions.tsv "$ROOT/dist/"
mkdir -p "$ROOT/dist/installer-config"
cp -a chroot/etc/calamares/. "$ROOT/dist/installer-config/"
find . -maxdepth 1 -name '*.packages' -exec cp '{}' "$ROOT/dist/" \;
cd "$ROOT/dist"
sha256sum "$image" > SHA256SUMS
echo "ISO e SHA-256 disponíveis em $ROOT/dist. Boot e instalação ainda precisam de teste em VM."
