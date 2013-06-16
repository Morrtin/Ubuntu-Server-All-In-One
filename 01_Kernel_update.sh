#!/bin/bash
#
# @author   Morrtin
# @date     2013-05-30
# @version  1.0
#

FIRMWARE_DOWNLOAD_URL="http://ubuntu.mirror.cambrium.nl/ubuntu//pool/main/l/linux-firmware/"
KERNEL_DOWNLOAD_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
<<<<<<< HEAD
KERNEL_VERSION="v3.9.5-saucy"
=======
KERNEL_VERSION="v3.9.6-saucy"
>>>>>>> update firmware & kernel version

function download()
{
    URL="$@"
    wget -q "$URL" > /dev/null 2>&1
}

clear
mkdir ~/3.9.x
cd ~/3.9.x
echo "Downloading Firmware"
download $FIRMWARE_DOWNLOAD_URL"linux-firmware_1.109_all.deb"
echo "Downloading Kernel $KERNEL_VERSION"
<<<<<<< HEAD
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.9.5-030905-generic_3.9.5-030905.201306071748_amd64.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.9.5-030905_3.9.5-030905.201306071748_all.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.9.5-030905-generic_3.9.5-030905.201306071748_i386.deb"  > /dev/null 2>&1
=======
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.9.6-030906-generic_3.9.6-030906.201306131535_amd64.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-headers-3.9.6-030906_3.9.6-030906.201306131535_all.deb"  > /dev/null 2>&1
download $KERNEL_DOWNLOAD_URL"$KERNEL_VERSION/linux-image-3.9.6-030906-generic_3.9.6-030906.201306131535_amd64.deb"  > /dev/null 2>&1
>>>>>>> update firmware & kernel version
echo "Updating computer"
sudo dpkg -i *deb
echo "Updating Grub"
sudo update-grub
cd ~
