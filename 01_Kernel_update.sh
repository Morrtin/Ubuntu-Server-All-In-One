#!/bin/bash
#
# @author   Morrtin
# @date     2013-10-20
# @version  1.15
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.11.6-saucy"
FIRMWARE_VERSION="v1.116"

function download()
{
    URL="$@"
    wget -q "$URL"
}

clear
mkdir ~/3.11.x
cd ~/3.11.x
echo "Downloading Firmware $FIRMWARE_VERSION"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.116_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.11.6-031106-generic_3.11.6-031106.201310181453_amd64.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.11.6-031106_3.11.6-031106.201310181453_all.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.11.6-031106-generic_3.11.6-031106.201310181453_amd64.deb"
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
rm ./01_Kernel_update.sh
rm -R ~/3.11.x