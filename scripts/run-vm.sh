#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
firmware=${1:-bios}
mode=${2:-live}
[[ $firmware == bios || $firmware == uefi ]] || { echo 'Use bios ou uefi.'; exit 1; }
[[ $mode == live || $mode == installed ]] || { echo 'Use live ou installed.'; exit 1; }
[[ $EUID != 0 ]] || { echo 'Execute a VM como usuário comum.'; exit 1; }
for command in qemu-system-x86_64 qemu-img; do command -v "$command" >/dev/null; done
mkdir -p "$ROOT/vms/$firmware" "$ROOT/logs"
disk="$ROOT/vms/$firmware/system.qcow2"
[[ ! -L $disk ]] || { echo 'Disco não pode ser link simbólico.'; exit 1; }
if [[ ! -e $disk ]]; then
  [[ $mode == live ]] || { echo 'Instale primeiro usando o modo live.'; exit 1; }
  qemu-img create -f qcow2 "$disk" 40G
fi
accel=(-accel tcg -cpu max)
[[ ! -r /dev/kvm || ! -w /dev/kvm ]] || accel=(-accel kvm -cpu host)
args=(-name "MotaOS-$firmware" -machine q35 "${accel[@]}" -m 4096 -smp 2
  -drive "file=$disk,if=virtio,format=qcow2"
  -device virtio-vga -display gtk -nic user,model=virtio-net-pci
  -audiodev "${MOTA_AUDIO_BACKEND:-pa},id=audio0"
  -device ich9-intel-hda -device hda-duplex,audiodev=audio0
  -device qemu-xhci -device usb-tablet
  -spice addr=127.0.0.1,port=5930,disable-ticketing=on
  -device virtio-serial-pci -chardev spicevmc,id=vdagent,name=vdagent
  -device virtserialport,chardev=vdagent,name=com.redhat.spice.0
  -serial "file:$ROOT/logs/serial-$firmware.log")
if [[ $firmware == uefi ]]; then
  code=/usr/share/OVMF/OVMF_CODE_4M.fd
  vars=/usr/share/OVMF/OVMF_VARS_4M.fd
  [[ -r $code && -r $vars ]] || { echo 'Instale ovmf.'; exit 1; }
  [[ -e $ROOT/vms/uefi/vars.fd ]] || cp "$vars" "$ROOT/vms/uefi/vars.fd"
  args+=(-drive "if=pflash,format=raw,readonly=on,file=$code"
    -drive "if=pflash,format=raw,file=$ROOT/vms/uefi/vars.fd")
fi
if [[ $mode == live ]]; then
  iso="$ROOT/dist/motaos-0.1-trixie-amd64.hybrid.iso"
  [[ -s $iso ]] || { echo "ISO ausente: $iso"; exit 1; }
  args+=(-cdrom "$iso" -boot order=d)
else
  args+=(-boot order=c)
fi
qemu-system-x86_64 "${args[@]}" 2>&1 | tee "$ROOT/logs/qemu-$firmware.log"
