#!/bin/bash

if [ "${1}" == "--beast" ] || [ "${1}" == "beast" ]; then
	if [ "$(df -P beast/squashfs-root/dev | tail -1 | cut -d' ' -f1)" == "udev" ]; then
		echo "ERROR: Exit from chroot!!!"
		exit 1
	fi
	sudo cp beast/{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,usb.sh,xxhsum} beast/squashfs-root/usr/bin
	sudo chmod +x beast/squashfs-root/usr/bin/{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,usb.sh,xxhsum}
	sudo cp beast/{motd.txt,profile,rc.local,resolv.conf} beast/squashfs-root/etc
	sudo cp beast/interfaces beast/squashfs-root/etc/network
	sudo rm -rf beast/filesystem.squashfs && sudo mksquashfs beast/squashfs-root beast/filesystem.squashfs -b 1024k -comp xz -Xbcj x86 -e boot && \
	echo "NOTE: Copy filesystem.squashfs to CLONER/live"
	exit 0
fi

if [ "${1}" == "--beast-chroot" ] || [ "${1}" == "beast-chroot" ]; then
	sudo mount -B /dev beast/squashfs-root/dev
	sudo mount -B /tmp beast/squashfs-root/tmp
	sudo mount -B /proc beast/squashfs-root/proc
	sudo mount -B /sys beast/squashfs-root/sys
	sudo chroot beast/squashfs-root/
	sudo umount beast/squashfs-root/dev
	sudo umount beast/squashfs-root/tmp
	sudo umount beast/squashfs-root/proc
	sudo umount beast/squashfs-root/sys
	exit 0
fi

if [ "${1}" == "--server" ] || [ "${1}" == "server" ]; then
	if [ "$(df -P server/squashfs-root/dev | tail -1 | cut -d' ' -f1)" == "udev" ]; then
		echo "ERROR: Exit from chroot!!!"
		exit 1
	fi
	# Propigate kernel modules throughout everywhere
	echo "Propigating kernel modules everywhere..."
	sudo rm -rf server/squashfs-root/tftpboot/node_root/lib/modules/*
	sudo cp -a server/initrd-root/lib/modules/4.18.7 server/squashfs-root/tftpboot/node_root/lib/modules
	sudo rm -rf server/squashfs-root/usr/lib/modules/*
	sudo cp -a server/initrd-root/lib/modules/4.18.7 server/squashfs-root/usr/lib/modules
	#
	
	echo "Copying everything from 'server/' folder to where they belong..."
	sudo cp server/syncthing.service server/squashfs-root/usr/lib/systemd/user
	sudo cp server/{syncthing@.service,syncthing-resume.service} server/squashfs-root/lib/systemd/system
	sudo cp server/{thunar-volman.xml,thunar.xml,bookmarks} server/squashfs-root/opt
	sudo cp server/drbl-functions server/squashfs-root/usr/share/drbl/sbin
	sudo cp server/{ocs-live-netcfg,ifupdownsucks.sh,startafterifupdownsucks.sh,drbl-live} server/squashfs-root/usr/sbin
	sudo cp server/drbl-live-conf-X server/squashfs-root/usr/share/drbl/sbin/drbl-live-conf-X
	sudo cp server/Forcevideo-drbl-live server/squashfs-root/tftpboot/node_root/sbin
	sudo cp server/firstboot server/squashfs-root/tftpboot/node_root/etc/init.d
	sudo cp server/drblwp.png server/squashfs-root/tftpboot/nbi_img
	sudo cp server/interfaces server/squashfs-root/etc/network
	sudo cp server/{rc.local,hosts} server/squashfs-root/etc
	sudo cp server/{Super_Thunar.desktop,Clonezilla-server.desktop,syncthing.desktop} server/squashfs-root/usr/share/drbl/setup/files/misc/desktop-icons/drbl-live
	sudo cp server/syncthing.png server/squashfs-root/usr/share/icons/hicolor/64x64/apps
	sudo cp server/firstboot.default-DBN.drbl server/squashfs-root/usr/share/drbl/setup/files/DBN
	sudo cp server/desktop-wallpaper/* server/squashfs-root/usr/share/desktop-base/softwaves-theme/wallpaper/contents/images
	sudo cp -a server/desktop-background server/squashfs-root/etc/alternatives/desktop-background
	
	echo "Chmoding executables..."
	sudo chmod +x server/squashfs-root/usr/sbin/{ocs-live-netcfg,ifupdownsucks.sh,startafterifupdownsucks.sh,drbl-live}
	sudo chmod +x server/squashfs-root/usr/share/drbl/sbin/drbl-functions
	sudo chmod +x server/squashfs-root/usr/sbin/ocs-live-netcfg
	sudo chmod +x server/squashfs-root/usr/sbin/ifupdownsucks.sh
	sudo chmod +x server/squashfs-root/usr/share/drbl/sbin/drbl-live-conf-X
	sudo chmod +x server/squashfs-root/usr/share/drbl/setup/files/DBN/firstboot.default-DBN.drbl
	sudo chmod +x server/squashfs-root/tftpboot/node_root/etc/init.d/firstboot
	sudo chmod +x server/squashfs-root/tftpboot/node_root/sbin/Forcevideo-drbl-live
	
	echo "Rebuilding filesystem.squashfs..."
	sudo rm -rf server/filesystem.squashfs && sudo mksquashfs server/squashfs-root server/filesystem.squashfs -b 1024k -comp xz -Xbcj x86 -e boot && \
	echo "NOTE: Copy vmlinuz, initrd.img, and filesystem.squashfs to CLONER SE/live"
	exit 0
fi

if [ "${1}" == "--server-chroot" ] || [ "${1}" == "server-chroot" ]; then
	sudo mount -B /dev server/squashfs-root/dev
	sudo mount -B /tmp server/squashfs-root/tmp
	sudo mount -B /proc server/squashfs-root/proc
	sudo mount -B /sys server/squashfs-root/sys
	sudo chroot server/squashfs-root/
	sudo umount server/squashfs-root/dev
	sudo umount server/squashfs-root/tmp
	sudo umount server/squashfs-root/proc
	sudo umount server/squashfs-root/sys
	exit 0
fi

if [ "${1}" == "--test-initrd" ] || [ "${1}" == "test-initrd" ]; then
	sudo qemu-system-x86_64 \
    -monitor stdio \
    -soundhw ac97 \
    -machine accel=kvm \
    -m 1024 \
    -boot once=c,menu=on \
    -net nic,vlan=0 \
    -net user,vlan=0 \
    -kernel server/vmlinuz \
    -initrd server/initrd.img\
    -append 'debug boot=live union=overlay config \
    components nomodeset net.ifnames=0 nosplash noeject \
    netboot=nfs nfsroot=192.168.100.254:tftpboot/node_root/clonezilla-live \
    ocs_server="192.168.100.254" hostname=ocs-client \
    username=clonezilla systemd.unit=multi-user.target \
    drbl_live_noconfx stick-to-pxe-srv dhcp-vendor-id=DRBLClient \
    drbl_prerun1="mkdir -p /var/lib/live/clonezilla/ocs-live.d" \
    drbl_prerun2="grep -qsE ^sudo -i ocs-live-run-menu /home/clonezilla/.bash_profile || echo sudo -i ocs-live-run-menu >> /home/clonezilla/.bash_profile" \
    keyboard-layous=us locales=en_US.UTF-8 ocs_daemonon="ssh" \
    ocs_prerun="mount -t nfs 192.168.100.254:/home/partimag/" \
    ocs_live_run="ocs-sr -l en_US.UTF-8 --use-partclone --clone-hidden-data -p reboot -zip -i 2000 -scr savedisk 2018-09-02-05-img sda"' \
    -rtc base=localtime \
    -name "Clonezilla Live - PXE"
	
	exit 0
fi

if [ "${1}" == "--initrd" ] || [ "${1}" == "initrd" ]; then
	if [ ! -d server/initrd-root ]; then
		echo "First lets unpack the existing initrd.img"
		mkdir server/initrd-root
		cd server/initrd-root
		zcat ../initrd.img | cpio -idmv
		cd $OLDPWD
		exit 0
	fi
	
	sudo rm -rf server/initrd.img
	cd server/initrd-root
	# Strip kernel modules
	echo "Stripping kernel modules (only *.ko)..."
	sudo find lib/modules/*/ -iname "*.ko" -exec strip --strip-debug {} \;
	echo "Repacking initrd.img"
	sudo find . | sudo cpio --quiet -o -H newc | sudo gzip -9 > ../initrd.img
	cd $OLDPWD
	echo "Updated initrd.img"
	exit 0
fi

echo "ERROR: Wrong arguments or not enough arguments"
echo "Example: ${0} [OPTION]"
echo "OPTION:"
echo " --beast, beast                   - Rebuild for imaging beast"
echo " --beast-chroot, beast-chroot     - Chroot into beast's rootfs"
echo " --server, server                 - Rebuild for imaging servers"
echo " --server-chroot, server-chroot   - Chroot into server's rootfs"
echo " --test-initrd, test-initrd       - Test Clonezilla-Live initrd with qemu"
echo " --initrd, initrd                 - Rebuild initrd.img for Clonezilla-Live.initrd.img"
exit 1
