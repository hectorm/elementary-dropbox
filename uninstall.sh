#!/bin/bash
# Author:
#  Héctor Molinero Fernández <me@znt.se>.
#

# Exit on errors:
set -e

#############################################
# Messages:                                 #
#############################################

function infoMsg {
    echo -e "\e[1;33m + \e[1;32m$1 \e[0m"
}

function promptMsg {
    echo -en "\e[1;33m + \e[1;32m$1 \e[0m"
    read -p "[y/N]: " USER_RESPONSE

    if [[ $USER_RESPONSE =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

#############################################
# Actions:                                #
#############################################

function uninstallDropbox {
    if promptMsg "Do you want to uninstall Dropbox?"; then
        if [ "$(pidof dropbox)" ]; then
            killall dropbox
        fi

        rm -rf \
            $HOME/.dropbox-dist \
            $HOME/.local/share/applications/dropbox.desktop \
            $HOME/.config/autostart/dropbox.desktop

        if [ -d $HOME/.dropbox ]; then
            rm -rf $HOME/.dropbox.bak
            mv $HOME/.dropbox $HOME/.dropbox.bak
        fi
    fi
}

function uninstallIcons {
    if promptMsg "Do you want to uninstall the custom icons?"; then
        rm -rf \
            $HOME/.local/share/icons/hicolor/*x*/apps/dropbox.* \
            $HOME/.local/share/icons/hicolor/*x*/apps/dropboxstatus-{busy,busy2,idle,logo,x}.*
    fi
}

#############################################
# Process:                                  #
#############################################

uninstallDropbox
uninstallIcons

infoMsg "Operation complete!"
