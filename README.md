This repository contains Debian based OS preseed files and associated scripts used to build systems in an automated manner.

Examples imclude:

- Kali Linux preseed file
- Debian Linux preseed file - known to work on Debian 13 - Trixie, but most, if not all should work on other Debian version
- Two types of post installation scripts
  - One runs during the initial installation as a **late_command**
  - Another runs after the first boot and then disables itself after the first boot is completed
- Runs commands to do install programs, configure settings, and copy over some configuration files - including:
  - Installs various software for the user
  - Ceate a network bridge interface that is connected to the single built-in network interface so that all KVM VM's can get bridged IP addresses
  - Defines the bridge network for KVM
  - Auto starts the bridged network for KVM
  - Copies over some preconfigured KVM qcow2 and the XML files that define the virtual machines
  - Defines the virtual machines for KVM
  - Sets permissions on the qcow2 files and the /var/lib/libvirt/images directory so that the files can be accessed by non-root users
  - Sets the virtual machines to autostart when the system boots
  - Installs SSH ppublic keys
  - Adds user to groups
  - Creates various directories for the user account (within the user profile)
  - Disables Wayland in KDE DE
  - Sets zsh as the default shell
  - Installs oh-my-zsh
  - Copies over preconfigured .zshrc file
  - Copies over a script that will create an outbound SSH tunnel to a server in the cloud
  - Copies over a bbackup of a desired preconfigured KDE DE state (all settings for desktop, taskbar, power settings, etc.) and applies those settings
  - Configures **polkit** to not ask for authentication to manage network settings
  - Installs the tmux plugin manager
  - Copies over a preconfigured .tmux.conf file
