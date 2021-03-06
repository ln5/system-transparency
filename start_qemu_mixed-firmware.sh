#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Source global build config file.
if [ $# -gt 0 ]; then
    run_config=$1; shift
    [ -r ${run_config} ] && source ${run_config}
fi

failed="\e[1;5;31mfailed\e[0m"

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
file="${dir}/$(basename "${BASH_SOURCE[0]}")"
base="$(basename ${file} .sh)"
root="$dir"
mem=${ST_QEMU_MEM:-8192}

image="${root}/deploy/mixed-firmware/Syslinux_Linuxboot.img"


qemu-system-x86_64 \
  -drive if=virtio,file=${image},format=raw \
  -nographic \
  -net user,hostfwd=tcp::2222-:2222 \
  -net nic \
  -object rng-random,filename=/dev/urandom,id=rng0 \
  -device virtio-rng-pci,rng=rng0 \
  -rtc base=localtime \
  -m ${mem}
