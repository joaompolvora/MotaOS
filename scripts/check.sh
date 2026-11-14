#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$ROOT"
while IFS= read -r -d '' script; do bash -n "$script"; done < <(
  find scripts auto config/hooks config/includes.chroot/usr/local -type f \
    \( -name '*.sh' -o -name '*.hook.chroot' -o -name 'motaos-*' -o -path auto/config \) -print0)
python3 scripts/validate.py
if command -v shellcheck >/dev/null; then
  shellcheck -e SC1091 scripts/*.sh config/hooks/live/*.hook.chroot \
    config/includes.chroot/usr/local/bin/motaos-* config/includes.chroot/usr/local/sbin/motaos-target-cleanup
fi
echo 'Verificação estática concluída; não comprova boot nem instalação.'
