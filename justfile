build-data:
    docker rm devdata || true
    docker create --name devdata busybox:latest
    docker export devdata -o wsl-data.tar
    docker rm devdata

reset-build-data: build-data
    wsl.exe --unregister wsl-data-dev
    WINHOME_LIN=$(wslpath $(powershell.exe Write-Output '$env:USERPROFILE') | tr -d '\r')
    WINHOME=$(wslpath $WINHOME_LIN)
    wsl.exe --import wsl-data-dev "$WINHOME\wsl\wsl-data" "./wsl-data.tar"
    wsl.exe -d wsl-data-dev /mount.sh

build variant="fedora":
    docker build . -f docker/{{variant}}/Dockerfile -t devbox-{{variant}}:latest

build-wsl variant="fedora": (build variant)
    rm devbox-{{variant}}-wsl.tar || true
    docker rm devdevdev || true
    docker create --name devdevdev devbox-{{variant}}:latest
    docker export devdevdev -o devbox-{{variant}}-wsl.tar
    docker rm devdevdev

@import-wsl variant="fedora" wslname="devbox":
    #!/bin/bash
    echo "installing {{variant}} as WSL distribution: {{wslname}}"
    # get rid of some special characters by converting to and from linux path variant
    WINHOME_LIN=$(wslpath $(powershell.exe Write-Output '$env:USERPROFILE') | tr -d '\r')
    WINHOME=$(wslpath -w $WINHOME_LIN)
    wsl.exe --import {{wslname}} "$WINHOME\wsl\{{wslname}}" "./devbox-{{variant}}-wsl.tar"

build-import variant="fedora" wslname="devbox": (build-wsl variant) (import-wsl variant wslname)
    echo new build imported

delete-build-import variant="fedora" wslname="devbox": (delete-devbox wslname) (build-wsl variant) (import-wsl variant wslname)
    echo new build imported

build-wsl-compressed variant="fedora": (build-wsl variant)
    7za a devbox-{{variant}}-wsl.tar.xz devbox-{{variant}}-wsl.tar

delete-devbox wslname="devbox":
    wsl.exe --unregister {{wslname}} || true

devbox wslname="devbox":
    wsl.exe -d {{wslname}}