#!/bin/bash
#
# @author   Morrtin
# @date     2013-05-16
# @version  1.0
#

SCRIPT_TITLE="Test test"
L_FIRMWARE="linux-firmware_1.106_all.deb"
DIALOG_WIDTH=70

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

function selectKernel()
{
  mkdir ~/firmware
  cd ~/firmware
  wget -q "http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"$L_FIRMWARE > /dev/null 2>&1
#sudo dpkg -i $L_FIRMWARE
	
    cmd=(dialog --title "Kernel / Firmware update"
			--backtitle "Kernel architecture"
        --radiolist "Plese select to download:" 
        15 $DIALOG_WIDTH 6)
        
    options=(1 "32bit" off
            2 "64bit" on)
         
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    case ${choice//\"/} in
        1)
            mkdir ~/3.9.0
            cd ~/3.9.0
	    wget -q "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.9-raring/linux-headers-3.9.0-030900-generic_3.9.0-030900.201304291257_i386.deb"  > /dev/null 2>&1
	    wget -q "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.9-raring/linux-headers-3.9.0-030900_3.9.0-030900.201304291257_all.deb" > /dev/null 2>&1
	    wget -q "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.9-raring/linux-image-3.9.0-030900-generic_3.9.0-030900.201304291257_i386.deb" > /dev/null 2>&1
            ;;
        2)
            mkdir ~/3.9.0
	    cd ~/3.9.0
	    wget -q "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.9-raring/linux-headers-3.9.0-030900-generic_3.9.0-030900.201304291257_amd64.deb"  > /dev/null 2>&1
	    wget -q "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.9-raring/linux-headers-3.9.0-030900_3.9.0-030900.201304291257_all.deb"  > /dev/null 2>&1
	    wget -q "http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.9-raring/linux-image-3.9.0-030900-generic_3.9.0-030900.201304291257_amd64.deb"  > /dev/null 2>&1
            ;;
        *)
            selectKernel
            ;;
    esac
	
#sudo dpkg -i *deb
#sudo update-grub
}

selectKernel
