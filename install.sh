#!/bin/bash
# Author:
#  Héctor Molinero Fernández <me@znt.se>.
#

# Globals:
##############################

# Exit on errors:
set -e

# Get script directory:
SCRIPTDIR=$(dirname $0)

# Load common methods:
source $SCRIPTDIR/common.sh

# Actions:
##############################

function downloadDropbox {
	printInfo "Downloading Dropbox..."

	if [ $(uname -m) == 'x86_64' ]; then
		ARCH=x86_64
	else
		ARCH=x86
	fi

	wget -O - "https://www.dropbox.com/download?plat=lnx.$ARCH" --no-check-certificate | tar xzf - -C $HOME
}

function downloadDropboxCLI {
	printInfo "Downloading Dropbox CLI..."

	mkdir -p $HOME/.dropbox-bin
	wget -O $HOME/.dropbox-bin/dropbox "https://www.dropbox.com/download?dl=packages/dropbox.py" --no-check-certificate
}

function installDropbox {
	printInfo "Installing Dropbox..."

	cat > $HOME/.dropbox-bin/dropboxd <<-'EOF'
	#!/bin/sh
	env XDG_CURRENT_DESKTOP=Unity $HOME/.dropbox-dist/dropboxd "$@"
	EOF

	# Replace daemon location
	sed -i 's/dropbox-dist\/dropboxd/dropbox-bin\/dropboxd/g' $HOME/.dropbox-bin/dropbox

	# Prevents autostart modification (buggy)
	sed -i '/def reroll_autostart(/a\ \ \ \ return' $HOME/.dropbox-bin/dropbox

	printInfo "Adding to path (maybe a restart is required)..."

	chmod +x $HOME/.dropbox-bin/*
	echo 'PATH="$HOME/.dropbox-bin:$PATH"' >> $HOME/.profile
}

function installIcons {
	mkdir -p $HOME/.local/share/icons/hicolor
	cp -rT $SCRIPTDIR/icons $HOME/.local/share/icons/hicolor
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

	printInfo "Creating menu launcher..."
	mkdir -p $HOME/.local/share/applications
	cp $SCRIPTDIR/dropbox.desktop $HOME/.local/share/applications/

	printInfo "Creating autostart launcher..."
	mkdir -p $HOME/.config/autostart
	cp $SCRIPTDIR/dropbox.desktop $HOME/.config/autostart/
}

function runDropbox {
	$HOME/.dropbox-bin/dropbox start -i
}

# Process:
##############################

if promptMsg "Do you want to install Dropbox?"; then
	if [ -d $HOME/.dropbox ] || [ -d $HOME/.dropbox-bin ] || [ -d $HOME/.dropbox-dist ]; then
		printWarn "This script has found a previous Dropbox installation."

		source $SCRIPTDIR/uninstall.sh
	fi

	downloadDropbox
	downloadDropboxCLI
	installDropbox

	if promptMsg "Do you want to install the custom icons?"; then
		installIcons
	fi

	createLaunchers

	if promptMsg "Run Dropbox now?"; then
		runDropbox
	fi

	printInfo "Installation complete!"
else
	printError "Installation aborted!"
fi
