#!/bin/bash
# Ubuntu 19.04

# bash-check
if [ -z "$BASH_VERSION" ]
then
    exec bash "$0" "$@"
fi

# root-check
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

# install
set ex;
aptInstall=" \
    apache2-utils \
    apt-utils \
    aptitude \
    atop \
    axel \
    bash-completion \
    build-essential \
    bzip2 \
    chrome-gnome-shell \
    cifs-utils \
    cryptsetup \
    curl \
    dconf-editor \
    dialog \
    diffutils \
    dirmngr \
    docker.io \
    dnsutils \
    enigmail \
    exfat-fuse \
    exfat-utils \
    file \
    filezilla \
    flameshot \
    fuse \
    gcc \
    geoip-bin \
    geoip-database \
    git \
    gnome-tweak-tool \
    golang \
    gparted \
    hddtemp \
    hdparm \
    htop \
    iotop \
    libavcodec-extra \
    libnss3-tools \
    libreoffice \
    libreoffice-help-pt-br \
    libreoffice-l10n-pt-br \
    libreoffice-pdfimport \
    lm-sensors \
    make \
    mongo-tools \
    mysql-client \
    nano \
    nload \
    net-tools \
    netcat \
    network-manager-openvpn-gnome \
    nfs-kernel-server \
    nfs-common \
    nmap \
    ntfs-3g \
    jq \
    openssl \
    openvpn \
    pavucontrol \
    php-cli \
    procps \
    python-pip \
    pwgen \
    qbittorrent \
    rar \
    remmina \
    rsync \
    software-properties-common \
    sshfs \
    sshpass \
    tcpdump \
    telnet \
    terminator \
    tilix \
    thunderbird \
    thunderbird-locale-pt-br \
    tree \
    ubuntu-restricted-extras \
    unoconv \
    unrar \
    unzip \
    vim \
    vlc \
    vpnc \
    wget \
    whois \
    x264 \
    x265 \
";
pipInstall="
    setuptools \
    wheel \
    ansible \
    awscli \
    boto \
    boto3 \
    docker-compose \
";
apt update -q; \
DEBIAN_FRONTEND=noninteractive apt install -qy $aptInstall; \
pip install $pipInstall

# chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
apt install -y ./google-chrome-stable_current_amd64.deb; \
rm -f ./google-chrome-stable_current_amd64.deb

# code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg; \
install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/; \
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'; \
apt install -y apt-transport-https; \
apt update -q; \
apt install -y code

# docker-machine
DOCKER_MACHINE_VER=$(curl --silent "https://api.github.com/repos/docker/machine/releases/latest" |
grep '"tag_name":' |
sed -E 's/.*"([^"]+)".*/\1/')
base=https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VER}; \
curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine; \
install /tmp/docker-machine /usr/local/bin/docker-machine

# kops
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64; \
chmod +x ./kops-linux-amd64; \
mv ./kops-linux-amd64 /usr/bin/kops

# kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; \
chmod +x ./kubectl; \
mv ./kubectl /usr/bin/kubectl; \
echo "source <(kubectl completion bash)" >> ~/.bashrc

# helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh; \
chmod 700 get_helm.sh; \
./get_helm.sh

# mega
wget https://mega.nz/linux/MEGAsync/x$(lsb_release -si)_$(lsb_release -sr)/amd64/megasync-x$(lsb_release -si)_$(lsb_release -sr)_amd64.deb; \
apt install -y ./megasync-x$(lsb_release -si)_$(lsb_release -sr)_amd64.deb; \
rm -f megasync-x$(lsb_release -si)_$(lsb_release -sr)_amd64.deb

# packer
curl -o packer.zip $(curl https://releases.hashicorp.com/index.json | jq '{packer}' | egrep "linux.*amd64" | sort --version-sort -r | head -1 | awk -F[\"] '{print $4}'); \
unzip packer.zip; \
chmod +x ./packer; \
mv ./packer /usr/sbin/packer; \
rm -f packer.zip

# skype
wget https://repo.skype.com/latest/skypeforlinux-64.deb; \
apt install -y ./skypeforlinux-64.deb; \
rm -f ./skypeforlinux-64.deb

# slack
SLACK_VER=3.3.8
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-${SLACK_VER}-amd64.deb; \
apt install -y ./slack-desktop-${SLACK_VER}-amd64.deb

# spotify
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90; \
echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list; \
apt update -q; \
apt install -qy spotify-client

# terraform
function terraform-install() {
    [[ -f /sbin/terraform ]] && echo "`/sbin/terraform version` already installed at /sbin/terraform" && return 0
    OS=$(uname -s)
    LATEST_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].version' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'alpha|beta|rc' | tail -1)
    LATEST_URL="https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_${OS,,}_amd64.zip"
    curl ${LATEST_URL} > /tmp/terraform.zip
    mkdir -p /sbin
    (cd /sbin && unzip /tmp/terraform.zip)
    if [[ -z $(grep 'export PATH=/sbin:${PATH}' ~/.bashrc 2>/dev/null) ]]; then
        echo 'export PATH=/sbin:${PATH}' >> ~/.bashrc
    fi

    echo "Installed: `/sbin/terraform version`"
}

terraform-install

# terragrunt
curl -LO https://github.com/gruntwork-io/terragrunt/releases/download/$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep tag_name | cut -d '"' -f 4)/terragrunt_linux_amd64; \
chmod +x ./terragrunt_linux_amd64; \
mv ./terragrunt_linux_amd64 /usr/bin/terragrunt

# typora
wget -qO - https://typora.io/linux/public-key.asc | apt-key add -; \
add-apt-repository 'deb https://typora.io/linux ./'; \
apt update -q; \
apt install -qy typora

# update/upgrade
apt update -q; \
apt upgrade -qy;

# user/group
USERNAME=$(eval getent passwd {$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)..$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)} | cut -d: -f1)
usermod -aG docker ${USERNAME}

# systemctl
systemctl enable docker
