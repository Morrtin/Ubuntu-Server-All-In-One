#!/bin/bash
#
# @author   Morrtin
# @date     2013-08-24
# @version  1.9
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
KERNEL_VERSION="v3.10.9-saucy"
FIRMWARE_VERSION="v1.113"

function download()
{
    URL="$@"
    wget -q "$URL"
}

clear
mkdir ~/3.10.x
cd ~/3.10.x
echo "Downloading Firmware $FIRMWARE_VERSION"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.113_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.9-031009-generic_3.10.9-031009.201308201935_amd64.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.10.9-031009_3.10.9-031009.201308201935_all.deb"
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.10.9-031009-generic_3.10.9-031009.201308201935_amd64.deb"
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
rm ./01_Kernel_update.sh
rm -R ~/3.10.x
