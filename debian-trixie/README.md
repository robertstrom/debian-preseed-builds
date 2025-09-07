This README will strive to explain the files that are in this debian-trixie section.

I will list each of the file names in the order that they are used and give at least a brief description of what the file is for / doing

# General setup

There is a **netboot.xyz** server that uses the `netboot.xyz_debian.ipxe` file to perform the PXE boot and point the system to the preseed file named **debian-kde-preseed.cfg**. The **debian-kde-preseed.cfg** and all other files are hosted in a directory on the **netboot.xyz** server using a simple python3 http server started using the command `sudo python3 -m http.server 80`

# Files and descriptions of what each of them are / what they do

- **netboot.xyz_debian.ipxe **- the Debian ipxe file from the **netboot.xyz** system. This is a slightly modified default ipxe file. The line that is modified is the kernel line. The modification points to the preseed file and tells the preseed build to stop and wait for input of the systems hostname and domain.
- **debian-kde-preseed.cfg** - The Debian preseed file. This file will install the base Debian operating system and a number of additional software packages. The preseed file will create a user and assign the password for the **root** user and the user you create. The passwords are currently configured to use encrypted passwords. See this article for information on creating the encrypted password - https://linuxconfig.org/how-to-perform-unattedended-debian-installations-with-preseed - THe preseed file also enables the SSH service, changes the shell from bash to zsh for the root user and the user that is being created, copies over a script that runs post install and then runs that post install script, copies over a script to run on first boot, copies over the first boot service file, 
- **debian-preseed-postinstall.sh** - This script adds the user to some groups, adds some SSH public keys to the `authorized_keys` file for systems that will be accessing the installed operating system, copies over a preconfigured SSH private and public key that is used to access a remote cloud Linux system, creates some directories in the users home directory, creates a symbolic link for the `fdfind` program, installs **fzf** for the user, creates a link for the **batcat** program, downloads the 1password program and installs it, downloads VSCode and installs it, installs the **konsave** program (even though it is not currently being used since it does not seem to work with KDE 6, KBackup is used instead), installs the **rust** program, installs Docker, adds the user to the **docker** group, copies over a preconfigured `flameshot.ini` configuration file, sets some environmental variables in the `.profile` and the `.zshrc` files for KVM virtualization, installs **ohmyzsh** and sets the **ohmyzsh** theme
- After running the **debian-preseed-postinstall.sh** script the system will reboot and move on to the **firstboot-deb-nuc.sh** script
- **firstboot-deb-nuc.sh**
  - Creates a **br0** bridge interface that makes it possible for KVM virtual machines to use bridged networking when the system has only one NIC
  - The **bridged-network.xml** file is copied over
  - The **bridged-network.xml** is used to define the bridged network within KVM, the bridged network is set to autostart
  - Two preconfigured KVM virtual machines are copied over using **rsync** which is configured to copy **sparse** files, leaving them sparse, and copy over the large files so that the copy can be restarted if necessary. Some permissions on the **/var/lib/libvirt/images/** directory so that the virtual machines can be acccessed without having to sudo or use root. The two virtual machines are **defined** for KVM, the virtual machines are set to auto-start, the **modified-ethernet-interfaces.txt** file is copied over. This file is used to tell the **br0** interface what the master Ethernet interface is (the real NIC that is needs to bind to). An **awk** command is run to find out what the Ethernet interface name is and then **sed** is used to modify the **/etc/network/interfaces** file so that the **br0** bridge is associated with the correct interface name. The **00-general.conf** file is copied over. This file configures the KDE so that the users name is not displayed on the logon screen. The **state.conf** file is copied over. This file also helps to ensure that the last logged on user is not displyed on the logon screen. The file is then permissioned so that it cannot be written to. The **KDE_settings_backup.tar** file is copied over. This file is created using the **KBackup** program. This backup contains the preconfigured, desired, KDE settings. The **kde-settings.kbp** file is copied over. This file is a KBackup program profile that contains the files that are to be backed up for saving the KDE settings. Some directories are created for the **broot** program and a file named **1** is copied over. This preconfigures the **broot** **br** function. The **KDE_settings_backup.tar** is extracted placing all the preconfigured configuration files into the users profile. The **autossh-tunnel.service** file is copied over and the service is configured to be enabled. The **50-allow-network-manager.rule** file is copied over. This file ensures that **polkit** doesn't prompt for credentials when you log in via XRDP. The **first_login_script.sh** script is copied over. A preconfigured `.zshrc` file is copied over. A CopyQ backup is copied over. The tmux plug-in manager is installed. A preconfigured `.tmux.conf` file is copied over.
- 

 
 - .tmux.conf - this is a copy of my tmux configuration file
00-general.conf
1
50-allow-network-manager.rules
2025-08-19-16-01-24.cpq
autossh-tunnel.service
bridged-network.xml
CommandoVM.xml


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
