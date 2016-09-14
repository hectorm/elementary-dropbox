# Dropbox for Elementary OS
This script, designed for **Elementary OS**, installs the latest version of Dropbox and integrates it with WingPanel.

![System tray icon preview](http://i.imgur.com/hw3iHKK.png)

## Installation
#### Before you install
You need to install git and uninstall any previous version of Dropbox on your system (Software Center, apt-get...).

#### Install
	git clone https://github.com/zant95/elementary-dropbox /tmp/elementary-dropbox
	bash /tmp/elementary-dropbox/install.sh

#### Uninstall
	git clone https://github.com/zant95/elementary-dropbox /tmp/elementary-dropbox
	bash /tmp/elementary-dropbox/uninstall.sh

#### Command line options
	-y    Automatic "yes" to prompts
	-n    Automatic "no" to prompts

## Dropbox updates
This script itself doesn't handle updates. Dropbox will auto-update when a new version is available.

## Credits
* Panel icons: [paper-icon-theme](https://github.com/snwh/paper-icon-theme) ([license](https://raw.githubusercontent.com/snwh/paper-icon-theme/bbb30a7033904b64a0d410dd4081243a5262e461/LICENSE_CCBYSA)).
* Launcher icon: [nautilus-dropbox](https://github.com/dropbox/nautilus-dropbox) ([license](https://raw.githubusercontent.com/dropbox/nautilus-dropbox/48c2d695ab52f36ab1895ce42beacf458aa2700b/COPYING)).
