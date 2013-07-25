Ubuntu All-In-One Server
========================
ATTENTION: These scripts are designed to support my server setup.
I am using a INTEL system (Intel Core i3-2105 - Sandybridge).
If you have the same hardware then feel free to use them,
otherwise I don't recommend to run these scripts.

* Install Ubuntu Server 13.04 64-bit version on your machine...
* After installation connect your A/V receiver or TV to the Server like you will use it in production
* Start Server and from now on ONLY use SSH
* Create xbmc user and add it to sudo group
* Logon to xbmc user via SSH

* On INTEL systems it is recommended to upgrade at least to kernel 3.9 (inclusive firmware update) for proper XBMC.

* An upgrade to kernel 3.10.1 didn't work for me. Airplay was broken so I downgraded to 3.9.x
```
cd ~ 
wget https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/01_Kernel_update_3_9_x.sh
bash ./01_Kernel_update_3_9_x.sh
```

* If you like you can try / use kernel 3.10.x
```
cd ~ 
wget https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/01_Kernel_update.sh
bash ./01_Kernel_update.sh
```

* ...and run the following to install and configure XBMC:

ATTENTION: XBMC script copies a xorg.conf with a special monitor setup (my TV).
You can delete the file at: /etc/X11

```
cd ~ 
wget https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/02_XBMC.sh
bash ./02_XBMC.sh
```
[![lgplv3](https://f.cloud.github.com/assets/3521959/153710/2745bbea-7601-11e2-8b61-c8ff3ef97d32.png)](http://www.gnu.org/licenses/lgpl.txt)
