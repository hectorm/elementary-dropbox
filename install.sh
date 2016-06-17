#!/usr/bin/env bash

# Author:     Héctor Molinero Fernández <hector@molinero.xyz>
# Repository: https://github.com/zant95/elementary-dropbox
# License:    MIT, https://opensource.org/licenses/MIT

# Exit on errors
set -euo pipefail

# Globals
scriptDir=$(dirname "$(readlink -f "$0")")

# Methods
function downloadDropbox {
	infoMsg 'Downloading Dropbox...'

	if [ $(uname -m) == 'x86_64' ]; then
		arch=x86_64
	else
		arch=x86
	fi

	mkdir "$HOME"/.dropbox-dist
	wget "https://www.dropbox.com/download?plat=lnx.$arch" -O - | \
		tar -xz --strip-components=1 -C "$HOME"/.dropbox-dist
}

function downloadDropboxCLI {
	infoMsg 'Downloading Dropbox CLI...'

	mkdir "$HOME"/.dropbox-bin
	wget 'https://www.dropbox.com/download?dl=packages/dropbox.py' -qO "$HOME"/.dropbox-bin/dropbox
}

function configureDropbox {
	infoMsg 'Configuring Dropbox...'

	cat > "$HOME"/.dropbox-bin/dropboxd <<-'EOF'
	#!/bin/sh
	env XDG_CURRENT_DESKTOP=Unity "$HOME"/.dropbox-dist/dropboxd "$@"
	EOF

	# Replace daemon location
	sed -i 's|dropbox-dist/dropboxd|dropbox-bin/dropboxd|g' "$HOME"/.dropbox-bin/dropbox

	# Prevents autostart modification (buggy)
	sed -i '/def reroll_autostart(/a\ \ \ \ return' "$HOME"/.dropbox-bin/dropbox

	infoMsg 'Adding to path (maybe a restart is required)...'
	sed -i '$s|$|\nPATH="$HOME/.dropbox-bin:$PATH"|' "$HOME"/.profile

	chmod +x "$HOME"/.dropbox-bin/*
}

function createLaunchers {
	infoMsg 'Creating menu launcher...'

	mkdir -p "$HOME"/.local/share/applications
	cat > "$HOME"/.local/share/applications/dropbox.desktop <<-EOF
	[Desktop Entry]
	Name=Dropbox
	GenericName=File Synchronizer
	Comment=Sync your files across computers and to the web
	Exec="$HOME"/.dropbox-bin/dropbox start -i
	Terminal=false
	Type=Application
	Icon=dropbox
	Categories=Network;FileTransfer;
	StartupNotify=false
	EOF

	infoMsg 'Creating autostart launcher...'

	mkdir -p "$HOME"/.config/autostart
	ln -fs "$HOME"/.local/share/applications/dropbox.desktop "$HOME"/.config/autostart/dropbox.desktop
}

function installIcons {
	infoMsg 'Installing icons...'

	mkdir -p "$HOME"/.local/share/icons/hicolor
	cp -rT "$scriptDir"/icons "$HOME"/.local/share/icons/hicolor
}

function runDropbox {
	"$HOME"/.dropbox-bin/dropbox start -i
}

# Process
source "$scriptDir"/common.sh

infoMsg 'Installing Dropbox...'

if [ -d "$HOME"/.dropbox ] || [ -d "$HOME"/.dropbox-bin ] || [ -d "$HOME"/.dropbox-dist ]; then
	warnMsg 'This script has found a previous Dropbox installation.'

	if promptMsg 'Do you want to uninstall Dropbox?'; then
		bash "$scriptDir"/uninstall.sh
	else
		errorMsg 'Installation aborted!'
		exit 1
	fi
fi

downloadDropbox
downloadDropboxCLI
configureDropbox
createLaunchers

if promptMsg 'Do you want to install the custom icons?'; then
	installIcons
fi

if isReleaseCodename 'loki'; then
	warnMsg 'Elementary OS Loki detected.'

	if promptMsg 'Do you want to enable experimental support?'; then
		bash "$scriptDir"/loki_support.sh
	fi
fi

if promptMsg 'Run Dropbox now?'; then
	runDropbox
fi

infoMsg 'Installation complete!'
