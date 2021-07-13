#!/bin/bash

# Written by: Connor McMillan

if [ $# -lt 1 ]; then
	echo "ERROR: Not enough arguments."
	echo "${0} [target] [target] [target] [target] ..."
	echo "Example: ${0} a b c d e f g h i j k l"
	echo "Example: IMG=company_part#_version ${0} a b c d"
	echo "IMG=fluorchem-mfg-master-2017-11-27 by default"
	echo "IMG must be located in /home/partimag"
	exit 1
fi

PARTIMAG=$(lsblk -o name,serial,label | grep -i partimag | cut -d' ' -f1 | sed "s/[^[:alnum:]-]//g")
CLONER=$(lsblk -o name,serial,label | grep -i cloner | cut -d' ' -f1 | sed "s/[^[:alnum:]-]//g")
LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S).log
SED_LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S).sed
PDF_LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S).pdf
PNG_FILE=/tmp/012-914_xxhsum_$(date +%m_%d_%y_%H%M%S).png
LOCKED_PDF_LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S)_locked.pdf

if [ "x${IMG}x" = "xx" ]; then
	IMG=fluorchem-mfg-master-2017-11-27
	LOG_FILE=/tmp/012-914_xxhsum_$(date +%m_%d_%y_%H%M%S).log
fi

# Check to see if partimag is connected
if [ "${PARTIMAG}" == "" ]; then
	echo "${RED}ERROR: Insert or connect partimag SSD/HDD!${NC}"
	exit 1
fi

# Mount partimag onto /home/partimag
if [ "$(df -P /home/partimag | tail -1 | cut -d' ' -f1)" != "/dev/${PARTIMAG}" ]; then
	echo "Mounting /dev/${PARTIMAG} onto /home/partimag"
	sudo mount /dev/${PARTIMAG} /home/partimag
fi

# Check to see if CLONER USB is connected
if [ "${CLONER}" != "" ]; then
	echo "${RED}ERROR: Remove or disconnect CLONER USB!${NC}"
	exit 1
fi

if [ ! -f "/home/partimag/${IMG}" ]; then
	echo "ERROR: /home/partimg/${IMG} does not exist!!"
	exit 1
fi

echo ""
echo ""
echo "=================================================================="
echo " THE FOLLOWING DRIVES WILL BE IMAGED!!"
echo " BE SURE /home/partimag/${IMG} IS YOUR MASTER!!"
echo "=================================================================="
echo ""
echo ""

for i in "${@:1}"; do
	lsblk -o name,serial | grep -w sd${i}
done

echo ""
echo ""
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"


for i in "${@:1}"; do
	echo ""
	echo ""
	echo "=========================================================================================================="
	echo "EXECUTING: sudo sh <<< \"dd if=/home/partimag/${IMG} | pv | dd of=/dev/sd${i}\""
	echo "=========================================================================================================="
	echo ""
	echo ""
	sudo sh <<< "dd if=/home/partimag/${IMG} | pv | dd of=/dev/sd${i}"
	echo "xxhsum: /dev/sd${i} in the background"
	sudo xxhsum /dev/sd${i} &>> ${LOG_FILE} &
done

while [ "$(pidof xxhsum)" != "" ]
do
	sleep 10
done

echo "" >> ${LOG_FILE}
echo "" >> ${LOG_FILE}

for i in "${@:1}"; do
	lsblk -o name,serial | grep -w sd${i} >> ${LOG_FILE}
done

echo ""
echo ""
echo "=================================================================="
if [ "${IMG}" == "fluorchem-mfg-master-2017-11-27" ]; then
	echo " ${IMG} has a sum of ade06eeaf7bcad46"
fi
echo " PROOF OF IMAGED DRIVES WILL BE UPLOADED"
echo "=================================================================="
echo ""
echo ""
read -p "Press Enter to upload proof & view ${LOG_FILE}"
## Proof
clear
sudo cat ${LOG_FILE}
# Take screenshot# Take screenshot
sudo scrot ${PNG_FILE}
# Transfer it to clonezilla server
sudo ftp-upload -h win10server -u logs ${PNG_FILE}
## View log file
clear
sed -e "s/\r//g" ${LOG_FILE} | less

