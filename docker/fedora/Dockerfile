FROM registry.fedoraproject.org/fedora-toolbox:39 as devbox

# NOTE:
# the amount of layers is not important! We export it as a flat filesystem tarball. 
# So feel free to add as many layers as you want

RUN dnf install -y systemd nfs-utils cracklib-dicts python sqlite3 tcpdump ethtool zstd zip p7zip p7zip-plugins
RUN dnf install -y distrobox fzf zsh vim btop jq golang socat just age moreutils helm podman buildah docker

# Intellij X tools
RUN dnf install -y e2fsprogs-libs libXrender libXtst freetype
RUN dnf install rsms-inter-fonts.noarch fira-code-fonts.noarch -y

COPY --chown=0:0 system_files/common /
COPY --chown=0:0 system_files/fedora /
RUN chmod u+rwx /usr/sbin/*
RUN systemctl enable mount-home.service

# install rpms from new repos, disable the ones only temporary needed
RUN dnf install -y kubectl && dnf config-manager --disable kubernetes

# buildkit support
RUN mkdir -p /usr/lib/docker/cli-plugins/; \
    curl -Lo /usr/lib/docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64 && \
    chmod a+x /usr/lib/docker/cli-plugins/docker-buildx

# disable selinux as parts does not seem to be compatible with WSL2
RUN sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# k3s installed, but disabled by default. You can start it by systemctl start k3s. It uses docker mode 
RUN curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_EXEC="server --disable traefik --write-kubeconfig-mode 644" sh -s - 

# some container utils
RUN curl -L https://github.com/google/go-containerregistry/releases/download/v0.16.1/go-containerregistry_Linux_x86_64.tar.gz | tar xzf - -C /usr/local/bin/ crane gcrane
RUN chmod a+x /usr/local/bin/*

RUN mkdir -p /usr/lib/binfmt.d
RUN echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf
#RUN systemctl restart systemd-binfmt

# java 8 development
RUN dnf install -y java-1.8.0-openjdk-devel maven-openjdk8

# todo helmfile bw
# https://github.com/bitwarden/clients/releases/download/cli-v2023.9.0/bw-linux-2023.9.0.zip

# final cleanup
RUN dnf clean all && rm -rf /var/cache/yum
