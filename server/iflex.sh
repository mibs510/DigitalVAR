#!/bin/bash

PARTIMAG=$(lsblk -o name,serial,label | grep -i partimag | cut -d' ' -f1 | sed "s/[^[:alnum:]-]//g" | sed 's/[0-9]*//g')
CLONER=$(lsblk -o name,serial,label | grep -i cloner | cut -d' ' -f1 | sed "s/[^[:alnum:]-]//g")
SSD_LIST=""
RED=`tput setaf 1`
GREEN=`tput setaf 2`
CYAN=`tput setaf 14`
NC=`tput sgr0`

# Check to see if partimag is connected
if [ "${PARTIMAG}" == "" ]; then
	echo "${RED}ERROR: Insert or connect partimag SSD/HDD!${NC}"
	exit 1
fi

# Check to see if CLONER USB is connected
if [ "${CLONER}" != "" ]; then
	echo "${RED}ERROR: Remove or disconnect CLONER USB!${NC}"
	exit 1
fi

# Mount partimag onto /home/partimag
if [ "$(df -P /home/partimag | tail -1 | cut -d' ' -f1)" != "/dev/${PARTIMAG}1" ]; then
	if [ -b /dev/${PARTIMAG}1 ]; then
		echo "Mounting /dev/${PARTIMAG}1 onto /home/partimag"
		sudo mount /dev/${PARTIMAG}1 /home/partimag
	fi
fi

# Grab a potential list of "images" by excluding files
ls -l /home/partimag | grep ^d | awk '{print $9}' > /tmp/list_of_images.txt

# Exit if no director(y/ies) found
if [ "$(ls -hal /tmp/list_of_images.txt | awk '{print $5}')" == "0" ]; then
	echo "${RED}ERROR: NO IMAGES AVAILABLE IN /home/partimag!${NC}"
	exit 1
fi

# Put list of valid clonezilla images into an array
i=0
while read line
do
	# Not all folders contain clonezilla images
	if [ -f "/home/partimag/${line}/Info-dmi.txt" ]; then
		AVAILABLE_IMGS[$i]="$line"
		i=$((i+1))
	fi
done < /tmp/list_of_images.txt

TOTAL_AVAILABLE_IMGS=$(expr ${i} - 1)
i=0

# List valid images
echo "================================================="
echo " Choose an image available from the list below: "
echo "================================================="
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

if [ ! -d /home/partimag/${CLONEZILLA_IMAGE} ]; then
	echo "${RED}ERROR: Image not found in /home/partimag!${NC}"
	exit 1
fi

# Look for all available drives to image. This only excludes partimag, so be careful!
for i in {a..z}; do
	if [ -b /dev/sd${i} ] && [ "sd${i}" != "${PARTIMAG}" ]; then
		SSD_LIST=$SSD_LIST"sd$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done

for i in {a..z}; do
	if [ -b /dev/sda${i} ] && [ "sda${i}" != "${PARTIMAG}" ]; then
		SSD_LIST=$SSD_LIST"sda$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done

for i in {a..z}; do
	if [ -b /dev/sdb${i} ] && [ "sdb${i}" != "${PARTIMAG}" ]; then
		DRIVES_TO_BE_IMAGED=$DRIVES_TO_BE_IMAGED"sdb$i "
		SSD_LIST+=("sdb$i")
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done


if [ "${SSD_LIST}" == "" ]; then
	echo "${RED}ERROR: No SSD drives found to image?${NC}"
	exit 1
fi

echo "I will image the following drives: $SSD_LIST"
echo "${RED}MAKE SURE NO OTHER DEVICES ARE CONNECTED! (e.g. Toshiba/WD Element HDD)${NC}"
echo ""
echo "Image name: ${CYAN}${CLONEZILLA_IMAGE}${NC}"
echo "Total # of drives: ${CYAN}${NUMBER_OF_DRIVES}${NC}"
echo ""
echo "Is this correct?"
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"

echo "==================================================================================================================================================================================================================="
echo "EXECUTING: sudo ocs-restore-mdisks -batch -p '-nogui -batch -p true -icds -t -iefi -j2 -j0 -scr' ${CLONEZILLA_IMAGE} ${SSD_LIST}"
echo "==================================================================================================================================================================================================================="
echo ""
echo ""
sudo ocs-restore-mdisks -batch -p "-e1 auto -e2 -c -r -icds -iefi -j2 -cmf -scr -p true" ${CLONEZILLA_IMAGE} ${SSD_LIST}
echo ""
echo "======================="
echo " UUID SHOULD ALL MATCH"
echo "======================="
echo ""
sync
sudo blkid | grep -v 'CLONER' | grep -v 'squashfs'
echo ""
echo "Image name: ${CYAN}${CLONEZILLA_IMAGE}${NC}"
echo "Total # of drives: ${CYAN}${NUMBER_OF_DRIVES}${NC}"
exit 0
