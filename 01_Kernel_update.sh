#!/bin/bash
#
# @author   Morrtin
# @date     2013-05-16
# @version  1.0
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.9-raring/"

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

clear
mkdir ~/firmware
cd ~/firmware
echo "Downloading Firmware"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.108_all.deb"
echo "Updating Firmware"
sudo dpkg -i *deb
	
mkdir ~/3.9.0
cd ~/3.9.0
echo "Downloading Kernel"
download $KERNEL_DOWNLOAD_URL"linux-headers-3.9.0-030900-generic_3.9.0-030900.201304291257_amd64.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"linux-headers-3.9.0-030900_3.9.0-030900.201304291257_all.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"linux-image-3.9.0-030900-generic_3.9.0-030900.201304291257_amd64.deb"  > /dev/null 2>&1
echo "Updating Kernel"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
