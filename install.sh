#!/bin/bash
# Author:
#  Héctor Molinero Fernández <me@znt.se>.
#

# Exit on errors:
set -e

# Globals:
##############################

SCRIPTDIR=$(dirname $0)

# Messages:
##############################

function infoMsg {
	echo -e "\e[1;33m + \e[0;32m$1 \e[0m"
}

function promptMsg {
	echo -en "\e[1;33m + \e[0;32m$1 \e[0m"
	read -p "[y/N]: " USER_RESPONSE

	if [[ $USER_RESPONSE =~ ^[Yy]$ ]]; then
		return 0
	else
		return 1
	fi
}

# Actions:
##############################

function prerequisites {
	if [ -d $HOME/.dropbox-dist ]; then
		if promptMsg "This script has found a previous Dropbox installation. Do you want to continue?"; then
			if [ "$(pidof dropbox)" ]; then
				killall -9 dropbox
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

	mkdir -p $HOME/.dropbox-bin
}

function downloadDropbox {
	infoMsg "Downloading Dropbox..."

	if [ $(uname -m) == 'x86_64' ]; then
		ARCH=x86_64
	else
		ARCH=x86
	fi

	wget -O - "https://www.dropbox.com/download?plat=lnx.$ARCH" --no-check-certificate | tar xzf - -C $HOME
}

function downloadDropboxCLI {
	infoMsg "Downloading Dropbox CLI..."

	wget -O $HOME/.dropbox-bin/dropbox "https://www.dropbox.com/download?dl=packages/dropbox.py" --no-check-certificate
}

function installDropbox {
	infoMsg "Installing Dropbox..."

	cat > $HOME/.dropbox-bin/dropboxd <<-'EOF'
	#!/bin/sh
	env XDG_CURRENT_DESKTOP=Unity $HOME/.dropbox-dist/dropboxd "$@"
	EOF

	# Replace daemon location
	sed -i 's/dropbox-dist\/dropboxd/dropbox-bin\/dropboxd/g' $HOME/.dropbox-bin/dropbox

	# Prevents autostart modification (buggy)
	sed -i '/def reroll_autostart(/a\ \ \ \ return' $HOME/.dropbox-bin/dropbox

	infoMsg "Adding to path (maybe a restart is required)..."

	chmod +x $HOME/.dropbox-bin/*
	echo 'PATH="$HOME/.dropbox-bin:$PATH"' >> $HOME/.profile
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
	Exec=$HOME/.dropbox-bin/dropbox start -i
	Terminal=false
	Type=Application
	Icon=dropbox
	Categories=Network;FileTransfer;
	StartupNotify=false
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

# Process:
##############################

prerequisites
downloadDropbox
downloadDropboxCLI
installDropbox
installIcons
createLaunchers
runDropbox

infoMsg "Operation complete!"
