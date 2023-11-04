FROM ubuntu:22.04

# NOTE:
# the amount of layers is not important! We export it as a flat filesystem tarball. 
# So feel free to add as many layers as you want

# use https:// everywhere.
RUN apt-get update
RUN apt-get install -y systemd sudo ubuntu-wsl tcpdump ethtool
RUN apt-get install -y fzf zsh vim p7zip btop jq golang socat python-is-python3

# TODO no Intellij X tools
# TODO no distrobox
# TODO no kubectl (except k3s version)

COPY --chown=0:0 system_files/common /
COPY --chown=0:0 system_files/ubuntu /
RUN chmod u+rwx /usr/sbin/*
RUN systemctl enable mount-home.service

# docker support
RUN apt-get update
RUN apt-get install ca-certificates curl gnupg
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# k3s installed, but disabled by default. You can start it by systemctl start k3s. It uses docker mode 
RUN curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_EXEC="server --docker --disable traefik --write-kubeconfig-mode 644" sh -s - 

# some container utils
RUN curl -L https://github.com/google/go-containerregistry/releases/download/v0.16.1/go-containerregistry_Linux_x86_64.tar.gz | tar xzf - -C /usr/local/bin/ crane gcrane
RUN curl -L https://github.com/casey/just/releases/download/1.14.0/just-1.14.0-x86_64-unknown-linux-musl.tar.gz | tar xzf - -C /usr/local/bin/ just

RUN chmod a+x /usr/local/bin/*

# required, otherwise systemd support disables .exe support
RUN mkdir -p /usr/lib/binfmt.d; echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf

# final cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*