#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

failed="\e[1;5;31mfailed\e[0m"

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
file="${dir}/$(basename "${BASH_SOURCE[0]}")"
base="$(basename ${file} .sh)"
root="$dir"
mem=${ST_QEMU_MEM:-8192}

image="${root}/deploy/mixed-firmware/Syslinux_Linuxboot.img"

qemu-system-x86_64 -drive if=virtio,file=${image},format=raw -net user -net nic -device virtio-rng-pci -rtc base=localtime -m ${mem} -nographic
