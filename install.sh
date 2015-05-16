#!/bin/bash
# Author:
#  Héctor Molinero Fernández <me@znt.se>.
#

#############################################
# Globals:									#
#############################################

SCRIPTDIR=$(dirname $0)

# Exit on errors:
set -e

#############################################
# Messages:									#
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
# Actions:									#
#############################################

function prerequisites {
	if [ -d $HOME/.dropbox-dist ]; then
		if promptMsg "This script has found a previous Dropbox installation. Do you want to continue?"; then
			if [ "$(pidof dropbox)" ]; then
				killall dropbox
			fi

			rm -rf $HOME/.dropbox-dist
		else
			exit 0
		fi
	fi

	if [ -d $HOME/.dropbox ]; then
		rm -rf $HOME/.dropbox.bak
		mv $HOME/.dropbox $HOME/.dropbox.bak
	fi
}

function downloadDropbox {
	infoMsg "Downloading package..."

	if [ $(uname -m) == 'x86_64' ]; then
		ARCH=x86_64
	else
		ARCH=x86
	fi

	wget -O - "https://www.dropbox.com/download?plat=lnx.$ARCH" --no-check-certificate | tar xzf - -C $HOME
}

function installIcons {
	if promptMsg "Do you want to install the custom icons?"; then
		mkdir -p $HOME/.local/share/icons/hicolor
		cp -rT $SCRIPTDIR/icons $HOME/.local/share/icons/hicolor
	fi
}

function createLaunchers {
	cat > $SCRIPTDIR/dropbox.desktop <<-EOF

	[Desktop Entry]
	Name=Dropbox
	GenericName=File Synchronizer
	Comment=Sync your files across computers and to the web
	Terminal=false
	Type=Application
	Icon=dropbox
	Categories=Network;FileTransfer;
	StartupNotify=false
	X-GNOME-Autostart-enabled=true
	Exec=env XDG_CURRENT_DESKTOP=Unity $HOME/.dropbox-dist/dropboxd

	EOF

	infoMsg "Creating menu launcher..."
	mkdir -p $HOME/.local/share/applications
	cp $SCRIPTDIR/dropbox.desktop $HOME/.local/share/applications/

	infoMsg "Creating autostart launcher..."
	mkdir -p $HOME/.config/autostart
	cp $SCRIPTDIR/dropbox.desktop $HOME/.config/autostart/
}

function runDropbox {
	if promptMsg "Run Dropbox now?"; then
		XDG_CURRENT_DESKTOP=Unity $HOME/.dropbox-dist/dropboxd &
	fi
}

#############################################
# Process:									#
#############################################

prerequisites
downloadDropbox
installIcons
createLaunchers
runDropbox

infoMsg "Operation complete!"
