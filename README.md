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

--server, server					- Rebuild for imaging servers

--server-chroot, server-chroot		- Chroot into server's rootfs

--test-initrd, test-initrd			- Test Clonezilla-Live initrd with qemu

--initrd, initrd					- Rebuild initrd.img for Clonezilla-Live.initrd.img

### --test-initrd, test-initrd
You will need [qemu](https://www.qemu.org/) installed in your system.

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
* Installed: syncthing, gsmartcontrol, nut-client, 
			 scrot (backup to fbgrab), ftp-upload, inotify-tools,
			 udisks2, crda
* Uninstall: vim-common, vim-runtime, vim-tiny

### /etc/default/crda
Set REGDOMAIN=US otherwise we get a very vague deauthentication by local choice (Reason: 3=DEAUTH_LEAVING) 

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

### server/drbl-ocs.conf
Changed `HALT_REBOOT_OPT=""` to `HALT_REBOOT_OPT="-f -n"` to force poweroff/reboot immediately without syncing via systemd.

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
* Line 8819: Prevent set-netboot-1st-efi-nvram from running. reorders the boot order on most Dell firmware so that PXE (IPv4 & IPv6) are at the top. 

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

### server/osc-srv-live
check_img_in_pxe_cfg() from drbl-functions:999 eventually claims to be "Unable to find the image (local) label! Make sure the local label is labeled in /tftpboot/nbi_img/pxelinux.cfg/default! Program terminated"
So we added `cp /opt/default $pxecfg_pd/pxelinux.cfg/default` on the beginning of start_ocs_srv() in ocs-srv-live:40

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
Follow the steps below to update the Linux kernel. The linux Kernel is located in two locations. The first being in the live folder inside the USB drive that allows our servers to boot Clonezilla in secure mode. The second location is critical to our workflow and allows us to image computers without disabling secure boot. This copy of the Linux kernel is located inside of the squash filesystem. that is uncompressed into RAM during boot

Note: We cannot use a custom compiled kernel. This is because we do not want to disable secure boot for each computer that we want to image and the only way to accomplish this is to use a signed kernel + bootloader. We can only do this if we download a signed copy of the kernel which isn't modifiable.

* Download the latest Clonezilla Ubuntu AMD64 zip from [https://clonezilla.org/downloads.php](https://clonezilla.org/downloads.php)
* Unzip it: `uzip clonezilla-live-*.zip`
* `cd clonezilla-live-*`
Copy the following into server/secure-netboot:
* `cp live/vmlinuz /path/to/DigitalVAR/server/secure-netboot`
* `cp live/initrd.img /path/to/DigitalVAR/server/secure-netboot`
Then unsquash filesystem.squashfs to get the signed shim and grubnet bootloader
* `cd live`
* `sudo unsquashfs filesystem.squashfs`
Copy the following files into server/secure-netboot:
* `cp squashfs-root/usr/lib/shim/shimx64.efi.signed.latest /path/to/DigitalVAR/server/secure-netboot/shimx64.efi`
* `cp squashfs-root/usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed /path/to/DigitalVAR/server/secure-netboot/grubx64.efi`
Copy the firmware + device drivers folder into server/squashfs-root for filesystem.squashfs
* `rm -rf /path/to/DigitalVAR/server/squashfs-root/lib/modules/old-v.w.x-y-z`
* `rm -rf /path/to/DigitalVAR/server/squashfs-root/lib/firmware`
* `cp squashfs-root/lib/firmware /path/to/DigitalVAR/server/squashfs-root/lib`
* `cp squashfs-root/lib/modules/v.w.x-y-z /path/to/DigitalVAR/server/squashfs-root/lib/modules`
* Rebuild the server filesystem.squashfs: 
* `./rebuild.sh server`
Copy the following into the Clonezilla USB boot drive:
* `/path/to/latest/downloaded/clonezilla-zip/live/vmlinuz` -> /path/to/Clonezilla-USB/live
* `/path/to/latest/downloaded/clonezilla-zip/live/initrd.img` -> /path/to/Clonezilla-USB/live
* `/path/to/DigitalVAR/server/filesystem.squashfs` -> /path/to/Clonezilla-USB/live

### Deploying
Copy initrd.img, filesystem.squashfs, and vmlinuz to /path/to/CLONER SE/live
