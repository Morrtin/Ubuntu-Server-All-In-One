#!/bin/bash
#
# @author   Morrtin
# @date     2013-07-27
# @version  1.3
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.10.3-saucy"
FIRMWARE_VERSION="v1.112"

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

clear
mkdir ~/3.10.x
cd ~/3.10.x
echo "Downloading Firmware $FIRMWARE_VERSION"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.112_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.3-031003-generic_3.10.3-031003.201307251835_amd64.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.3-031003_3.10.3-031003.201307251835_all.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.10.3-031003-generic_3.10.3-031003.201307251835_amd64.deb"  > /dev/null 2>&1
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
rm ./01_Kernel_update.sh
rm -R ~/3.10.x
