#!/bin/bash

# Define a flag file path in the user's home directory
FLAG_FILE="$HOME/.first_login_done"

# Check if the flag file exists
if [ ! -f "$FLAG_FILE" ]; then
    # If the flag file does not exist, execute your commands
    echo "This is the first login for this user. Running setup tasks..."
    # Add your commands here, for example:
    # kwriteconfig5 --file kdeglobals --group General --key AllowKDEThemeToChangeColors true
    # cp /path/to/default/config /home/user/.config/app_config.conf

    # Configure default KVM Virt-Manager settings
    # sudo -u rstrom DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u rstrom)/bus" gsettings set org.virt-manager.virt-manager system-tray true
    gsettings set org.virt-manager.virt-manager system-tray true
    gsettings set org.virt-manager.virt-manager xmleditor-enabled true
    gsettings set org.virt-manager.virt-manager.console resize-guest 1
    gsettings set org.virt-manager.virt-manager.console scaling 2
    gsettings set org.virt-manager.virt-manager.stats enable-cpu-poll true 
    gsettings set org.virt-manager.virt-manager.stats enable-disk-poll true
    gsettings set org.virt-manager.virt-manager.stats enable-memory-poll true
    gsettings set org.virt-manager.virt-manager.stats enable-net-poll true
    gsettings set org.virt-manager.virt-manager.vmlist-fields disk-usage true
    gsettings set org.virt-manager.virt-manager.vmlist-fields host-cpu-usage true
    gsettings set org.virt-manager.virt-manager.vmlist-fields memory-usage true
    gsettings set org.virt-manager.virt-manager.vmlist-fields network-traffic true
    gsettings set org.virt-manager.virt-manager manager-window-width 1100
    gsettings set org.virt-manager.virt-manager manager-window-height 700

    # Download and install Nerd Fonts 
    
    mkdir -p ~/.local/share/fonts
    
    # Terminess Nerd Font
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Terminus.zip
    # Nerd Font Symbols
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip
    # Pro Font
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/ProFont.zip
    # M+ Font
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/MPlus.zip
    # Open Dyslexic Font
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/OpenDyslexic.zip
    # Monoid Font
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Monoid.zip
    # Meslo Font
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip
    # JetBrains Mono Font
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    
    pushd ~/.local/share/fonts
    unzip -o Terminus.zip
    rm Terminus.zip
    unzip -o NerdFontsSymbolsOnly.zip
    rm NerdFontsSymbolsOnly.zip
    unzip -o ProFont.zip
    rm ProFont.zip
    unzip -o MPlus.zip
    rm MPlus.zip
    unzip -o OpenDyslexic.zip
    rm OpenDyslexic.zip
    unzip -o Monoid.zip
    rm Monoid.zip
    unzip -o Meslo.zip
    rm Meslo.zip
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip 
    fc-cache -fv
    popd

# Copy over import_copyq.sh - script for importing copyq exported data
# This script will not run unless there is a GUI desktop present
# The script will need to be run after logging into the GUI
wget -O $HOME/import_copyq.sh http://192.168.0.82/import_copyq.sh
chown rstrom:rstrom $HOME/import_copyq.sh
chmod a+x $HOME/import_copyq.sh


    # Create the flag file to prevent future executions
    touch "$FLAG_FILE"
else
    echo "Script already ran for this user. Skipping."
fi

