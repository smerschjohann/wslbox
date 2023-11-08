#!/bin/bash

set -eo pipefail

function build_data {
    buildah rm devdata || true
    buildah from --name devdata busybox:latest
    buildah unshare --mount devdata sh -c 'tar -czf wsl-data.tar.gz -C $devdata .'
    buildah rm devdata
}

function reset_build_data {
    build_data
    wsl.exe --unregister wsl-data-dev || true
    WINHOME_LIN=$(wslpath $(powershell.exe Write-Output '$env:USERPROFILE') | tr -d '\r')
    WINHOME=$(wslpath -w "$WINHOME_LIN")
    wsl.exe --import wsl-data-dev "${WINHOME}\\wsl\\wsl-data" "./wsl-data.tar"
    wsl.exe -d wsl-data-dev /mount.sh
}

function build_wsl {
    local variant=$1
    rm "devbox-${variant}-wsl.tar" || true

    buildah bud --format=docker -f "docker/${variant}/Dockerfile" -t "devbox-${variant}:latest" .
    buildah from --name devdevdev "localhost/devbox-${variant}:latest"
    buildah unshare --mount devdevdev sh -c 'tar -czf devbox-'"${variant}"'-wsl.tar.gz -C $devdevdev .'
    buildah rm devdevdev
}

function import_wsl {
    local variant=$1
    local wslname=$2
    echo "installing ${variant} as WSL distribution: ${wslname}"
    WINHOME_LIN=$(wslpath $(powershell.exe Write-Output '$env:USERPROFILE') | tr -d '\r')
    WINHOME=$(wslpath -w "$WINHOME_LIN")
    wsl.exe --import "${wslname}" "${WINHOME}\\wsl\\${wslname}" "./devbox-${variant}-wsl.tar"
}

function build_import {
    local variant=$1
    local wslname=$2
    build_wsl "${variant}"
    import_wsl "${variant}" "${wslname}"
    echo "new build imported"
}

function delete_build_import {
    local variant=$1
    local wslname=$2
    delete_devbox "${wslname}"
    build_wsl "${variant}"
    import_wsl "${variant}" "${wslname}"
    echo "new build imported"
}

function delete_devbox {
    local wslname=$1
    wsl.exe --unregister "${wslname}" || true
}

function devbox {
    local wslname=$1
    wsl.exe -d "${wslname}"
}

# Main switch case to handle command line arguments
case "$1" in
    build_data)
        build_data
        ;;
    reset_build_data)
        reset_build_data
        ;;
    build_wsl)
        build_wsl "$2"
        ;;
    import_wsl)
        import_wsl "$2" "$3"
        ;;
    build_import)
        build_import "$2" "$3"
        ;;
    delete_build_import)
        delete_build_import "$2" "$3"
        ;;
    build_wsl_compressed)
        build_wsl_compressed "$2"
        ;;
    delete_devbox)
        delete_devbox "$2"
        ;;
    devbox)
        devbox "$2"
        ;;
    *)
        echo "Usage: $0 {build_data|reset_build_data|build_wsl|import_wsl|build_import|delete_build_import|build_wsl_compressed|delete_devbox|devbox} [args]";
        exit 1
        ;;
esac

exit 0
