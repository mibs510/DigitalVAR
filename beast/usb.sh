#!/bin/bash

trap ctrl_c INT

PARTIMAG=$(lsblk -o name,serial | grep S5VWNG0 | cut -d' ' -f1)
USB_LIST=""
RED=`tput setaf 1`
GREEN=`tput setaf 2`
CYAN=`tput setaf 14`
NC=`tput sgr0`

function ctrl_c(){
	echo "INFO: Trapped Ctrl-C"
	exit 1
}

# Check to see if patriot USB is connected
if [ "${PARTIMAG}" == "" ]; then
	echo "${RED}ERROR: SAMSUNG SSD is not connected to beast!${NC}"
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
ls -l *.img | awk '{print $9}' > /tmp/list_of_images.txt
cd ${OLDPWD}

# Exit if no director(y/ies) found
if [ "$(ls -hal /tmp/list_of_images.txt | awk '{print $5}')" == "0" ]; then
	echo "${RED}ERROR: NO IMAGES AVAILABLE IN /home/partimag!${NC}"
	exit 1
fi

# Put list of valid clonezilla images into an array
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

if [ ${number} -lt 0 ] || [ ${number} -gt ${TOTAL_AVAILABLE_IMGS} ]; then
	echo "${RED}ERROR: Invalid image number!${NC}"
	exit 1
fi

CLONEZILLA_IMAGE=${AVAILABLE_IMGS[${number}]}

if [ ! -d /home/partimag/${CLONEZILLA_IMAGE} ]; then
	echo "${RED}ERROR: Image not found in /home/partimag!${NC}"
	exit 1
fi

IMG_SIZE=$(ls -hal | ${CLONEZILLA_IMAGE} | awk '{print $5}')

if [ ${IMG_SIZE} == "0" ]; then
	echo "${RED}ERROR: Image has a size of 0?${NC}"
	exit 1
fi

# Look for all available drives to image. This only excludes  partimag, so be careful!
for i in {a..z}; do
	if [ -b /dev/sd${i} ] && [ "sd${i}" != "${PARTIMAG}" ]; then
		USB_LIST=$USB_LIST"sd$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done

for i in {a..z}; do
	if [ -b /dev/sda${i} ] && [ "sda${i}" != "${PARTIMAG}" ]; then
		USB_LIST=$USB_LIST"sda$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done

for i in {a..z}; do
	if [ -b /dev/sdb${i} ] && [ "sdb${i}" != "${PARTIMAG}" ]; then
		USB_LIST=$USB_LIST"sdb$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done


if [ "${USB_LIST}" == "" ]; then
	echo "${RED}ERROR: No USB drives found to image?${NC}"
	exit 1
fi

echo "The following drives will be imaged: ${USB_LIST}"
echo "${RED}MAKE SURE NO OTHER USB DEVICES ARE CONNECTED! (e.g. Toshiba/WD Element HDD)${NC}"
echo ""
echo "Image name: ${CYAN}${CLONEZILLA_IMAGE}${NC}"
echo "Total # of drives: ${CYAN}${NUMBER_OF_DRIVES}${NC}"
echo ""
echo "Is this correct?"
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"

for USB in "${USB_LIST[@]}"
do
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo dd if=/home/partimag/${CLONEZILLA_IMAGE} | pv -s ${IMG_SIZE} | dd of=/dev/${USB}"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	sudo dd if=/home/partimag/${CLONEZILLA_IMAGE} | pv -s ${IMG_SIZE} | dd of=/dev/${USB}
	echo ""
	echo ""
done

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
