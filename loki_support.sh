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

infoMsg 'Configuring Elementary OS Loki (maybe a restart is required)...'

mkdir -p "$HOME"/.config/autostart

if ! isPkgInstalled indicator-application; then
	infoMsg 'Installing indicator-application package...'
	sudo apt install indicator-application
fi

if ! isPkgInstalled wingpanel-indicator-ayatana; then
	infoMsg 'Installing wingpanel-indicator-ayatana package...'
	sudo apt install wingpanel-indicator-ayatana
fi

if [ -r '/etc/xdg/autostart/indicator-application.desktop' ]; then
	sed 's|^\(OnlyShowIn=\).*|\1Unity;GNOME;Pantheon;|g' \
		/etc/xdg/autostart/indicator-application.desktop \
		> "$HOME"/.config/autostart/indicator-application.desktop
fi

if [ -r '/etc/xdg/autostart/nm-applet.desktop' ]; then
	sed 's|^\(NotShowIn=\).*|\1KDE;GNOME;Pantheon;|g' \
		/etc/xdg/autostart/nm-applet.desktop \
		> "$HOME"/.config/autostart/nm-applet.desktop
fi

infoMsg 'Configuration complete.'
