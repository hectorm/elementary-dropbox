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

function uninstallDropbox {
	if [ "$(pidof dropbox)" ]; then
		killall dropbox
	fi

	sed -i '/PATH="\$HOME\/\.dropbox-bin:\$PATH"/d' $HOME/.profile

	rm -rf \
		$HOME/.dropbox-bin \
		$HOME/.dropbox-dist \
		$HOME/.local/share/applications/dropbox.desktop \
		$HOME/.config/autostart/dropbox.desktop \
		$HOME/.local/share/icons/hicolor/*x*/apps/dropbox.* \
		$HOME/.local/share/icons/hicolor/*x*/apps/dropboxstatus-{busy,busy2,idle,logo,x}.*

	if [ -d $HOME/.dropbox ]; then
		mv $HOME/.dropbox $HOME/.dropbox.$(date +%s).bak
	fi
}

# Process:
##############################

if promptMsg "Do you want to uninstall Dropbox?"; then
	uninstallDropbox

	printInfo "Uninstallation complete!"
else
	printError "Uninstallation aborted!"
fi
