#!/bin/bash

if [ "${1}" == "--beast" ] || [ "${1}" == "beast" ]; then
	sudo cp beast/{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,usb.sh,xxhsum} beast/squashfs-root/usr/bin
	sudo chmod +x beast/squashfs-root/usr/bin/{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,usb.sh,xxhsum}
	sudo cp beast/{motd.txt,profile,rc.local} beast/squashfs-root/etc
	sudo cp beast/interfaces beast/squashfs-root/etc/network
	sudo rm -rf beast/filesystem.squashfs && sudo mksquashfs beast/squashfs-root beast/filesystem.squashfs -b 1024k -comp xz -Xbcj x86 -e boot
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
	sudo cp server/drblwp.png server/squashfs-root/tftpboot/nbi_img
	sudo cp server/interfaces server/squashfs-root/etc/network
	sudo cp server/{rc.local,hosts} server/squashfs-root/etc
	sudo cp server/70-presistent-net.rules server/squashfs-root/etc/udev/rules.d
	
	sudo rm -rf server/filesystem.squashfs && sudo mksquashfs server/squashfs-root server/filesystem.squashfs -b 1024k -comp xz -Xbcj x86 -e boot
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

echo "ERROR: Wrong arguments or not enough arguments"
echo "Example: ${0} [OPTION]"
echo "OPTION:"
echo "			--beast, beast                 - Rebuild for imaging beast"
echo "          --beast-chroot, beast-chroot   - Chroot into beast's rootfs"
echo "			--server, server               - Rebuild for imaging servers"
echo "			--server-chroot, server-chroot - Chroot into server's rootfs"
exit 1
