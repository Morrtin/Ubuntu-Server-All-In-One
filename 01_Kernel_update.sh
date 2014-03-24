#!/bin/bash
#
# @author   Morrtin
# @date     2014-03-24
# @version  1.20
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.11.10.6-saucy"
FIRMWARE_VERSION="v1.126"

function download()
{
    URL="$@"
    wget -q "$URL"
}

clear
mkdir ~/3.11.x
cd ~/3.11.x
echo "Downloading Firmware $FIRMWARE_VERSION"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.126_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.11.10-03111006-generic_3.11.10-03111006.201403120635_amd64.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.11.10-03111006_3.11.10-03111006.201403120635_all.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.11.10-03111006-generic_3.11.10-03111006.201403120635_amd64.deb"
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
rm ./01_Kernel_update.sh
rm -R ~/3.11.x