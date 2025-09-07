#!/bin/bash

# Import copyq data
    copyq --start-server
    sleep 1
    /usr/bin/copyq importData $HOME/2025-08-19-16-01-24.cpq
    sleep 1
    /usr/bin/copyq removetab "&clipboard"
    sleep 1
    /usr/bin/copyq renametab "&clipboard (1)" "&clipboard"

# Make sure that CopyQ is set to autostart
    copyq config autostart true
