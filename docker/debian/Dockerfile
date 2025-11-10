FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update
RUN apt-get -y install systemd sudo tcpdump ethtool fzf zsh vim p7zip btop jq golang socat python-is-python3

COPY --chown=0:0 system_files/common /
RUN chmod u+rwx /usr/sbin/*
RUN systemctl enable mount-home.service

RUN apt-get -y update \
 && apt-get -y install --no-install-recommends ca-certificates curl gnupg lsb-release \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
 && chmod a+r /etc/apt/keyrings/docker.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian trixie stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get -y update \
 && apt-get -y install --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
 && rm -rf /var/lib/apt/lists/*

# k3s installed, but disabled by default. You can start it by systemctl start k3s. It uses docker mode 
RUN curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_EXEC="server --docker --disable traefik --write-kubeconfig-mode 644" sh -s - 

# some container utils
RUN curl -L https://github.com/google/go-containerregistry/releases/download/v0.20.6/go-containerregistry_Linux_x86_64.tar.gz | tar xzf - -C /usr/local/bin/ crane gcrane
RUN curl -L https://github.com/casey/just/releases/download/1.43.0/just-1.43.0-x86_64-unknown-linux-musl.tar.gz | tar xzf - -C /usr/local/bin/ just

RUN chmod a+x /usr/local/bin/*

# required, otherwise systemd support disables .exe support
RUN mkdir -p /usr/lib/binfmt.d; echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf

# final cleanup
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*
