#!/bin/bash

if [ "${1}" != "7880" ] && [ "${1}" != "8500" ] && [ "${1}" != "8609" ] && [ "${1}" != "8610" ] && [ "${1}" != "8599" ]; then
	echo "ERROR: Invalid arguments"
	echo "Example: ${0} 7880"
	echo "         ${0} [PART NUMBER]"
	echo ""
	echo "PART NUMBER:  7880, 8500, 8599, 8609, 8610"
	exit 1
fi

PARTIMAG=$(lsblk -o name,serial | grep 07013A | cut -d' ' -f1)
USB_LIST=""
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`

for i in {a..z}; do
	if [ -b /dev/sd${i} ] && [ "sd${i}" != "${PARTIMAG}" ]; then
		USB_LIST=$USB_LIST"sd$i "
	fi
done

if [ -b /dev/sdaa ] && [ "sdaa" != "${PARTIMAG}" ]; then
	USB_LIST=$USB_LIST"sdaa"
fi

if [ "${USB_LIST}" == "" ]; then
	echo "ERROR: No USB drives found to image?"
	exit 1
fi

echo "I will image the following drives: $USB_LIST"
echo "${RED}MAKE SURE NO OTHER USB DEVICES ARE CONNECTED! (e.g. Toshiba/WD Element HDD)${NC}"
echo ""
echo "Is this correct?"
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"

if [ "$(df -P /home/partimag | tail -1 | cut -d' ' -f1)" != "/dev/${PARTIMAG}1" ]; then
	echo "Mounting /dev/${PARTIMAG}1 onto /home/partimag"
	sudo mount /dev/${PARTIMAG}1 /home/partimag
fi

# green7880
if [ "${1}" == "7880" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' green7880 ${USB_LIST}"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' green7880 ${USB_LIST}
	echo ""
	echo "======================="
	echo " UUID SHOULD ALL MATCH"
	echo "======================="
	echo ""
	sync
	sudo blkid | grep -v 'CLONER' | grep -v 'squashfs'
	exit 0
fi

# yellow8500
if [ "${1}" == "8500" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' yellow8500 ${USB_LIST}"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' yellow8500 ${USB_LIST}
	echo ""
	echo "======================="
	echo " UUID SHOULD ALL MATCH"
	echo "======================="
	echo ""
	sync
	sudo blkid | grep -v 'CLONER' | grep -v 'squashfs'
	exit 0
fi

# red8609
if [ "${1}" == "8609" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' red8609 ${USB_LIST}"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' red8609 ${USB_LIST}
	echo ""
	echo "======================="
	echo " UUID SHOULD ALL MATCH"
	echo "======================="
	echo ""
	sync
	sudo blkid | grep -v 'CLONER' | grep -v 'squashfs'
	exit 0
fi

# blue8610
if [ "${1}" == "8610" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' blue8610 ${USB_LIST}"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' blue8610 ${USB_LIST}
	echo ""
	echo "======================="
	echo " UUID SHOULD ALL MATCH"
	echo "======================="
	echo ""
	sync
	sudo blkid | grep -v 'CLONER' | grep -v 'squashfs'
	exit 0
fi

# lightblue8599
if [ "${1}" == "8599" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' lightblue8599 ${USB_LIST}"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' lightblue8599 ${USB_LIST}
	echo ""
	echo "======================="
	echo " UUID SHOULD ALL MATCH"
	echo "======================="
	echo ""
	sync
	sudo blkid | grep -v 'CLONER' | grep -v 'squashfs'
	exit 0
fi
