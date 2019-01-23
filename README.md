This repository's main purpose is to hold and document modifications done
to Clonezilla (Live/SE). These modifications were specifically targeted
for our production needs. The motivation behind such changes were done
so to speed up the process of rebooting a server, to fix broken basic
GUI features, to add basic IT functions (server edition). Additionally,
I've added a lot of scripts and basic C programs in [beast/](beast) 
which are used to automate many of our production needs for SSDs/HDDs &
USBs.
 
### rebuild.sh
The main purpose of [rebuild.sh](rebuild.sh) is to be able to use any filesystem.squashfs,
wether it has been modified already or not and to ultimately produce the same
consistent image each time, hence all the recopying of files. All files
located in [server/](server) and [beast/](beast)  are files that have been in some way 
modified from the original filesystem.squashfs. I've also included the 
copying of symlinks as well. However all changes may not have been 
accounted for, those will be eventually dealt with.


The following is the synopsis:

rebuild.sh OPTION

OPTION:

--beast, beast						- Rebuild for imaging beast

--beast-chroot, beast-chroot		- Chroot into beast's rootfs

--server, server					- Rebuild for imaging servers

--server-chroot, server-chroot		- Chroot into server's rootfs

--test-initrd, test-initrd			- Test Clonezilla-Live initrd with qemu

--initrd, initrd					- Rebuild initrd.img for Clonezilla-Live.initrd.img

### --test-initrd, test-initrd
You will need [qemu](https://www.qemu.org/) installed in your system.

# Beast
---

### beast/filesystem.squashfs
You'll need an exisitng filesystem.squahfs as I couldn't upload my working
copy due to file size limits on github. A download link to can be found 
[here](https://mega.nz/#!u9ZhGIzQ!l_C5uRzM-TDhhGgjuEz2r_npwrV16YNlYHrJYxuBjlk).
You'll have to rename it (filesystem.squashfs) and uncompress it inside 
/path/to/[DigitalVAR/beast](beast/) by executing the following:

`sudo unsquashfs filesystem.squashfs`

### Packages
* Installed: inotify-tools, curl
* Uninstalled: 

You could reproduce this by chrooting:

`./rebuild.sh beast-chroot`

and then installing said package(s):

`apt update && apt install curl inotify-tools`

#### DO NOT UPDATE PACKAGES (apt upgrade)

### beast/rc.local
The purpose of [rc.local](beast/rc.local) was to provide a 
quick-n-dirty-easy-updater for all scripts and C programs. It also gave
us the flexibilty to manage updates remotely upon each boot without the
need of repacking filesystem.squashfs for each minor change.

### beast/motd.txt
[motd.txt](beast/motd.txt) will give you a synopsis of all the scripts
and C programs I wrote. This txt file is displayed on every tty login 
instance, as seen in [profile](beast/profile).

### Adding new tools (as seen in motd.txt)
Three files are involved in my quick-n-dirty-easy-updater to deploy new
tools on-the-fly.

* Add the files/executables in [beast/](beast/) directory
* Chmod them (`chmod +x script.sh/binarary`) if they're executables

  Although it's not necessary as the quick-n-dirty-easy-updater takes 
  care of this but it might be needed for local development purposes.

* Open: [file-chmodx](beast/file-chmodx), [file-dest](beast/file-dest), and [files](beast/files)
* Add the name of the file into [files](beast/files) at the end of the existing list
* Add the destintation of where the file will reside in the filesystem.squashfs at the end of [file-dest](beast/file-dest)
* If the file is an executable/script add the file name with its absolute path into the end of [file-chmodx](beast/file-chmodx)
* Optionally add the synopsis of the new tool into [motd.txt](beast/motd.txt)

Don't forget to add the new file into lines 8-9 in `rebuild.sh` so that
filesystem.squashfs gets updated on the next rebuild.

### Deploying
Copy filesystem.squahfs to /path/to/CLONER/live

# Server
---
### server/filesystem.squashfs
Much like the beast, I tried writing rebuild.sh and keeping all files that 
I've modified so that rebuild.sh can give you what I once made in a 
presistent manner. If you don't want to go throgh and make surethat all
changes have been made from an original copy, then you can download my
working copy [here](https://mega.nz/#!D5YBQQKQ!YM46X2bZytg074hqV75LkB1kiZI_Cq9woTLLZi8DG8E) 
(resquashed on 9/16/2018). Although its more than likely this has changed 
by the time you download it, the changes won't be major from now on out. 
Make sure to rename it to filesystem.squashfs and that it resides in the 
[server/](server/) directory. To uncompress it, execute the following:

`sudo unsquashfs filesystem.squashfs`

### Packages
* Installed: syncthing
* Uninstall: vim-common, vim-runtime, vim-tiny

### server/desktop-background
Symlink to reflect new default wallpapers from svgs to pngs

### server/drbl-functions
Too long of a file. Hopefully I remebered to mention all lines edited. If not, sorry.
* Lines edited: 2516, 3539-3541, 3789-3791
* Can't remember if any other line was edited.

### drbl-sl
Remove unwanted text (Clonezilla Live 0.0.0-0 runs on RAM) from PXE menu when imaging units
* Lines edited: 802-804

### server/drbl-live
Please don't tell me to press Enter to continue.
* Lines editied: 153-155, 173-175, 304-305, 318, & 335-336

### server/drbl-live-conf-x
All other firstboot* and Forcevideo-drbl-live don't matter, I figured.
* Lines edited: 32-32, automatically start the GUI, no need to ask us.

### server/gnome-background.xml
File updated to reflect new custom wallpapers from originally svgs to pngs
as seen in [desktop-wallpaper/](server/desktop-wallpaper).
* Lines edited: 5-15, changed .svg to .png

### server/hosts
Pretty self explanatory.

### server/ifupdownsucks.sh
networks(5) is a powerful system daemon but it has limitations.
Unfortunately for our case, networks(5) isn't customizable enough for our
environment. So [ifupdownsucks.sh](server/ifupdownsucks.sh) was created 
to manage the IP address of both Clonezilla servers in a live environment.
[ifupdownsucks.sh](server/ifupdownsucks.sh) does have to run on a infinite
loop while the OS is running as rebooting either one of the servers will
cause the IP address of the other one to drop. Additionally, 
[ifupdownsucks.sh](server/ifupdownsucks.sh) only starts after eth0, 
eth0:1, and dhcp are brought up otherwise `ocs-live-netcfg` 
(or some other script in the latter) will configure eth1 as as the LAN
that faces the PXE clients.

### server/ocs-functions
* Line(s) edited: 4865-4866, 6596-6598, 6651-6653, 6932-6934, 7609-7911, no more `Press Enter` nonsense

### server/ocs-live-blacklist.conf
This is used to blacklist kernel modules from loading. Usually these 
modules are completely useless but may include those causing kernel panics 
or other issues when loaded automatically by the kernel itself. You will
need to rebuild the initrd (`./rebuild.sh initrd`) and the server
filesystem.squashfs (`./rebuild.sh server`)

### server/ocs-live-netcfg
This file basically configures the ethernet that is facing the PXE clients.
All lines mentioned automate the configuration with a static ip address.
* Lines edited: 146-149, 151-154, 160-164, 171,174, 442-445, 462-473

### server/rc.local
rc.local not only gets executed on the server live but also on the PXE 
clients (units to be images). So becareful of what you put in there.
This file ultimately gets copied to /tftpboot/nbi_root

### server/startafterifupdownsucks.sh
This script, unlike [ifupdownsucks.sh](server/ifupdownsucks.sh), is meant
to be run literally as the filename states but only executing whatever
you want it once. So basically after all NICs have been configured and 
dhcp is running. This is important because if ssh is invoked by [rc.local](server/rc.local)
or systemctl before starting Clonezilla server (`sudo ocs-srv-live -b start`)
ssh will not work. `sudo ocs-srv-live -b start` invokes a drbl script
that regenerates ssh certificates and in doing so when ssh had already
done so causes ssh to fail.

### server/syncthing*.service
Excluding syncthing-resume.service, both of these files had to be edited
to work in a live environment. Since we're using a live environment 
the HDDs in the servers that contain all clonezilla images (mounted as 
/home/partmag) are responsible of holding all configurations files and 
the local database that syncthing uses to keep track of file and 
directories /home/partimag/{.config/syncthing/*, .stfolder, .stignore} 
So therefore -home was added to both of these files.

### server/thunar*.xml
These files are copied to /opt and then are copied to
/home/user/.config/xfce4/xfconf/xfce-perchannel-xml upon each boot as seen in [rc.local](server/rc.local)
Both are responsible of providing modified default settings to our needs
for the ability of (a) to click on a USB mass storage device and automatically
mount it, and (b) to set Thunar's default view as 'detailed list'.

### server/vmlinuz - Kernel
We used Clonezilla SE stable release (2.5.1-16) as the base image for
our modified copy. The kernel that was shipped out with (4.9.0-2-amd64)
was infact missing some entries in the modules.alias file for newer
hardware. So I decided to update to the latest kernel (4.18.7 - as of 9/9/2018).

The kernel modules are located in three different places!!!
 * initrd.img (/lib/modules) - Server and PXE use
 * /lib/modules - Server use after initrd.img
 * /tftpboot/nbi_root/lib/modules - PXE use, after initrd.img is done /tftpboot/nbi_root directory gets mounted as /

The steps below summarize what needs to be done so that
filesystem.squashfs & the intial ramdisk can utilize the new kernel
modules. All three locations must have the same exact modules.

* Download the latest stable kernel from [http://kernel.org/](http://kernel.org)
* Untar it: `tar xvf linux-*.tar.xz`
* `cd linux-*`
* `make menuconfig`
   
   Include all desired modules, I included: iSCSi, SCSi, PATA, SATA, NVMe, Ethernet, USB Ethernet, 802.11, and all filesystems
   
   `make allmodconfig` did not yield a usable kernel and modules
* `make -j 16` (16 = CPU cores * 2)
* `mkdir install`
* `INSTALL_MOD_PATH="install" make modules_install`
* `cp arch/x86/boot/bzImage /path/to/DigitalVAR/server/vmlinuz`
* Delete old modules: `rm -rf /path/to/DigitalVAR/server/initrd-root/lib/modules/*`
* Delete unneeded symlinks: `rm -rf install/modules/{build,source}`
* Copy new modules: `cp -r install/lib/modules/* /path/to/DigitalVAR/server/initrd-root/modules`
* Go back to this repo: `cd /path/to/DigitalVAR`
* Rebuild initial ramdisk `./rebuild.sh initrd`
* Test initial ramdisk (Optional, kernel should not panic, will dump you into busybox bash if successful):
  `./rebuild.sh test-initrd`
* Rebuild the server filesystem.squashfs to propigate drivers (Not needed until complete with all other modifications): 
  `./rebuild.sh server`


### Deploying
Copy initrd.img, filesystem.squahfs, and vmlinuz to /path/to/CLONER SE/live
