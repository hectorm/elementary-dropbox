#!/bin/bash

# Messages:
##############################

printInfo () {
	echo -e "\e[0;33m + \e[1;32m$1 \e[0m"
}

printWarn () {
	echo -e "\e[0;33m + \e[1;33m$1 \e[0m"
}

printError () {
	echo -e "\e[0;33m + \e[1;31mError: $1 \e[0m"
	exit 1
}

promptMsg () {
	echo -en "\e[0;33m + \e[1;32m$1 \e[0m"
	read -p "[y/N]: " USER_RESPONSE

	if [[ $USER_RESPONSE =~ ^[Yy]$ ]]; then
		return 0
	else
		return 1
	fi
}
