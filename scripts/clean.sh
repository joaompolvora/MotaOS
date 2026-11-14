#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
[[ $EUID == 0 ]] || { echo 'Execute com sudo.'; exit 1; }
[[ -d $ROOT/build && ! -L $ROOT/build && -f $ROOT/build/.motaos-build ]] || { echo 'Diretório de build identificado não encontrado.'; exit 1; }
[[ $(realpath "$ROOT/build") == "$ROOT/build" ]] || exit 1
cd "$ROOT/build"
lb clean --purge
if findmnt -rn -o TARGET | grep -F -- "$ROOT/build/"; then
  echo 'Há montagens dentro do build. Desmonte-as antes de limpar.'; exit 1
fi
cd "$ROOT"
rm -rf -- "$ROOT/build"
echo 'Build removido. dist/, logs/ e vms/ foram preservados.'
