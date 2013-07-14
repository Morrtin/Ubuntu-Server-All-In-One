#!/bin/bash
#
# @author   Morrtin
# @date     2013-07-11
# @version  1.0
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.10.1-saucy"
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
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.1-031001-generic_3.10.1-031001.201307131550_amd64.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.1-031001_3.10.1-031001.201307131550_all.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.10.1-031001-generic_3.10.1-031001.201307131550_amd64.deb"  > /dev/null 2>&1
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
rm ./01_Kernel_update.sh
rm -R ~/3.10.x
