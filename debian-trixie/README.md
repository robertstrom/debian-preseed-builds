This README will strive to explain the files that are in this debian-trixie section.

I will list each of the file nmames in the order that they are used and give at least a brief description of what the file is for / doing

# General setup

There is a **netboot.xyz** server that uses the `netboot.xyz_debian.ipxe` file to perform the PXE boot and point the system to the preseed file named **debian-kde-preseed.cfg**. The **debian-kde-preseed.cfg** and all other files are hosted in a directory on the **netboot.xyz** server using a simple python3 http server started using the command `sudo python3 -m http.server 80`

- netboot.xyz_debian.ipxe - the Debian ipxe file from the **netboot.xyz** system. This is a slightly modified default ipxe file. The line that is modified is the kernel line. The modification points to the preseed file and tells the preseed build to stop and wait for input of the systems hostname and domain.
- debian-kde-preseed.cfg - The Debian preseed file
- 

 
 - .tmux.conf - this is a copy of my tmux configuration file
00-general.conf
1
50-allow-network-manager.rules
2025-08-19-16-01-24.cpq
autossh-tunnel.service
bridged-network.xml
CommandoVM.xml

debian-preseed-postinstall.sh
debian_base_os_ssh_tunnel.sh
first_login_script.sh
first_login_script_example.sh
firstboot-deb-nuc.sh
firstboot.service
firstboot.sh
firstbootdeb13nuc.service
flameshot.ini
import_copyq.sh
kali-kde-chatgpt-preseed.cfg
Kali-KDE-NUC.xml
kali-kde-preseed.cfg
kali-preseed-postinstall.sh
kali-xfce-chatgpt-preseed.cfg
kde-files-to-save.txt
kde-settings.kbp
KDE_settings_backup.tar
modified-ethernet-interfaces.txt
old
Robert.profile
state.conf
