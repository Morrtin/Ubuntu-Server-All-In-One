Ubuntu All-In-One Server
========================

* Install Ubuntu Server 12.04 LTS 64bit on your machine...
* After installation connect your A/V receiver, TV to the Server like you will use it in production
* Start Server and from now on only use SSH

* On INTEL systems it is recommended to upgrade to kernel 3.9 (inclusive firmware update) for proper XBMC

```
cd ~ 
wget https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/01_Kernel_update.sh
bash ./01_Kernel_update.sh
```

* Create xbmc user and add it to sudo group
* Logon to xbmc user via SSH
* ...and run the following to install and configure XBMC (NVIDIA, ATI and Intel video cards supported):

```
cd ~ 
wget https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/02_XBMC.sh
bash ./02_XBMC.sh
```
[![lgplv3](https://f.cloud.github.com/assets/3521959/153710/2745bbea-7601-11e2-8b61-c8ff3ef97d32.png)](http://www.gnu.org/licenses/lgpl.txt)
