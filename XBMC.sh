#!/bin/bash
#
# @author   Bram van Oploo / Edited by uNiversal
# @date     2013-02-22
# @version  2.6.3
#

# Variables
SCRIPT_VERSION="2.6.3"
SCRIPT_TITLE="XBMC installation script v$SCRIPT_VERSION for Ubuntu 12.10 by Bram van Oploo :: bram@sudo-systems.com :: www.sudo-systems.com"

XBMC_USER="xbmc"
HOME_DIRECTORY="/home/$XBMC_USER/"
LOG_FILE=$HOME_DIRECTORY"xbmc_installation.log"
DIALOG_WIDTH=70


# System functions
function createFile()
{
    FILE="$1"
    IS_ROOT="$2"
    REMOVE_IF_EXISTS="$3"
    
    if [ -e "$FILE" ] && [ "$REMOVE_IF_EXISTS" == "1" ]; then
        sudo rm "$FILE" > /dev/null
    fi
    if [ "$IS_ROOT" == "0" ]; then
		touch "$FILE" > /dev/null
    else
        sudo touch "$FILE" > /dev/null
    fi
}

# Installation functions
function installDependencies()
{
    echo "-- Installing installation dependencies..."
    echo ""

	# python-software-properties for add-apt-repository (Ubuntu 12.04)
	# software-properties-common for add-apt-repository (Ubuntu 12.10 and above)
	sudo apt-get -y install dialog python-software-properties software-properties-common > /dev/null 2>&1
}

# Program
clear
createFile "$LOG_FILE" 0 1
echo ""
installDependencies
echo "Loading installer..."

dialog	--title "XBMC installation script" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\n$@" 12 $DIALOG_WIDTH