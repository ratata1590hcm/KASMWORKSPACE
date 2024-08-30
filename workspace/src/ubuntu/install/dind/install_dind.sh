#!/usr/bin/env bash
set -ex
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

# Enable Docker repo
# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository for Docker CE
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install deps
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    dbus-user-session \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    fuse-overlayfs \
    iptables \
    kmod \
    openssh-client \
    sudo \
    supervisor \
    uidmap \
    wget \
    bash-completion

# Install dind init and hacks
useradd -U dockremap
usermod -G dockremap dockremap
echo 'dockremap:165536:65536' >> /etc/subuid
echo 'dockremap:165536:65536' >> /etc/subgid
curl -o \
    /usr/local/bin/dind -L \
    https://raw.githubusercontent.com/moby/moby/master/hack/dind
chmod +x /usr/local/bin/dind
curl -o \
    /usr/local/bin/dockerd-entrypoint.sh -L \
    https://kasm-ci.s3.amazonaws.com/dockerd-entrypoint.sh
chmod +x /usr/local/bin/dockerd-entrypoint.sh
echo 'hosts: files dns' > /etc/nsswitch.conf
usermod -aG docker kasm-user

# increase map_count for sonar server
echo 'vm.max_map_count=262144' | tee -a /etc/sysctl.conf
sysctl -p

# bash auto complete install
echo "source /etc/profile.d/bash_completion.sh" >> /etc/bash.bashrc

# Install k3d tools
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -o \
    /usr/local/bin/kubectl -L \
    "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
chmod +x /usr/local/bin/kubectl

# Passwordless Sudo
echo 'kasm-user:kasm-user' | chpasswd
echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Cleanup
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi
