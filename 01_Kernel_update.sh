#!/bin/bash
#
# @author   Morrtin
# @date     2013-08-02
# @version  1.4
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.10.4-saucy"
FIRMWARE_VERSION="v1.112"

function download()
{
    URL="$@"
    wget -q "$URL"
}

clear
mkdir ~/3.10.x
cd ~/3.10.x
echo "Downloading Firmware $FIRMWARE_VERSION"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.112_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.4-031004-generic_3.10.4-031004.201307282043_amd64.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.4-031004_3.10.4-031004.201307282043_all.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.10.4-031004-generic_3.10.4-031004.201307282043_amd64.deb"
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
rm ./01_Kernel_update.sh
rm -R ~/3.10.x
