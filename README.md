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


* Latest firmware and kernel v3.10.x upgrade
```
cd ~ 
wget https://raw.github.com/Morrtin/Ubuntu-Server-All-In-One/master/01_Kernel_update.sh
bash ./01_Kernel_update.sh
```

XBMC setup specifics:
* Custom xorg.conf for my TV - Can be deleted at: /etc/X11
* XBMC ppa used: ppa:wsnipex/vaapi

```
Packages not installed:
```
* fixLocaleBug
* XbmcBootScreen
* ScreenResolution
* Audio
* XbmcTweaks
* AdditionalPackages
* RemoteWakeup

These packages can be enabled when you edit the script before running it and
remove hashes (#) at the bottom of the file.

* ...and run the following to install and configure XBMC:

```
cd ~ 
wget https://github.com/Morrtin/Ubuntu-Server-All-In-One/raw/master/02_XBMC.sh
bash ./02_XBMC.sh
```

[![lgplv3](https://f.cloud.github.com/assets/3521959/153710/2745bbea-7601-11e2-8b61-c8ff3ef97d32.png)](http://www.gnu.org/licenses/lgpl.txt)
