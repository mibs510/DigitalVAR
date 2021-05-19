#!/bin/bash

# Written by: Connor McMillan (connor@mcmillan.website)

trap ctrl_c INT

PARTIMAG=$(lsblk -o name,serial | grep 3208LH | cut -d' ' -f1)
USB_LIST=()
DRIVES_TO_BE_IMAGED=""
RED=`tput setaf 1`
GREEN=`tput setaf 2`
CYAN=`tput setaf 14`
NC=`tput sgr0`

if [ $(whoami) != "root" ]; then
	echo "${RED}ERROR: ${0} must be ran as root!${NC}"
	exit 1
fi

if [ $# -lt 1 ]; then
	echo "${RED}ERROR: Not enough arguments.${NC}"
	echo "${0} [target] [target] [target] [target] ..."
	echo "/dev/sd[target]"
	echo "Example: ${0} a b c d e f g h i j k l"
	echo "Example: ${0} q r s t x z aa ab ac ba bf"
	exit 1
fi

if [ $# -gt 10 ]; then
	echo "WARN: Not recommended to image more than ten (10) USB drives in series."
	echo "Run the script in multiple instances in Alt-F1 through F6!"
	echo "${0} [target] [target] [target] [target] ..."
	echo "/dev/sd[target]"
	echo "Example: ${0} a b c d e f g h i j k l"
	echo "Example: ${0} q r s t x z aa ab ac ba bf"
	exit 1
fi

function ctrl_c(){
	echo ""
	echo "INFO: Trapped Ctrl-C"
	exit 1
}

# Count how many drives we are imaging.
for TARGET in "${@:1}"; do
	# Let's check if the user is trying to image the device holding the images.
	if [ "sd${TARGET}" == "${PARTIMAG}" ]; then
		echo "${RED}ERROR: WHY ARE YOU TRYING TO IMAGE THE DEVICE THAT HOLDS ALL IMAGES!?!${NC}"
		exit 1
	fi
	NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
done

# Check to see if patriot USB is connected
if [ "${PARTIMAG}" == "" ]; then
	echo "${RED}ERROR: Intel SSD is not connected to beast!${NC}"
	exit 1
fi

# Check to see if Western Digital Elements HDD is connected
if [ "$(lsblk -o name,serial | grep 575857 | cut -d' ' -f1)" != "" ]; then
	echo "${RED}ERROR: WD Elements drive is connected!${NC}"
	exit 1
fi

# Check to see if CLONER USB is connected
if [ "$(lsblk -o name,serial | grep 07013A | cut -d' ' -f1)" != "" ]; then
	echo "${RED}ERROR: CLONER USB is connected!${NC}"
	exit 1
fi

# Mount "partimag" from  SAMSUNG SSD onto /home/partimag
if [ "$(df -P /home/partimag | tail -1 | cut -d' ' -f1)" != "/dev/${PARTIMAG}1" ]; then
	echo "Mounting /dev/${PARTIMAG}1 onto /home/partimag"
	sudo mount /dev/${PARTIMAG}1 /home/partimag
fi

# Grab a potential list of "images" by excluding files
cd /home/partimag
sudo ls -l *.img | awk '{print $9}' > /tmp/list_of_images.txt
cd ${OLDPWD}

# Exit if no director(y/ies) found
if [ "$(ls -hal /tmp/list_of_images.txt | awk '{print $5}')" == "0" ]; then
	echo "${RED}ERROR: NO IMAGES AVAILABLE IN /home/partimag!${NC}"
	exit 1
fi

# Put list of valid images into an array
i=0
while read line
do
	AVAILABLE_IMGS[$i]="$line"
	i=$((i+1))
done < /tmp/list_of_images.txt

TOTAL_AVAILABLE_IMGS=$(expr ${i} - 1)
i=0

# List valid images
echo "================================================"
echo " Choose an image available from the list below: "
echo "================================================"
echo ""
for i in $(seq 0 ${TOTAL_AVAILABLE_IMGS}); do 
	echo "${i} = ${AVAILABLE_IMGS[$i]}"
done
echo ""
read -p "Enter the image #> " number
echo ""

if ! [[ "${number}" =~ ^[0-9]+$ ]]; then
	echo "${RED}ERROR: Invalid image number!${NC}"
	exit 1
fi

CLONEZILLA_IMAGE=${AVAILABLE_IMGS[${number}]}

if [ ! -e /home/partimag/${CLONEZILLA_IMAGE} ]; then
	echo "${RED}ERROR: Image not found in /home/partimag!${NC}"
	exit 1
fi

echo "The following drives will be imaged: ${DRIVES_TO_BE_IMAGED}"
for TARGET in "${@:1}"; do
	lsblk -o name,serial | grep -w sd${TARGET}
done
echo "${RED}MAKE SURE NO OTHER USB DEVICES ARE CONNECTED! (e.g. Toshiba/WD Element HDD)${NC}"
echo ""
echo "Image name: ${CYAN}${CLONEZILLA_IMAGE}${NC}"
echo "Total # of drives: ${CYAN}${NUMBER_OF_DRIVES}${NC}"
echo ""
echo "Is this correct?"
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"

for TARGET in "${@:1}"; do
	echo "=========================================================================================="
	echo "| EXECUTING: sudo pv -q < /home/partimag/${CLONEZILLA_IMAGE} > /dev/sd${TARGET}|"
	echo "=========================================================================================="
	echo ""
	echo ""
	sudo pv -f < /home/partimag/${CLONEZILLA_IMAGE} > /dev/sd${TARGET}
	echo ""
	echo ""
done

echo "Informing the kernel of new partitions so that usb-qa.sh doesn't fail to mount partitions."
partprobe

echo ""
echo "======================="
echo " UUID SHOULD ALL MATCH"
echo "======================="
echo ""
sync
sudo blkid | grep -v 'CLONER' | grep -v 'partimag' | grep -v 'PARTIMAG' | grep -v 'squashfs'
echo ""
echo "Image name: ${CYAN}${CLONEZILLA_IMAGE}${NC}"
echo "Total # of drives: ${CYAN}${NUMBER_OF_DRIVES}${NC}"
exit 0
