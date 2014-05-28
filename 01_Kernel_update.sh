#!/bin/bash
#
# @author   Morrtin
# @date     2014-05-28
# @version  2.02
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.14.1-trusty"
FIRMWARE_VERSION="v1.130"

function download()
{
    URL="$@"
    wget -q "$URL"
}

clear
mkdir ~/3.13.x
cd ~/3.13.x
echo "Downloading Firmware $FIRMWARE_VERSION"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.130_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.14.1-031401-generic_3.14.1-031401.201404141220_amd64.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.14.1-031401_3.14.1-031401.201404141220_all.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.14.1-031401-generic_3.14.1-031401.201404141220_amd64.deb"
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
rm ./01_Kernel_update.sh
rm -R ~/3.13.x