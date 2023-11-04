#!/bin/bash

set -eo pipefail

startWslData() {
    /mnt/c/Windows/system32/wsl.exe -d wsl-data << EOF
    mkdir -p /data;
    mkdir -p /mnt/wsl/data;
    umount /mnt/wsl/data 2> /dev/null || true; 
    mount -o bind /data /mnt/wsl/data;
    chmod a+rwx /mnt/wsl/data;
    echo mounted.
EOF
}

if ! grep -q "/mnt/wsl/data" /proc/mounts; then
    startWslData

    while true; do
        sleep 3
        if grep -q "/mnt/wsl/data" /proc/mounts; then
            break
        fi
    done
fi

mkdir -p /mnt/wsl/data/home
mount -o bind /mnt/wsl/data/home /home