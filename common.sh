#!/bin/sh

# Author:     Héctor Molinero Fernández <hector@molinero.xyz>
# Repository: https://github.com/zant95/elementary-dropbox
# License:    MIT, https://opensource.org/licenses/MIT

# Exit on errors
set -eu

assume='ask'

while getopts 'yn' opt; do
	case "$opt" in
		y) assume='yes' ;;
		n) assume='no' ;;
		*) exit 1 ;;
	esac
done

infoMsg() {
	printf -- '\033[1;33m + \033[1;32m%s \033[0m\n' "$@"
}

warnMsg() {
	printf -- '\033[1;33m + \033[1;33m%s \033[0m\n' "$@"
}

errorMsg() {
	printf -- '\033[1;33m + \033[1;31m%s \033[0m\n' "$@"
}

promptMsg() {
	printf -- '\033[1;33m + \033[1;33m%s \033[0m[y/N]: ' "$@"
	if [ "$assume" = 'yes' ]; then
		printf -- '%s\n' 'y'
		return 0
	elif [ "$assume" = 'no' ]; then
		printf -- '%s\n' 'n'
		return 1
	else
		read answer
		case "$answer" in
			[yY]|[yY][eE][sS]) return 0 ;;
			*) return 1 ;;
		esac
	fi
}
