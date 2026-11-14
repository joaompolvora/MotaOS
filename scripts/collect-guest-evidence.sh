#!/bin/bash
set -Eeuo pipefail
target="$HOME/motaos-evidence-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$target"
exec > >(tee "$target/diagnostics.txt") 2>&1
uname -a
cat /etc/os-release
localectl status
timedatectl status
nmcli device status
ip address
ip route
getent hosts www.debian.org
curl --fail --location https://www.debian.org/ -o "$target/debian.html"
wpctl status
xrandr --current
systemctl --failed
findmnt /
lsblk -f
sudo journalctl -b --no-pager > "$target/journal.txt"
echo "Evidências em $target. Este diagnóstico não substitui os testes manuais."
