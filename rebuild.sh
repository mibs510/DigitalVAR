#!/bin/bash

if [ "${1}" == "--beast" ] || [ "${1}" == "beast" ]; then
	sudo cp beast/{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,xxhsum} beast/squashfs-root/usr/bin
	sudo chmod +x beast/squashfs-root/usr/bin/{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,xxhsum}
	sudo cp beast/{motd.txt,profile,rc.local} beast/squashfs-root/etc
	sudo cp beast/interfaces beast/squashfs-root/etc/network
	sudo rm -rf beast/filesystem.squashfs && sudo mksquashfs beast/squashfs-root beast/filesystem.squashfs -b 1024k -comp xz -Xbcj x86 -e boot
	exit 0
fi

if [ "${1}" == "--server" ] || [ "${1}" == "server" ]; then
	sudo cp server/drblwp.png server/squashfs-root/tftpboot/nbi_img

	sudo cp ./{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,xxhsum} squashfs-root/usr/bin
	sudo chmod +x squashfs-root/usr/bin/{bigbox,fluorchem,onthefly.sh,onthefly-ssd.sh,jesse.sh,xxhsum}
	sudo cp ./{motd.txt,profile} squashfs-root/etc
	sudo rm -rf filesystem.squashfs && sudo mksquashfs squashfs-root filesystem.squashfs -b 1024k -comp xz -Xbcj x86 -e boot
	exit 0
fi

if [ "${1}" == "--chroot" ] || [ "${1}" == "chroot" ]; then
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

echo "ERROR: Not enough arguments"
echo "Example: ${0} [OPTION]"
echo "OPTION:"
echo "			--beast, beast 		- Rebuild for imaging beast"
echo "			--server, server 	- Rebuild for imaging servers"
echo "			--chroot, chroot	- Chroot into server's rootfs"
exit 1
