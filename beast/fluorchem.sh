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

LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S).log
SED_LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S).sed
PDF_LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S).pdf
PNG_FILE=/tmp/012-914_xxhsum_$(date +%m_%d_%y_%H%M%S).png
LOCKED_PDF_LOG_FILE=/tmp/xxhsum_$(date +%m_%d_%y_%H%M%S)_locked.pdf

if [ "x${IMG}x" = "xx" ]; then
	IMG=fluorchem-mfg-master-2017-11-27
	LOG_FILE=/tmp/012-914_xxhsum_$(date +%m_%d_%y_%H%M%S).log
fi

if [ "$(mount | grep '/home/partimag')" == "" ]; then
	HDD=$(lsblk -o name,serial | grep 575857 | cut -d' ' -f1)
	if [ -b /dev/${HDD}1 ]; then
		sudo mount /dev/${HDD}1 /home/partimag
	fi
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

# sudo scp ${LOG_FILE} user@server1:/home/partimag/logs

# Convert txt file to DOS compatible CR/NL
# todos ${LOG_FILE}

# Convert ^M to \n
sudo sed -e "s/\r/\n/g" ${LOG_FILE} > ${SED_LOG_FILE}

clear

sudo cat ${SED_LOG_FILE}

# Take screenshot# Take screenshot
sudo fbgrab ${PNG_FILE}

# Create pdf from txt file
# sudo pandoc ${SED_LOG_FILE} -o ${PDF_LOG_FILE}

# Lock pdf to prevent tampering
# sudo pdftk ${PDF_LOG_FILE} output ${LOCKED_PDF_LOG_FILE} owner_pw "$(openssl rand -base64 32)" allow printing

# Transfer it to clonezilla server
sudo ftp-upload -h win10server -u logs ${PNG_FILE}

echo ""
echo ""
echo "=================================================================="
if [ "${IMG}" == "fluorchem-mfg-master-2017-11-27" ]; then
	echo " ${IMG} has a sum of ade06eeaf7bcad46"
fi
echo " LOGS OF IMAGED DRIVES ARE LOCATED IN ${LOG_FILE}"
echo " A COPY HAS BENT SCP'D ONTO server1"
echo "=================================================================="
echo ""
echo ""
echo "Press Ctrl+C to exit"
read -p "Press Enter to view ${LOG_FILE}"
sed -e "s/\r//g" ${LOG_FILE} | less

