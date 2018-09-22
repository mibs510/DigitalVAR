#!/bin/bash

if [ "${1}" != "7880" ] && [ "${1}" != "8500" ] && [ "${1}" != "8609" ] && [ "${1}" != "8610" ] && [ "${1}" != "8599" ]; then
	echo "ERROR: Invalid arguments"
	echo "Example: ${0} 7880"
	echo "         ${0} [PART NUMBER]"
	echo ""
	echo "PART NUMBER:  7880, 8500, 8599, 8609, 8610"
	exit 1
fi

USB_LIST=""

for i in {b..z}; do
	if [ -b /dev/sd${i} ]; then
		USB_LIST=$USB_LIST"sd$i "
	fi
done

if [ -b /dev/sdaa ]; then
	USB_LIST=$USB_LIST"sdaa "
fi

if [ "${USB_LIST}" == "" ]; then
	echo "ERROR: No USB drives found to image?"
	exit 1
fi

echo "I will image the following drives: $USB_LIST"
echo ""
echo "Is this correct?"
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"

if [ "$(df -P /home/partimag | tail -1 | cut -d' ' -f1)" != "/dev/sda1" ]; then
	echo "Mounting /dev/sda1 onto /home/partimag"
	sudo mount /dev/sda1 /home/partimag
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
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
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
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
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
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
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
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
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
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
	exit 0
fi
