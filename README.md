xbmc-ubuntu-minimal
===================

* Install Ubuntu Server 12.04LTS on your machine...

* Make sure you installed your Ubuntu with xbmc user or create xbmc user after installation 
  and add user to sudo group

* On INTEL systems it is recommended to upgrade to kernel 3.9 (inclusive firmware update)

```
cd ~ 
https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/download/01_Kernel_update.sh
bash ./01_Kernel_update
```

* ...and run the following on the machine afterwards to install and configure XBMC (NVIDIA, ATI and Intel video cards supported):

```
cd ~ 
https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/download/02_XBMC.sh
bash ./02_XBMC.sh
```
[![lgplv3](https://f.cloud.github.com/assets/3521959/153710/2745bbea-7601-11e2-8b61-c8ff3ef97d32.png)](http://www.gnu.org/licenses/lgpl.txt)
