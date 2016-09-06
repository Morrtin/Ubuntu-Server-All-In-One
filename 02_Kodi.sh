#!/bin/bash
#
# @author   Morrtin
# @Original script by Bram van Oploo
# @date     2013-05-27
# @version  1.0.0
#

## ----- Define variables ---------

KODI_USER="kodi"
SCRIPT_VERSION="1.0.0"
THIS_FILE=$0
HOME_DIRECTORY="/home/$KODI_USER/"
TEMP_DIRECTORY=$HOME_DIRECTORY"temp/"
LOG_FILE=$HOME_DIRECTORY"kodi_installation.log"
DIALOG_WIDTH=70
SCRIPT_TITLE="Kodi installation script v$SCRIPT_VERSION for Ubuntu 16.04"

## ------ START functions ---------

function showInfo()
{
    CUR_DATE=$(date +%Y-%m-%d" "%H:%M)
    echo "$CUR_DATE - INFO :: $@" >> $LOG_FILE
    dialog --title "Installing & configuring..." --backtitle "$SCRIPT_TITLE" --infobox "\n$@" 5 $DIALOG_WIDTH
}

function showError()
{
    CUR_DATE=$(date +%Y-%m-%d" "%H:%M)
    echo "$CUR_DATE - ERROR :: $@" >> $LOG_FILE
    dialog --title "Error" --backtitle "$SCRIPT_TITLE" --msgbox "$@" 8 $DIALOG_WIDTH
}

function createFile()
{
    FILE="$1"
    IS_ROOT="$2"
    REMOVE_IF_EXISTS="$3"
    
    if [ -e "$FILE" ] && [ "$REMOVE_IF_EXISTS" == "1" ]; then
        sudo rm "$FILE" > /dev/null
    else
        if [ "$IS_ROOT" == "0" ]; then
            touch "$FILE" > /dev/null
        else
            sudo touch "$FILE" > /dev/null
        fi
    fi
}

------------------------------

function installDependencies()
{
    echo "-- Installing installation dependencies..."
    echo ""

	# python-software-properties for add-apt-repository (Ubuntu 12.04)
	# software-properties-common for add-apt-repository (Ubuntu 12.10 and above)
	# dialog	(misc): Displays user-friendly dialog boxes from shell scripts
	sudo apt-get -y install dialog software-properties-common > /dev/null 2>&1
}




function cleanUp()
{
    showInfo "Cleaning up..."
	sudo apt-get -y autoremove > /dev/null 2>&1
	sudo apt-get -y autoclean > /dev/null 2>&1
	sudo apt-get -y clean > /dev/null 2>&1
	
	if [ -e "$TEMP_DIRECTORY" ]; then
	    sudo rm -R "$TEMP_DIRECTORY" > /dev/null 2>&1
	fi
	
	if [ -e "$HOME_DIRECTORY$THIS_FILE" ]; then
	    rm "$HOME_DIRECTORY$THIS_FILE" > /dev/null 2>&1
	fi
}


function quit()
{
	clear
	exit
}

control_c()
{
    cleanUp
    echo "Installation aborted..."
    quit
}

## ------- END functions -------

clear

createFile "$LOG_FILE" 0 1

echo ""
installDependencies
echo "Loading installer..."
dialog	--title "Kodi installation script" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\nWelcome to the Kodi minimal installation script. Some parts may take a while to install depending on your internet connection speed.\n\nPlease be patient..." 12 $DIALOG_WIDTH
trap control_c SIGINT
