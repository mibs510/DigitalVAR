#!/bin/bash

DEBUG=false
SKIP_XXHSUM=false
SKIP_PULLOUTS=false

PARTIMAG=$(lsblk -o name,serial,label | grep -i partimag | cut -d' ' -f1 | sed "s/[^[:alnum:]-]//g" | sed 's/[0-9]*//g')
PNG_FILE=/tmp/89-21054-00-001_$(date +%m_%d_%y_%H%M%S).png
LOG_FILE=/tmp/89-21054-00-001_$(date +%m_%d_%y_%H%M%S).log
SSD_LIST=""
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`

j=1

# Check to see if patriot USB is connected
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
		SSD_LIST=$SSD_LIST"sdb$i "
		NUMBER_OF_DRIVES=$((NUMBER_OF_DRIVES+1))
	fi
done

if [ "${SSD_LIST}" == "" ]; then
	echo "${RED}ERROR${NC}: No SSD drives found to QA?"
	exit 1
fi

# Grab a potential list of "images" by excluding files
ls /home/partimag | grep .xxhsums | sed 's/.xxhsums//' > /tmp/list_of_xxhsums.txt

# Exit if no .xxhsums files found
if [ "$(ls -hal /tmp/list_of_xxhsums.txt | awk '{print $5}')" == "0" ]; then
	echo "${RED}ERROR: NO SUM FILES FOUND IN /home/partimag!${NC}"
	exit 1
fi

# Put list of valid .xxhsums files into an array
i=0
while read line
do
	AVAILABLE_XXHSUMS[$i]="$line"
	i=$((i+1))
done < /tmp/list_of_xxhsums.txt

TOTAL_AVAILABLE_XXHSUMS=$(expr ${i} - 1)
i=0

# List .xxhsums files
echo "=================================================="
echo " Choose a hash file available from the list below: "
echo "=================================================="
echo ""
for i in $(seq 0 ${TOTAL_AVAILABLE_XXHSUMS}); do 
	echo "${i} = ${AVAILABLE_XXHSUMS[$i]}"
done
echo ""
read -p "Enter the hash file #> " number
echo ""

if ! [[ "${number}" =~ ^[0-9]+$ ]]; then
	echo "${RED}ERROR: Invalid hash file number!${NC}"
	exit 1
fi

XXHSUM_FILE=${AVAILABLE_XXHSUMS[${number}]}.xxhsums


if [ "${DEBUG}" == "true" ]; then
	set -x
fi

if [ ! -f /home/partimag/${XXHSUM_FILE} ]; then
	echo "${RED}ERROR: /home/partimag/${XXHSUM_FILE} DOES NOT EXIST!"
	echo "This part number may not be supported at the time.${NC}"
	exit 1
fi

echo "Device Block Name,Model,Serial Number,File Qty,MD5SUM Result" >> ${LOG_FILE}

if [ "${SKIP_XXHSUM}" == "false" ]; then
	for i in {a..z}; do
		EXIT=false
		KNAME="sd${i}"
		MODEL="$(lsblk -o kname,model | grep -w sd${i} | awk -F '   ' '{print $2}')"
		SERIALNUM="$(lsblk -o kname,serial | grep -w sd${i} | awk -F '   ' '{print $2}')"
		FILE_QTY="NA"
		QA_FLAG="${GREEN}PASSED${NC}"
		
		if [ -b /dev/sd${i}4 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
			echo "Checking sd${i}..."
			sudo mount /dev/sd${i}4 /mnt
		
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				QA_FLAG="${RED}FAILED${NC}"			
			fi
			
			if [ "$EXIT" == "false" ]; then
				FILE_QTY=$(find /mnt -type f | wc -l)
			fi
		
			if [ "$EXIT" == "false" ]; then
				sudo xxhsum -c /home/partimag/${XXHSUM_FILE} &> /dev/null
			fi
			
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				sudo umount /dev/sd${i}4
				QA_FLAG="${RED}FAILED${NC}"
			fi
			umount /mnt &> /dev/null
			echo "${KNAME},${MODEL},${SERIALNUM},${FILE_QTY},${QA_FLAG}" >> ${LOG_FILE}
		
		fi
		if [ -b /dev/sd${i} ] && [ ! -b /dev/sd${i}4 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
			QA_FLAG="${RED}FAILED${NC}"
			echo "${KNAME},${MODEL},${SERIALNUM},${FILE_QTY},${QA_FLAG}" >> ${LOG_FILE}
		fi
		
	done
	
	umount /mnt &> /dev/null

fi

umount /mnt &> /dev/null
clear
cat ${LOG_FILE} | column -c 78 -t -s ","
# Take screenshot# Take screenshot
sudo scrot ${PNG_FILE}
# Transfer it to clonezilla server
sudo ftp-upload -h win10server.digital.var -u logs ${PNG_FILE}


if [ "${DEBUG}" == "true" ]; then
	set +x
fi
