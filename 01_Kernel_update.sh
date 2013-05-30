#!/bin/bash
#
# @author   Morrtin
# @date     2013-05-30
# @version  1.0
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.9.4-saucy"

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

clear
mkdir ~/3.9.x
cd ~/3.9.x
echo "Downloading Firmware"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.108_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.9.4-030904-generic_3.9.4-030904.201305241545_amd64.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.9.4-030904_3.9.4-030904.201305241545_all.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.9.4-030904-generic_3.9.4-030904.201305241545_amd64.deb"  > /dev/null 2>&1
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
