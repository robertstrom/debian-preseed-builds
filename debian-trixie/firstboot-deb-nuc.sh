#!/bin/bash
echo "This runs only on the first boot!" > /root/firstboot.log

# Do your commands here...

# import the older docker Ubuntu images
export HOME=/home/rstrom >> /root/firstboot.log 2>&1
export USER=rstrom >> /root/firstboot.log 2>&1

sleep 30 >> /root/firstboot.log 2>&1

# ethtool -s enp3s0 speed 1000 duplex full autoneg off

# sleep 5

# ip link set enp3s0 down

# sleep 5

# ip link set enp3s0 up

# sleep 5

# Create the br0 bridge interface 
ip link add br0 type bridge >> /root/firstboot.log 2>&1
# Set the br0 interface to have the same MAC address every time so that it doesn't
# get a different IP address every time - at least for when testing
# sleep 2
# ip link set dev br0 down
# sleep 2
# ip link set dev br0 address 12:5D:5F:4D:8C:52 >> /root/firstboot.log 2>&1
# sleep 2
# ip link set dev br0 up

sleep 10 >> /root/firstboot.log 2>&1

# Copy over the KVM network bridge definition XML file

wget -O /root/bridged-network.xml http://192.168.0.82/bridged-network.xml >> /root/firstboot.log 2>&1

sleep 5 >> /root/firstboot.log 2>&1

# Define the KVM bridged network
virsh net-define /root/bridged-network.xml >> /root/firstboot.log 2>&1

sleep 5 >> /root/firstboot.log 2>&1

# Set the KVM bridged network to auto-start
virsh net-autostart bridged-network >> /root/firstboot.log 2>&1 

sleep 5 >> /root/firstboot.log 2>&1

pushd $HOME/Documents/KVMBackup >> /root/firstboot.log 2>&1
# Copy CommandoVM VM
## wget -O $HOME/Documents/KVMBackup/CommandoVM.qcow2  http://192.168.0.82/CommandoVM.qcow2
## wget -O $HOME/Documents/KVMBackup/CommandoVM.xml  http://192.168.0.82/CommandoVM.xml

# ethtool -s enp3s0 speed 1000 duplex full autoneg off

# sleep 10

## Using rsync here because it supports copying sparse files

rsync -aSv --partial --progress -e "ssh -o StrictHostKeyChecking=no" installer@192.168.0.82:debian-preseed/CommandoVM.xml ./ >> /root/firstboot.log 2>&1

## scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null installer@192.168.0.82:debian-preseed/CommandoVM.xml ./

## Using rsync here because it supports copying sparse files

rsync -aSv --partial --progress -e "ssh -o StrictHostKeyChecking=no" installer@192.168.0.82:debian-preseed/CommandoVM.qcow2 ./ >> /root/firstboot.log 2>&1

## scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null installer@192.168.0.82:debian-preseed/CommandoVM.qcow2 ./ 


# Copy Kali VM
## wget -O $HOME/Documents/KVMBackup/kali-debian-kde.qcow2  http://192.168.0.82/kali-debian-kde.qcow2
## wget -O $HOME/Documents/KVMBackup/Kali-KDE-NUC.xml  http://192.168.0.82/Kali-KDE-NUC.xml

## Using rsync here because it supports copying sparse files

rsync -aSv --partial --progress -e "ssh -o StrictHostKeyChecking=no" installer@192.168.0.82:debian-preseed/Kali-KDE-NUC.xml ./ >> /root/firstboot.log 2>&1

## scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o installer@192.168.0.82:debian-preseed/Kali-KDE-NUC.xml ./

## Using rsync here because it supports copying sparse files

rsync -aSv --partial --progress -e "ssh -o StrictHostKeyChecking=no" installer@192.168.0.82:debian-preseed/kali-debian-kde.qcow2 ./ >> /root/firstboot.log 2>&1

## scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null installer@192.168.0.82:debian-preseed/kali-debian-kde.qcow2 ./

# Set permissions on the /var/lib/libvirt/images directory so that it can be accessed without using sudo
setfacl -R -b /var/lib/libvirt/images >> /root/firstboot.log 2>&1
setfacl -R -m u:$USER:rwX /var/lib/libvirt/images >> /root/firstboot.log 2>&1
setfacl -m d:u:$USER:rwx /var/lib/libvirt/images >> /root/firstboot.log 2>&1

sudo -u rstrom mv CommandoVM.qcow2 /var/lib/libvirt/images/ >> /root/firstboot.log 2>&1
sudo -u rstrom mv kali-debian-kde.qcow2 /var/lib/libvirt/images/ >> /root/firstboot.log 2>&1
chown -R rstrom:rstrom /var/lib/libvirt/images >> /root/firstboot.log 2>&1
# chown rstrom:rstrom /var/lib/libvirt/images/kali-debian-kde.qcow2 >> /root/firstboot.log 2>&1
chown rstrom:rstrom ./*.xml >> /root/firstboot.log 2>&1


# mv ./home/rstrom/Kali-KDE-NUC.xml ./
# sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/CommandoVM.qcow2
# sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/kali-debian-kde.qcow2
# sudo -u rstrom virsh define CommandoVM.xml
# sudo -u rstrom virsh define Kali-KDE-NUC.xml
sudo -u rstrom virsh --connect qemu:///system define ./CommandoVM.xml >> /root/firstboot.log 2>&1
sudo -u rstrom virsh --connect qemu:///system define ./Kali-KDE-NUC.xml >> /root/firstboot.log 2>&1
virsh net-autostart default >> /root/firstboot.log 2>&1

sleep 5

# Set virtual machines to autostart on host boot
virsh autostart CommandoVM >> /root/firstboot.log 2>&1
virsh autostart Kali-KDE-NUC >> /root/firstboot.log 2>&1

popd


sleep 5 >> /root/firstboot.log 2>&1

# Modify the /etc/network/interfaces file to set the br0 interface to use the physical ethernet adapter as the master
wget -O /etc/network/interfaces http://192.168.0.82/modified-ethernet-interfaces.txt >> /root/firstboot.log 2>&1
# The line below finds the built-in PCI based ethernet adapter and sets it's name to a variable
ethadp=$(ip a | awk '/^[0-9]+:/ {print $2}' | grep enp | awk -F":" '{ print $1 }')
# The line below modifies the /etc/network/interfaces file to associate the ehternet adapter name to the br0 interface
# This takes into account the fact that not all ethernet adpaters have the same name but that all built-in adapters start with enp
# and all external ethernet adpaters begin with enx
# This may need to be modified if there are mulktiple built-in ethernet adapters
sed -i "s/bridge_ports enp.*/bridge_ports $ethadp/" /etc/network/interfaces

sleep 5 >> /root/firstboot.log 2>&1

# Copy over preconfigured Konsole profile
# wget -O $HOME/.local/share/konsole/Robert.profile  http://192.168.0.82/Robert.profile
# chown rstrom:rstrom $HOME/.local/share/konsole/Robert.profile
# wget -O $HOME/.config/konsolerc http://192.168.0.82/konsolerc
# chown rstrom:rstrom $HOME/.config/konsolerc

# Copy over ssh_tunnel.sh script
# wget -O $HOME/ssh_tunnel.sh http://192.168.0.82/debian_base_os_ssh_tunnel.sh
# chmod a+x $HOME/ssh_tunnel.sh
# chown rstrom:rstrom $HOME/ssh_tunnel.sh

# Add the root cron job
# reference
# https://www.reddit.com/r/linuxadmin/comments/frw2h8/create_root_crontab_file_and_add_job_from_a_script/
# crontab -l 2>/dev/null >/tmp/crontab
# echo '*/5 * * * * /home/rstrom/ssh_tunnel.sh' >>/tmp/crontab
# crontab /tmp/crontab
# rm /tmp/crontab
# crontab -l

# Set KDE logon screen to not display the last user that logged on
mkdir -p /etc/sddm.conf.d
wget -O /etc/sddm.conf.d/00-general.conf http://192.168.0.82/00-general.conf
# The sed command below did not work. The file must not be there yet
# sed -i 's/User=.*$/User=/' /var/lib/sddm/state.conf
# Changing tactic to copy over a preconfigured /var/lib/sddm/state.conf file
wget -O /var/lib/sddm/state.conf http://192.168.0.82/state.conf
chattr +i /var/lib/sddm/state.conf

# Copy over preconfigured KDE settings
wget -O $HOME/KDE_settings_backup.tar http://192.168.0.82/KDE_settings_backup.tar

# Copy over KBackup profile
wget -O $HOME/kde-settings.kbp http://192.168.0.82/kde-settings.kbp
chown rstrom:rstrom $HOME/kde-settings.kbp

# Copy over broot function so that it is already configured and set
sudo -u rstrom mkdir -p $HOME/.local/share/broot/launcher/bash/ >> /root/firstboot.log 2>&1
sudo -u rstrom mkdir -p $HOME/.config/broot/launcher/bash/ >> /root/firstboot.log 2>&1
wget -O $HOME/.local/share/broot/launcher/bash/1 http://192.168.0.82/1 >> /root/firstboot.log 2>&1
chown rstrom:rstrom $HOME/.local/share/broot/launcher/bash/1 >> /root/firstboot.log 2>&1

sudo -u rstrom ln -s $HOME/.local/share/broot/launcher/bash/1 $HOME/.config/broot/launcher/bash/br >> /root/firstboot.log 2>&1

sudo -u rstrom ln -s $(which fdfind) $HOME/.local/bin/fd >> /root/firstboot.log 2>&1

# Decompress KDE configuration settings
# sudo -u rstrom 7z x $HOME/kde-settings.7z -o/home/rstrom/.config >> /root/firstboot.log 2>&1
tar -xvf $HOME/KDE_settings_backup.tar -C / >> /root/firstboot.log 2>&1

# Copy over preconfigured Krusader profile
# wget -O $HOME/.config/krusaderrc http://192.168.0.82/krusaderrc
# chown rstrom:rstrom $HOME/.config/krusaderrc

# Copy over preconfigured Dolphin profile
# wget -O $HOME/.config/dolphinrc http://192.168.0.82/dolphinrc
# chown rstrom:rstrom $HOME/.config/dolphinrc

# Copy over autossh service definition file
wget -O /etc/systemd/system/autossh-tunnel.service http://192.168.0.82/autossh-tunnel.service
chmod 0644 /etc/systemd/system/autossh-tunnel.service
systemctl enable autossh-tunnel.service


# Copy over polkit rule to allow managing neetwork connection when using XRDP
wget -O /etc/polkit-1/rules.d/50-allow-network-manager.rules http://192.168.0.82/50-allow-network-manager.rules >> /root/firstboot.log 2>&1

# Copy over script to run at users first logon
wget -O $HOME/.local/bin/first_login_script.sh http://192.168.0.82/first_login_script.sh >> /root/firstboot.log 2>&1
chmod a+x $HOME/.local/bin/first_login_script.sh >> /root/firstboot.log 2>&1
chown rstrom:rstrom $HOME/.local/bin/first_login_script.sh >> /root/firstboot.log 2>&1

# Copy over preconfigured .zshrc profile file
sudo -u rstrom mv $HOME/.zshrc $HOME/.zshrc.save >> /root/firstboot.log 2>&1
wget -O $HOME/.zshrc http://192.168.0.82/.zshrc >> /root/firstboot.log 2>&1
chown rstrom:rstrom $HOME/.zshrc >> /root/firstboot.log 2>&1

# Copy over copyq backup so that it can be resoted onto the system
wget -O $HOME/2025-08-19-16-01-24.cpq http://192.168.0.82/2025-08-19-16-01-24.cpq >> /root/firstboot.log 2>&1
# sudo -u rstrom /usr/bin/copyq importData $HOME/2025-08-19-16-01-24.cpq >> /root/firstboot.log 2>&1
chown rstrom:rstrom $HOME/2025-08-19-16-01-24.cpq >> /root/firstboot.log 2>&1

chown rstrom:rstrom $HOME/KDE_settings*.tar

# Install tmux plugin manager
sudo -u rstrom git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm >> /root/firstboot.log 2>&1

# Copy over preconfigured .tmux.conf file
wget -O $HOME/.tmux.conf http://192.168.0.82/.tmux.conf >> /root/firstboot.log 2>&1
chown rstrom:rstrom $HOME/.tmux.conf >> /root/firstboot.log 2>&1



# Disable this service so it doesn't run again
systemctl disable firstboot.service >> /root/firstboot.log 2>&1

sleep 5 >> /root/firstboot.log 2>&1

reboot >> /root/firstboot.log 2>&1
