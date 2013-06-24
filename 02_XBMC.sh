#!/bin/bash
#
# @author   Morrtin
# @Original script by Bram van Oploo
# @date     2013-05-27
# @version  1.0.0
#

XBMC_USER="xbmc"
THIS_FILE=$0
SCRIPT_VERSION="1.0.0"
HOME_DIRECTORY="/home/$XBMC_USER/"
TEMP_DIRECTORY=$HOME_DIRECTORY"temp/"
ENVIRONMENT_FILE="/etc/environment"
CRONTAB_FILE="/etc/crontab"
DIST_UPGRADE_FILE="/etc/cron.d/dist_upgrade.sh"
DIST_UPGRADE_LOG_FILE="/var/log/updates.log"
XBMC_INIT_FILE="/etc/init.d/xbmc"
XBMC_ADDONS_DIR=$HOME_DIRECTORY".xbmc/addons/"
XBMC_USERDATA_DIR=$HOME_DIRECTORY".xbmc/userdata/"
XBMC_KEYMAPS_DIR=$XBMC_USERDATA_DIR"keymaps/"
XBMC_ADVANCEDSETTINGS_FILE=$XBMC_USERDATA_DIR"advancedsettings.xml"
XBMC_INIT_CONF_FILE="/etc/init/xbmc.conf"
XBMC_XSESSION_FILE="/home/xbmc/.xsession"
XWRAPPER_FILE="/etc/X11/Xwrapper.config"
XORG_FILE="/etc/X11/xorg.conf"
GRUB_CONFIG_FILE="/etc/default/grub"
GRUB_HEADER_FILE="/etc/grub.d/00_header"
SYSTEM_LIMITS_FILE="/etc/security/limits.conf"
INITRAMFS_SPLASH_FILE="/etc/initramfs-tools/conf.d/splash"
INITRAMFS_MODULES_FILE="/etc/initramfs-tools/modules"
MODULES_FILE="/etc/modules"
REMOTE_WAKEUP_RULES_FILE="/etc/udev/rules.d/90-enable-remote-wakeup.rules"
AUTO_MOUNT_RULES_FILE="/etc/udev/rules.d/11-media-by-label-auto-mount.rules"
SYSCTL_CONF_FILE="/etc/sysctl.conf"
POWERMANAGEMENT_DIR="/var/lib/polkit-1/localauthority/50-local.d/"
DOWNLOAD_URL="https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/download/"
# VAAPI PPA from WSNIPEX includes INTEL VAAPI (hardware / GPU) de-interlacing support
# http://forum.xbmc.org/showthread.php?tid=165707
XBMC_PPA="ppa:wsnipex/vaapi"
HTS_TVHEADEND_PPA="ppa:jabbors/hts-stable"
OSCAM_PPA="ppa:oscam/ppa"

LOG_FILE=$HOME_DIRECTORY"xbmc_installation.log"
DIALOG_WIDTH=70
SCRIPT_TITLE="XBMC installation script v$SCRIPT_VERSION for Ubuntu 13.04"

GFX_CARD=$(lspci |grep VGA |awk -F: {' print $3 '} |awk {'print $1'} |tr [a-z] [A-Z])

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

function createDirectory()
{
    DIRECTORY="$1"
    GOTO_DIRECTORY="$2"
    IS_ROOT="$3"
    
    if [ ! -d "$DIRECTORY" ];
    then
        if [ "$IS_ROOT" == "0" ]; then
            mkdir -p "$DIRECTORY" > /dev/null 2>&1
        else
            sudo mkdir -p "$DIRECTORY" > /dev/null 2>&1
        fi
    fi
    
    if [ "$GOTO_DIRECTORY" == "1" ];
    then
        cd $DIRECTORY
    fi
}

function handleFileBackup()
{
    FILE="$1"
    BACKUP="$1.bak"
    IS_ROOT="$2"
    DELETE_ORIGINAL="$3"

    if [ -e "$BACKUP" ];
	then
	    if [ "$IS_ROOT" == "1" ]; then
	        sudo rm "$FILE" > /dev/null 2>&1
		    sudo cp "$BACKUP" "$FILE" > /dev/null 2>&1
	    else
		    rm "$FILE" > /dev/null 2>&1
		    cp "$BACKUP" "$FILE" > /dev/null 2>&1
		fi
	else
	    if [ "$IS_ROOT" == "1" ]; then
		    sudo cp "$FILE" "$BACKUP" > /dev/null 2>&1
		else
		    cp "$FILE" "$BACKUP" > /dev/null 2>&1
		fi
	fi
	
	if [ "$DELETE_ORIGINAL" == "1" ]; then
	    sudo rm "$FILE" > /dev/null 2>&1
	fi
}

function appendToFile()
{
    FILE="$1"
    CONTENT="$2"
    IS_ROOT="$3"
    
    if [ "$IS_ROOT" == "0" ]; then
        echo "$CONTENT" | tee -a "$FILE" > /dev/null 2>&1
    else
        echo "$CONTENT" | sudo tee -a "$FILE" > /dev/null 2>&1
    fi
}

function addRepository()
{
    REPOSITORY=$@
    KEYSTORE_DIR=$HOME_DIRECTORY".gnupg/"
    createDirectory "$KEYSTORE_DIR" 0 0
    sudo add-apt-repository -y $REPOSITORY > /dev/null 2>&1

    if [ "$?" == "0" ]; then
        sudo apt-get update > /dev/null 2>&1
        showInfo "$REPOSITORY repository successfully added"
        echo 1
    else
        showError "Repository $REPOSITORY could not be added (error code $?)"
        echo 0
    fi
}

function isPackageInstalled()
{
    PACKAGE=$@
    sudo dpkg-query -l $PACKAGE > /dev/null 2>&1
    
    if [ "$?" == "0" ]; then
        echo 1
    else
        echo 0
    fi
}

function aptInstall()
{
    PACKAGE=$@
    IS_INSTALLED=$(isPackageInstalled $PACKAGE)

    if [ "$IS_INSTALLED" == "1" ]; then
        showInfo "Skipping installation of $PACKAGE. Already installed."
        echo 1
    else
        sudo apt-get -f install > /dev/null 2>&1
        sudo apt-get -y install $PACKAGE > /dev/null 2>&1
        
        if [ "$?" == "0" ]; then
            showInfo "$PACKAGE successfully installed"
            echo 1
        else
            showError "$PACKAGE could not be installed (error code: $?)"
            echo 0
        fi 
    fi
}

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

function move()
{
    SOURCE="$1"
    DESTINATION="$2"
    IS_ROOT="$3"
    
    if [ -e "$SOURCE" ];
	then
	    if [ "$IS_ROOT" == "0" ]; then
	        mv "$SOURCE" "$DESTINATION" > /dev/null 2>&1
	    else
	        sudo mv "$SOURCE" "$DESTINATION" > /dev/null 2>&1
	    fi
	    
	    if [ "$?" == "0" ]; then
	        echo 1
	    else
	        showError "$SOURCE could not be moved to $DESTINATION (error code: $?)"
	        echo 0
	    fi
	else
	    showError "$SOURCE could not be moved to $DESTINATION because the file does not exist"
	    echo 0
	fi
}

------------------------------

function installDependencies()
{
    echo "-- Installing installation dependencies..."
    echo ""

	# python-software-properties for add-apt-repository (Ubuntu 12.04)
	# software-properties-common for add-apt-repository (Ubuntu 12.10 and above)
	sudo apt-get -y install dialog software-properties-common > /dev/null 2>&1
}

function fixLocaleBug()
{
    createFile $ENVIRONMENT_FILE
    handleFileBackup $ENVIRONMENT_FILE 1
    appendToFile $ENVIRONMENT_FILE "LC_MESSAGES=\"C\""
    appendToFile $ENVIRONMENT_FILE "LC_ALL=\"en_US.UTF-8\""
	showInfo "Locale environment bug fixed"
}

function fixUsbAutomount()
{
# Program usbmount is not used because it is not maintent anymore and dev rule solution is the nativ one
# User xbmc has to be added to group users - see section addUserToRequiredGroups
# Also udisks has to be installed and user xbmc has to get permissions to handle udisks policies - see section installPowerManagement
    handleFileBackup "$MODULES_FILE" 1 0
    appendToFile $MODULES_FILE "usb-storage"
    createDirectory "$TEMP_DIRECTORY" 1 0
    download $DOWNLOAD_URL"11-media-by-label-auto-mount.rules"

    if [ -e $TEMP_DIRECTORY"11-media-by-label-auto-mount.rules" ]; then
	    IS_MOVED=$(move $TEMP_DIRECTORY"11-media-by-label-auto-mount.rules" "$AUTO_MOUNT_RULES_FILE")
	    showInfo "USB automount successfully fixed"
	else
	    showError "USB automount could not be fixed"
	fi
}

function applyXbmcNiceLevelPermissions()
{
	createFile $SYSTEM_LIMITS_FILE
    appendToFile $SYSTEM_LIMITS_FILE "$XBMC_USER             -       nice            -1"
	showInfo "Allowed XBMC to prioritize threads"
}

function addUserToRequiredGroups()
{
	sudo adduser $XBMC_USER video > /dev/null 2>&1				# to use video devices
	sudo adduser $XBMC_USER audio > /dev/null 2>&1				# to use audio devices
	sudo adduser $XBMC_USER users > /dev/null 2>&1				# for USB automount
	sudo adduser $XBMC_USER fuse > /dev/null 2>&1				# to use FUSE File system
	sudo adduser $XBMC_USER cdrom > /dev/null 2>&1				# to use CD-ROM
	sudo adduser $XBMC_USER plugdev > /dev/null 2>&1			# to access external storage devices
#    sudo adduser $XBMC_USER dialout > /dev/null 2>&1			# to use some remote controls through lirc
	showInfo "XBMC user added to required groups"
}

function addXbmcPpa()
{
    showInfo "Adding repository $XBMC_PPA ..."
	addRepository "$XBMC_PPA"
}

function distUpgrade()
{
    showInfo "Updating Ubuntu with latest packages (may take a while)..."
	sudo apt-get update > /dev/null 2>&1
	sudo apt-get -y dist-upgrade > /dev/null 2>&1
	showInfo "Ubuntu installation updated"
}

function installXinit()
{
    showInfo "Installing xinit..."
    IS_INSTALLED=$(aptInstall xinit)
}

function installPowerManagement()
{
    showInfo "Installing power management packages..."
    createDirectory "$TEMP_DIRECTORY" 1 0
    IS_INSTALLED=$(aptInstall policykit-1)			# for managing administrative policies and privileges - e.g. shut down computer without amdin rights
    IS_INSTALLED=$(aptInstall upower)				# Hibernate / Suspend computer
    IS_INSTALLED=$(aptInstall udisks)				# for D-Bus interfaces that can be used to query and manipulate storage devices. e.g. Airplay
    IS_INSTALLED=$(aptInstall acpi-support)
	download $DOWNLOAD_URL"custom-actions.pkla"
	createDirectory "$POWERMANAGEMENT_DIR"
    IS_MOVED=$(move $TEMP_DIRECTORY"custom-actions.pkla" "$POWERMANAGEMENT_DIR")
}

function installAudio()
{
    showInfo "Installing audio packages....\n!! Please make sure no used channels are muted !!"
#    IS_INSTALLED=$(aptInstall linux-sound-base)		# Don't needed when alsa-base is installed
#    IS_INSTALLED=$(aptInstall alsa-base)
    IS_INSTALLED=$(aptInstall alsa-utils)			# alsa-utils installs alsa-base and linux-sound-base
#    IS_INSTALLED=$(aptInstall libasound2)			# Don't needed when alsa-utils is installed
    sudo alsamixer
}

function installAirplay()
{
    showInfo "Installing Airplay Service..."
    IS_INSTALLED=$(aptInstall avahi-daemon)
}

function installLirc()
{
    clear
    echo ""
    echo "Installing lirc..."
    echo ""
    echo "------------------"
    echo ""
    
	sudo apt-get -y install lirc
	
	if [ "$?" == "0" ]; then
        showInfo "Lirc successfully installed"
    else
        showError "Lirc could not be installed (error code: $?)"
    fi
}

function allowRemoteWakeup()
{
    showInfo "Allowing for remote wakeup (won't work for all remotes)..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	handleFileBackup "$REMOTE_WAKEUP_RULES_FILE" 1 1
	download $DOWNLOAD_URL"remote_wakeup_rules"
	
	if [ -e $TEMP_DIRECTORY"remote_wakeup_rules" ]; then
	    sudo mv $TEMP_DIRECTORY"remote_wakeup_rules" "$REMOTE_WAKEUP_RULES_FILE" > /dev/null 2>&1
	    showInfo "Remote wakeup rules successfully applied"
	else
	    showError "Remote wakeup rules could not be downloaded"
	fi
}

function installTvHeadend()
{
    showInfo "Adding jabbors hts-stable PPA..."
	addRepository "$HTS_TVHEADEND_PPA"

    clear
    echo ""
    echo "Installing tvheadend..."
    echo ""
    echo "------------------"
    echo ""

    sudo apt-get -y install tvheadend
    
    if [ "$?" == "0" ]; then
        showInfo "TvHeadend successfully installed"
    else
        showError "TvHeadend could not be installed (error code: $?)"
    fi
}

function installOscam()
{
    showInfo "Adding oscam PPA..."
    addRepository "$OSCAM_PPA"

    showInfo "Installing oscam..."
    IS_INSTALLED=$(aptInstall oscam-svn)
}

function installXbmc()
{
    showInfo "Installing XBMC..."
    IS_INSTALLED=$(aptInstall xbmc)
#	IS_INSTALLED=$(aptInstall xbmc-bin)   #should be not necessary as xbmc depends on xbmc-bin 
}

function enableDirtyRegionRendering()
{
    showInfo "Enabling XBMC dirty region rendering..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	handleFileBackup $XBMC_ADVANCEDSETTINGS_FILE 0 1
	download $DOWNLOAD_URL"dirty_region_rendering.xml"
	createDirectory "$XBMC_USERDATA_DIR" 0 0
	IS_MOVED=$(move $TEMP_DIRECTORY"dirty_region_rendering.xml" "$XBMC_ADVANCEDSETTINGS_FILE")

	if [ "$IS_MOVED" == "1" ]; then
        showInfo "XBMC dirty region rendering enabled"
    else
        showError "XBMC dirty region rendering could not be enabled"
    fi
}

function installXbmcAddonRepositoriesInstaller()
{
    showInfo "Installing Addon Repositories Installer addon..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"plugin.program.repo.installer-1.0.5.tar.gz"
    createDirectory "$XBMC_ADDONS_DIR" 0 0

    if [ -e $TEMP_DIRECTORY"plugin.program.repo.installer-1.0.5.tar.gz" ]; then
        tar -xvzf $TEMP_DIRECTORY"plugin.program.repo.installer-1.0.5.tar.gz" -C "$XBMC_ADDONS_DIR" > /dev/null 2>&1
        
        if [ "$?" == "0" ]; then
	        showInfo "Addon Repositories Installer addon successfully installed"
	    else
	        showError "Addon Repositories Installer addon could not be installed (error code: $?)"
	    fi
    else
	    showError "Addon Repositories Installer addon could not be downloaded"
    fi
}

function configureAtiDriver()
{
    sudo aticonfig --initial -f > /dev/null 2>&1
    sudo aticonfig --sync-vsync=on > /dev/null 2>&1
    sudo aticonfig --set-pcs-u32=MCIL,HWUVD_H264Level51Support,1 > /dev/null 2>&1
}

function disbaleAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,0 > /dev/null 2>&1
    showInfo "Underscan successfully disabled"
}

function enableAtiUnderscan()
{
	sudo kill $(pidof X) > /dev/null 2>&1
	sudo aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,1 > /dev/null 2>&1
    showInfo "Underscan successfully enabled"
}

function installVideoDriver()
{
    showInfo "Installing $GFX_CARD video drivers (may take a while)..."
    IS_INSTALLED=$(aptInstall i965-va-driver)
	IS_INSTALLED=$(aptInstall libva-intel-vaapi-driver)
	IS_INSTALLED=$(aptInstall libva1)
	IS_INSTALLED=$(aptInstall libva-glx1)
    showInfo "$GFX_CARD video drivers successfully installed and configured"
}

function installAutomaticDistUpgrade()
{
    showInfo "Enabling automatic system upgrade..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"dist_upgrade.sh"
	IS_MOVED=$(move $TEMP_DIRECTORY"dist_upgrade.sh" "$DIST_UPGRADE_FILE" 1)
	
	if [ "$IS_MOVED" == "1" ]; then
	    IS_INSTALLED=$(aptInstall cron)
	    sudo chmod +x "$DIST_UPGRADE_FILE" > /dev/null 2>&1
	    handleFileBackup "$CRONTAB_FILE" 1
	    appendToFile "$CRONTAB_FILE" "0 */4  * * * root  $DIST_UPGRADE_FILE >> $DIST_UPGRADE_LOG_FILE"
	else
	    showError "Automatic system upgrade interval could not be enabled"
	fi
}

function removeAutorunFiles()
{
    if [ -e "$XBMC_INIT_FILE" ]; then
        showInfo "Removing existing autorun script..."
        sudo update-rc.d xbmc remove > /dev/null 2>&1
        sudo rm "$XBMC_INIT_FILE" > /dev/null 2>&1

        if [ -e "$XBMC_INIT_CONF_FILE" ]; then
		    sudo rm "$XBMC_INIT_CONF_FILE" > /dev/null 2>&1
	    fi
	    
	    if [ -e "$XBMC_CUSTOM_EXEC" ]; then
	        sudo rm "$XBMC_CUSTOM_EXEC" > /dev/null 2>&1
	    fi
	    
	    if [ -e "$XBMC_XSESSION_FILE" ]; then
	        sudo rm "$XBMC_XSESSION_FILE" > /dev/null 2>&1
	    fi
	    
	    showInfo "Old autorun script successfully removed"
    fi
}

function installXbmcInitScript()
{
    removeAutorunFiles
    showInfo "Installing XBMC init.d autorun support..."
    createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"xbmc_init_script"
	
	if [ -e $TEMP_DIRECTORY"xbmc_init_script" ]; then
	    if [ -e $XBMC_INIT_FILE ]; then
		    sudo rm $XBMC_INIT_FILE > /dev/null 2>&1
	    fi
	    
	    IS_MOVED=$(move $TEMP_DIRECTORY"xbmc_init_script" "$XBMC_INIT_FILE")

	    if [ "$IS_MOVED" == "1" ]; then
	        sudo chmod a+x "$XBMC_INIT_FILE" > /dev/null 2>&1
	        sudo update-rc.d xbmc defaults > /dev/null 2>&1
	        
	        if [ "$?" == "0" ]; then
                showInfo "XBMC autorun succesfully configured"
            else
                showError "XBMC autorun script could not be activated (error code: $?)"
            fi
	    else
	        showError "XBMC autorun script could not be installed"
	    fi
	else
	    showError "Download of XBMC autorun script failed"
	fi
}

function installNyxBoardKeymap()
{
    showInfo "Applying Pulse-Eight Motorola NYXboard advanced keymap..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"nyxboard.tar.gz"
    createDirectory "$XBMC_KEYMAPS_DIR" 0 0

    if [ -e $XBMC_KEYMAPS_DIR"keyboard.xml" ]; then
        handleFileBackup $XBMC_KEYMAPS_DIR"keyboard.xml" 0 1
    fi

    if [ -e $TEMP_DIRECTORY"nyxboard.tar.gz" ]; then
        tar -xvzf $TEMP_DIRECTORY"nyxboard.tar.gz" -C "$XBMC_KEYMAPS_DIR" > /dev/null 2>&1
        
        if [ "$?" == "0" ]; then
	        showInfo "Pulse-Eight Motorola NYXboard advanced keymap successfully applied"
	    else
	        showError "Pulse-Eight Motorola NYXboard advanced keymap could not be applied (error code: $?)"
	    fi
    else
	    showError "Pulse-Eight Motorola NYXboard advanced keymap could not be downloaded"
    fi
}

function installXbmcBootScreen()
{
    showInfo "Installing XBMC boot screen (please be patient)..."
    #IS_INSTALLED=$(aptInstall v86d)
    #IS_INSTALLED=$(aptInstall plymouth-label)
    sudo apt-get install -y plymouth-label v86d > /dev/null
    createDirectory "$TEMP_DIRECTORY" 1 0
    download $DOWNLOAD_URL"plymouth-theme-xbmc-logo.deb"
    
    if [ -e $TEMP_DIRECTORY"plymouth-theme-xbmc-logo.deb" ]; then
        sudo dpkg -i $TEMP_DIRECTORY"plymouth-theme-xbmc-logo.deb" > /dev/null 2>&1
        update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/xbmc-logo/xbmc-logo.plymouth 100 > /dev/null 2>&1
        handleFileBackup "$INITRAMFS_SPLASH_FILE" 1 1
        createFile "$INITRAMFS_SPLASH_FILE" 1 1
        appendToFile "$INITRAMFS_SPLASH_FILE" "FRAMEBUFFER=y"
        showInfo "XBMC boot screen successfully installed"
    else
        showError "Download of XBMC boot screen package failed"
    fi
}

function applyScreenResolution()
{
    RESOLUTION="$1"
    
    showInfo "Applying bootscreen resolution (will take a minute or so)..."
    handleFileBackup "$GRUB_HEADER_FILE" 1 0
    sudo sed -i '/gfxmode=/ a\  set gfxpayload=keep' "$GRUB_HEADER_FILE" > /dev/null 2>&1
    GRUB_CONFIG="nomodeset usbcore.autosuspend=-1 video=uvesafb:mode_option=$RESOLUTION-24,mtrr=3,scroll=ywrap"
    
    if [[ $GFX_CARD == INTEL ]]; then
        GRUB_CONFIG="usbcore.autosuspend=-1 video=uvesafb:mode_option=$RESOLUTION-24,mtrr=3,scroll=ywrap"
    fi
    
    handleFileBackup "$GRUB_CONFIG_FILE" 1 0
    appendToFile "$GRUB_CONFIG_FILE" "GRUB_CMDLINE_LINUX=\"$GRUB_CONFIG\""
    appendToFile "$GRUB_CONFIG_FILE" "GRUB_GFXMODE=$RESOLUTION"
    
    handleFileBackup "$INITRAMFS_MODULES_FILE" 1 0
    appendToFile "$INITRAMFS_MODULES_FILE" "uvesafb mode_option=$RESOLUTION-24 mtrr=3 scroll=ywrap"
    
    sudo update-grub > /dev/null 2>&1
    sudo update-initramfs -u > /dev/null
    
    if [ "$?" == "0" ]; then
        showInfo "Bootscreen resolution successfully applied"
    else
        showError "Bootscreen resolution could not be applied"
    fi
}

function installLmSensors()
{
    showInfo "Installing temperature monitoring package (apply all defaults)..."
    IS_INSTALLED=$(aptInstall lm-sensors)
    clear
    
    yes "" | sensors-detect
    
    if [ ! -e "$XBMC_ADVANCEDSETTINGS_FILE" ]; then
	    createDirectory "$TEMP_DIRECTORY" 1 0
	    download $DOWNLOAD_URL"temperature_monitoring.xml"
	    createDirectory "$XBMC_USERDATA_DIR" 0 0
	    IS_MOVED=$(move $TEMP_DIRECTORY"temperature_monitoring.xml" "$XBMC_ADVANCEDSETTINGS_FILE")

	    if [ "$IS_MOVED" == "1" ]; then
            showInfo "Temperature monitoring successfully enabled in XBMC"
        else
            showError "Temperature monitoring could not be enabled in XBMC"
        fi
    fi
    
    showInfo "Temperature monitoring successfully configured"
}

function reconfigureXServer()
{
    showInfo "Configuring X-server..."
	
	showInfo "Configuring Xwrapper..."
    handleFileBackup "$XWRAPPER_FILE" 1
    createFile "$XWRAPPER_FILE" 1 1
	appendToFile "$XWRAPPER_FILE" "allowed_users=anybody"
	
	#Do get 23.976 mode in XBMC working - xorg.conf has to be modifed.
	showInfo "Configuring Xorg.conf..."
	createDirectory "$TEMP_DIRECTORY" 1 0
	download $DOWNLOAD_URL"xorg.conf"
	handleFileBackup "$XORG_FILE" 1 1
	IS_MOVED=$(move $TEMP_DIRECTORY"xorg.conf" "$XORG_FILE")
	
	if [ "$IS_MOVED" == "1" ]; then
		showInfo "xorg.conf successfully configured"
    else
        showError "xorg.conf could not be configured"
    fi
	
	showInfo "X-server successfully configured"
}

function selectXbmcTweaks()
{
    cmd=(dialog --title "Optional XBMC tweaks and additions" 
        --backtitle "$SCRIPT_TITLE" 
        --checklist "Plese select to install or apply:" 
        15 $DIALOG_WIDTH 6)
        
    options=(1 "Enable dirty region rendering (improved performance)" on
            2 "Enable temperature monitoring (confirm with ENTER)" on
            3 "Install Addon Repositories Installer addon" off
            4 "Apply improved Pulse-Eight Motorola NYXboard keymap" off)
            
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices
    do
        case ${choice//\"/} in
            1)
                enableDirtyRegionRendering
                ;;
            2)
                installLmSensors
                ;;
            3)
                installXbmcAddonRepositoriesInstaller 
                ;;
            4)
                installNyxBoardKeymap 
                ;;
        esac
    done
}

function selectScreenResolution()
{
    cmd=(dialog --backtitle "Select bootscreen resolution (required)"
        --radiolist "Please select your screen resolution, or the one sligtly lower then it can handle if an exact match isn't availabel:" 
        15 $DIALOG_WIDTH 6)
        
    options=(1 "720 x 480 (NTSC)" off
            2 "720 x 576 (PAL)" off
            3 "1280 x 720 (HD Ready)" off
            4 "1366 x 768 (HD Ready)" off
            5 "1920 x 1080 (Full HD)" on)
         
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case ${choice//\"/} in
        1)
            applyScreenResolution "720x480"
            ;;
        2)
            applyScreenResolution "720x576"
            ;;
        3)
            applyScreenResolution "1280x720"
            ;;
        4)
            applyScreenResolution "1366x768"
            ;;
        5)
            applyScreenResolution "1920x1080"
            ;;
        *)
            selectScreenResolution
            ;;
    esac
}

function selectAdditionalPackages()
{
    cmd=(dialog --title "Other optional packages and features" 
        --backtitle "$SCRIPT_TITLE" 
        --checklist "Plese select to install:" 
        15 $DIALOG_WIDTH 6)
        
    options=(1 "Lirc (IR remote support)" off
            2 "Hts tvheadend (live TV backend)" off
            3 "Oscam (live HDTV decryption tool)" off
            4 "Automatic upgrades (every 4 hours)" off)
            
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices
    do
        case ${choice//\"/} in
            1)
                installLirc
                ;;
            2)
                installTvHeadend 
                ;;
            3)
                installOscam 
                ;;
            4)
                installAutomaticDistUpgrade
                ;;
        esac
    done
}

function optimizeInstallation()
{
    showInfo "Optimizing installation..."
    handleFileBackup "$SYSCTL_CONF_FILE" 1 0
    createFile "$SYSCTL_CONF_FILE" 1 0
    appendToFile "$SYSCTL_CONF_FILE" "dev.cdrom.lock=0"
#	The Linux kernel provides a tweakable setting that controls how often the swap file is used, called swappiness
#	http://askubuntu.com/questions/103915/how-do-i-configure-swappiness
#	No swapfile, no swappiness needed.
    appendToFile "$SYSCTL_CONF_FILE" "vm.swappiness=0"
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

function rebootMachine()
{
    showInfo "Reboot system..."
	dialog --title "Installation complete" \
		--backtitle "$SCRIPT_TITLE" \
		--yesno "Do you want to reboot now?" 7 $DIALOG_WIDTH

	case $? in
        0)
            showInfo "Installation complete. Rebooting..."
            clear
            echo ""
            echo "Installation complete. Rebooting..."
            echo ""
            sudo reboot now > /dev/null 2>&1
	        ;;
	    1) 
	        showInfo "Installation complete. Not rebooting."
            quit
	        ;;
	    255) 
	        showInfo "Installation complete. Not rebooting."
	        quit
	        ;;
	esac
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
dialog	--title "XBMC installation script" \
		--backtitle "$SCRIPT_TITLE" \
		--msgbox "\nWelcome to the XBMC minimal installation script. Some parts may take a while to install depending on your internet connection speed.\n\nPlease be patient..." 12 $DIALOG_WIDTH
trap control_c SIGINT

#fixLocaleBug
fixUsbAutomount
applyXbmcNiceLevelPermissions
addUserToRequiredGroups
addXbmcPpa
distUpgrade
installVideoDriver
installXinit
installXbmc
installXbmcInitScript
#installXbmcBootScreen
#selectScreenResolution
reconfigureXServer
installPowerManagement
#installAudio
installAirplay
#selectXbmcTweaks
#selectAdditionalPackages
#allowRemoteWakeup
optimizeInstallation
cleanUp
rebootMachine
