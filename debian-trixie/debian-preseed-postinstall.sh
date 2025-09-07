#!/bin/bash

# kali-preseed-postinstall.sh
# Script to finish building out a Kali preseed automate build

# set -eux
set -ux


export HOME=/home/rstrom
export USER=rstrom
cd $HOME

# Setup fuse group and add user to fuse group for sshfs use
groupadd fuse
usermod -aG fuse rstrom

# Add rstrom user to various groups
usermod -aG kvm rstrom
usermod -aG libvirt rstrom
usermod -aG sudo rstrom
usermod -aG libvirt-qemu rstrom
usermod -aG wireshark rstrom

# Add ninja-pi-1 user to various groups
# usermod -aG fuse ninja-pi-1
# usermod -aG kvm ninja-pi-1
# usermod -aG libvirt ninja-pi-1
# usermod -aG sudo ninja-pi-1
# usermod -aG libvirt-qemu ninja-pi-1
# usermod -aG wireshark ninja-pi-1

# Set ninja-pi-1 account to use the zsh shell
# usermod -s /usr/bin/zsh ninja-pi-1

# rstrom SSH key setup
mkdir -p $HOME/.ssh
echo '<your ssh public key rstrom@debian-dell-xps>' > $HOME/.ssh/authorized_keys
echo '<your ssh public key rstrom@ansible-pi5>' >> $HOME/.ssh/authorized_keys
echo '<your ssh public key rstrom@oryx-pro>' >> $HOME/.ssh/authorized_keys
echo '<your ssh public key rstrom@ubuntu-s-1vcp>' >> $HOME/.ssh/authorized_keys

wget -O $HOME/.ssh/rstrom.cloud.id_ed25519 http://192.168.0.82/rstrom.cloud.id_ed25519
wget -O $HOME/.ssh/rstrom.cloud.id_ed25519.pub http://192.168.0.82/rstrom.cloud.id_ed25519.pub
chown -R rstrom:rstrom $HOME/.ssh
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/rstrom.cloud.id_ed25519
chmod 644 $HOME/.ssh/rstrom.cloud.id_ed25519.pub

# Create $HOME/.local/bin/ directory
sudo -u rstrom mkdir -p $HOME/.local/bin/
# sudo -u ninja-pi-1 mkdir -p $NINJAHOME/.local/bin/

# Create $HOME/Downloads/ directory
sudo -u rstrom mkdir -p $HOME/Downloads

## Create a directory for copying down prebuilt Docker Images from NAS
sudo -u rstrom mkdir $HOME/Docker-Images

# Creating a link to the fdfind binary so that it can be launched using the command fd
sudo -u rstrom ln -s $(which fdfind) $HOME/.local/bin/fd

# Add .screenrc file to make scrolling work properly when / if using screen
sudo -u rstrom touch $HOME/.screenrc
sudo -u rstrom echo "# Enable mouse scrolling and scroll bar history scrolling" > $HOME/.screenrc
sudo -u rstrom echo "termcapinfo xterm* ti@:te@" >> $HOME/.screenrc

# Create a directory for mounting remote SMB shares
sudo -u rstrom mkdir $HOME/SMBmount

# Create a working directory for temp type actions
sudo -u rstrom mkdir $HOME/working

# Create a directory for the KVM Backup
sudo -u rstrom mkdir -p $HOME/Documents/KVMBackup

# Install fzf via github
sudo -u rstrom git clone --depth 1 https://github.com/junegunn/fzf.git
cd $HOME/fzf
sudo -u rstrom ./install --all
cd $HOME

# Setting up link to bat for the batcat install
sudo -u rstrom ln -s /usr/bin/batcat $HOME/.local/bin/bat

arch=$(uname -m)

## 2024-11-09 - Added the install of 1password
pushd $HOME/Downloads

case "$arch" in
  x86_64|amd64)
    echo "Architecture: x86-64 (64-bit)"
    wget https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
    sudo dpkg -i 1password-latest.deb
    ;;
  i?86)
    echo "Architecture: x86 (32-bit)"
    ;;
  arm*)
    echo "Architecture: ARM"
    ;;
  aarch64)
    ## https://support.1password.com/install-linux/#arm-or-other-distributions-targz
    echo "Architecture: AArch64 (64-bit ARM)"
    curl -sSO https://downloads.1password.com/linux/tar/stable/aarch64/1password-latest.tar.gz
    sudo tar -xf 1password-latest.tar.gz
    sudo mkdir -p /opt/1Password
    sudo mv 1password-*/* /opt/1Password
    sudo /opt/1Password/after-install.sh
    rm -rf 1password*
    ;;
  ppc64le)
    echo "Architecture: PowerPC 64-bit Little Endian"
    ;;
  *)
    echo "Architecture: Unknown ($arch)"
    ;;
esac
popd

# Download and install VS Code
# Used to be able to install VS Code via apt install code-oss but that package does not appear to be available in the repo anymore
pushd $HOME/Downloads
wget -O vscode-latest-x64.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
sudo dpkg -i ./vscode-latest-x64.deb
rm vscode-latest-x64.deb
popd

# Download and install Obsidian
pushd $HOME/Downloads
obdsidianamd64=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | jq -r ".assets[].browser_download_url" | grep amd64)
wget -O obsidian-latest-x64.deb $obdsidianamd64
sudo dpkg -i obsidian-latest-x64.deb
rm obsidian-latest-x64.deb
popd

# Install konsave
sudo -u rstrom $(which pipx) install konsave
## sudo -u rstrom $(which pipx) inject konsave "setuptools<80" --force
sudo -u rstrom $(which pipx) inject konsave setuptools==80 --force

# Copy over customized konsave conf.yaml file
# wget -O $HOME/.config/konsave/conf.yaml http://192.168.0.82/konsave-conf.yaml
# chown rstrom:rstrom $HOME/.config/konsave/conf.yaml

# Disable Wayland
sudo mv /usr/share/wayland-sessions/xfce-wayland.desktop /usr/share/wayland-sessions/xfce-wayland.desktop.disabled
sudo mv /usr/share/wayland-sessions/plasma.desktop /usr/share/wayland-sessions/plasma.desktop.disabled

# This is a fix for using XRDP in KDE
sudo sed -i '/X-GNOME-Autostart-Phase=WindowManager/d' /etc/xdg/autostart/spice-vdagent.desktop

Install Rust
sudo -u rstrom curl https://sh.rustup.rs -sSf | sudo -u rstrom sh -s -- -y

# Install Docker Official GPG Key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository to APT sources
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine, CLI, containerd, and Docker Compose plugin
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to the docker group
sudo usermod -aG docker rstrom

# Copy Flameshot configuration
wget -O $HOME/flameshot.ini http://192.168.0.82/flameshot.ini
sudo -u rstrom mkdir -p $HOME/.config/flameshot
cp $HOME/flameshot.ini $HOME/.config/flameshot/
chown rstrom:rstrom $HOME/.config/flameshot.ini

# Copy KDE configuration
wget -O $HOME/debian-kde-nuc.knsv http://192.168.0.82/debian-kde-nuc.knsv
chown rstrom:rstrom debian-kde-nuc.knsv

# Import the KDE configuration using konsave
## 2025-08-21 - RStrom - using KBackup saved configuration now
# sudo -u rstrom /home/rstrom/.local/bin/konsave -i $HOME/debian-kde-nuc.knsv
# sudo -u rstrom /home/rstrom/.local/bin/konsave -a debian-kde-nuc


echo 'export LIBVIRT_DEFAULT_URI=qemu:///system' >> $HOME/.profile
echo 'export LIBVIRT_DEFAULT_URI=qemu:///system' >> $HOME/.zshrc


## An alternate way of getting the current version information from GitHub
## curl -s https://api.github.com/repos/phiresky/ripgrep-all/releases/latest | grep browser_download

# sudo systemctl start docker || true

# Installing uv
# See - UV vs. PIP: Revolutionizing Python Package Management
# https://medium.com/@sumakbn/uv-vs-pip-revolutionizing-python-package-management-576915e90f7e
# curl -LsSf https://astral.sh/uv/install.sh | sh


# Install wwwtree
# sudo git clone https://github.com/t3l3machus/wwwtree /opt/wwwtree
# cd /opt/wwwtree
# sudo pip3 install -r requirements.txt
# sudo chmod +x wwwtree.py
# cd /usr/bin
# sudo ln -s /opt/wwwtree/wwwtree.py wwwtree

# Install Oh My Zsh non-interactively
# No need to install zsh in kali but saving this for regular Debian install
sudo -u rstrom sh -c 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

# Optionally, set a theme or plugins (change "robbyrussell" to "agnoster" or others)
sudo -u rstrom sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"agnoster\"/" $HOME/.zshrc
