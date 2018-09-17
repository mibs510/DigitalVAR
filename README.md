# DigitalVAR
---

This repository's main purpose is to hold and document modifications done
to Clonezilla (Live/SE). These modifications were specifically targeted
for our production needs. The motivation behind such changes were done
so to speed up the process of rebooting a server, to fix broken basic
GUI features, to add basic IT functions (server edition). Additionally,
I've added a lot of scripts and basic C programs in [beast/](beast) 
which are used to automate many of our production needs for SSDs/HDDs &
USBs.
 
### rebuild.sh
The main purpose of rebuild.sh is to be able to use any filesystem.squashfs
wether it has been modified already or not and to ultimately produce the same
consisnent image each time, hence all the recopying of files. I've also 
included the copying of symlinks as well. However all changes may not 
have been accounted for so and those will be eventually dealt with.


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

### Rebuild/filesystem.squashfs
You'll need an exisitng filesystem.squahfs as I couldn't upload my working
copy due to file size limits on github. A link to filedropper.com can be
found [here](). You have to uncompress it inside /path/to/DigitalVAR/beast
by executing the following:

`unsquashfs filesystem.squahfs`

### Packages
I only had to install curl (which is included for offline installs)
You could reproduce this by chrooting:

`./rebuild.sh beast-chroot`

and then installing said package:

`apt update && apt install curl`

### rc.local
The purpose of [rc.local](beast/rc.local) was to provide a 
quick-n-dirty-easy-updater for all scripts and C programs. It also gave
us the flexibilty to manage updates remotely upon each boot without the
need of repacking filesystem.squashfs for each minor change.

### motd.txt
[motd.txt](beast/motd.txt) will give you a synopsis of all the scripts
and C programs I wrote. This txt file is displayed on every tty login 
instance, as seen in [profile](beast/profile).

### Deploying
Copy filesystem.squahfs to /path/to/USB_ROOT/live

# Server
---

### ifupdownsucks.sh
networks(5) is a powerful system daemon but it has limitations.
Unfortunately for our case, networks(5) isn't customizable enough for our
environment. So [ifupdownsucks.sh](server/ifupdownsucks.sh) was created 
to manage the IP address of both Clonezilla servers in a live environment.
[ifupdownsucks.sh](server/ifupdownsucks.sh) does have to run on infinite
loop while the OS is running as rebooting either one of the servers will
cause the IP address of the other one to drop.

### startafterifupdownsucks.sh
This script, unlike [ifupdownsucks.sh](server/ifupdownsucks.sh), is meant
to be run literally as the filename states but only executing whatever
you want it once. So basically after all NICS have been configured and 
dhcp is running.

### rc.local
rc.local not only gets executed on the server live but also on the PXE 
clients (units to be images). So becareful of what you put in there.
This file ultimately gets copied to /tftpboot/nbi_root


### Kernel
We used Clonezilla SE stable release (2.5.1-16) as the base image for
our modified copy. The kernel that was shipped out with (4.9.0-2-amd64)
was infact missing some entries in the modules.alias file for newer
hardware. So I decided to update to the latest (4.18.7 - as of 9/9/2018).

The kernel modules are located in three different places!!!
 * Inside initrd.img - Server and PXE use
 * /lib/modules - Server use after initrd.img
 * /tftpboot/nbi_root/lib/modules - PXE use, after initrd.img is done /tftpboot/nbi_root directory gets mounted as /

The steps below summarize what needs to be done so that
filesystem.squashfs & the intial ramdisk can utilize the new kernel
modules.

* Download the latest stable kernel from [http://kernel.org/](http://kernel.org)
* Untar it: `tar xvf linux-*.tar.xz`
* `cd linux-*`
* `make menuconfig`
* Include all desired modules, I included: iSCSi, SCSi, PATA, SATA, NVMe, Ethernet, USB Ethernet, 802.11, All Filesystems
* `make -j 16` (16 = CPU cores * 2)
* `mkdir install`
* `INSTALL_MOD_PATH="install" make modules_install`
* `cp arch/x86/boot/bzImage /path/to/DigitalVAR/server/vmlinuz`
* Delete old modules: `rm -rf /path/to/DigitalVAR/server/initrd-root/lib/modules/*`
* Delete unneeded symlinks: `rm -rf install/modules/{build,source}`
* Copy new modules: `cp -r install/lib/modules/* /path/to/DigitalVAR/server/initrd-root/modules`
* Go back to this repo: `cd /path/to/DigitalVAR`
* Rebuild initial ramdisk `./rebuild.sh initrd`
* Test initial ramdisk (Optional, kernel should not panic, will dump you into busybox bash): `./rebuild.sh test-initrd`
* Propigate drivers (Not needed until complete with any other modification): `./rebuild.sh server`


### Deploying
Copy initrd.img, filesystem.squahfs, and vmlinuz to /path/to/USB_ROOT/live
