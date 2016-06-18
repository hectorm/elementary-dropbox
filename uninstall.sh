#!/usr/bin/env bash

# Author:     Héctor Molinero Fernández <hector@molinero.xyz>
# Repository: https://github.com/zant95/elementary-dropbox
# License:    MIT, https://opensource.org/licenses/MIT

# Exit on errors
set -euo pipefail

# Globals
scriptDir=$(dirname "$(readlink -f "$0")")

# Process
source "$scriptDir"/common.sh

infoMsg 'Uninstalling Dropbox...'

if [ "$(pidof dropbox)" ]; then
	killall dropbox
fi

if [ -f "$HOME"/.profile ]; then
	sed -i '\|PATH="$HOME/.dropbox-bin:$PATH"|d' "$HOME"/.profile
fi

rm -rf \
	"$HOME"/.dropbox-bin \
	"$HOME"/.dropbox-dist \
	"$HOME"/.local/share/applications/dropbox.desktop \
	"$HOME"/.config/autostart/dropbox.desktop \
	"$HOME"/.local/share/icons/hicolor/*x*/apps/dropbox.* \
	"$HOME"/.local/share/icons/hicolor/*x*/apps/dropboxstatus-{busy,busy2,idle,logo,x}.*

if [ -d "$HOME"/.dropbox ]; then
	mv "$HOME"/.dropbox "$HOME"/.dropbox.$(date +%s).bak
fi

infoMsg 'Uninstallation complete!'
