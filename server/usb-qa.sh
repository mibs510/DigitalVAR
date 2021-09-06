#!/bin/bash

DEBUG=false
SKIP_XXHSUM=false
SKIP_PULLOUTS=false

PARTIMAG=$(lsblk -o name,serial,label | grep -i partimag | cut -d' ' -f1 | sed "s/[^[:alnum:]-]//g" | sed 's/[0-9]*//g')
USB_LIST=""
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`

j=1
declare -a BAD_BOYS

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

if [ "${USB_LIST}" == "" ]; then
	echo "${RED}ERROR${NC}: No USB drives found to QA?"
	exit 1
fi

# Grab a potential list of "images" by excluding files
ls /home/partimag | grep .xxhsums > /tmp/list_of_xxhsums.txt

# Exit if no .xxhsums files found
if [ "$(ls -hal /tmp/list_of_xxhsums.txt | awk '{print $5}')" == "0" ]; then
	echo "${RED}ERROR: NO .xxhsums FOUND IN /home/partimag!${NC}"
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
	echo "${RED}ERROR: Invalid hash number!${NC}"
	exit 1
fi

XXHSUM_FILE=${AVAILABLE_XXHSUMS[${number}]}


if [ "${DEBUG}" == "true" ]; then
	set -x
fi

if [ ! -f /home/partimag/${XXHSUM_FILE} ]; then
	echo "${RED}ERROR: /home/partimag/${XXHSUM_FILE} DOES NOT EXIST!"
	echo "This part number may not be supported at the time.${NC}"
	exit 1
fi

if [ "${SKIP_XXHSUM}" == "false" ]; then
	for i in {a..z}; do
		EXIT=false
		if [ -b /dev/sd${i}1 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
			echo "mount: /dev/sd${i}"
			sudo mount /dev/sd${i}1 /mnt
		
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				echo "${RED}"
				echo "================================================================="
				echo "ERROR: /dev/sd${i}1 COULDN'T BE MOUNTED!!"
				echo "Adding /dev/sd${i} onto the bad list..."
				echo "================================================================="
				echo "${NC}"
				BAD_BOYS+=(sd${i})
			fi
		
			if [ "$EXIT" == "false" ]; then
				echo "xxhsum: /dev/sd${i}"
				sudo xxhsum -c /home/partimag/${XXHSUM_FILE} &> /dev/null
			fi
			
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				echo "unmount: /dev/sd${i}"
				sudo umount /dev/sd${i}1
				echo "${RED}"
				echo "==========================================="
				echo "ERROR: /dev/sd${i} HAS XXHSUM MISMATCH(ES)"
				echo "Adding /dev/sd${i} onto the bad list..."
				echo "==========================================="
				echo "${NC}"
				BAD_BOYS+=(sd${i})
			fi
		
			if [ "$EXIT" == "false" ]; then
				echo "unmount: /dev/sd${i}"
				sudo umount /dev/sd${i}1
			fi
		fi
		if [ -b /dev/sd${i} ] && [ ! -b /dev/sd${i}1 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
			echo "${RED}"
			echo "================================================================="
			echo "ERROR: /dev/sd${i} DOES NOT HAVE ANY PARTITIONS"
			echo "Adding /dev/sd${i} onto the bad list..."
			echo "================================================================="
			echo "${NC}"
			BAD_BOYS+=(sd${i})
		fi
	done
	
	umount /mnt &> /dev/null

	for i in {a..z}; do
		EXIT=false
		if [ -b /dev/sda${i}1 ] && [ "sda${i}" != "${PARTIMAG}" ]; then
			echo "mount: /dev/sda${i}"
			sudo mount /dev/sda${i}1 /mnt
		
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				echo "${RED}"
				echo "================================================================="
				echo "ERROR: /dev/sda${i}1 COULDN'T BE MOUNTED!!"
				echo "Adding /dev/sda${i} onto the bad list..."
				echo "================================================================="
				echo "${NC}"
				BAD_BOYS+=(sda${i})
			fi
		
			if [ "$EXIT" == "false" ]; then
				echo "xxhsum: /dev/sda${i}"
				sudo xxhsum -c /home/partimag/${XXHSUM_FILE} &> /dev/null
			fi
			
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				echo "unmount: /dev/sda${i}"
				sudo umount /dev/sda${i}1
				echo "${RED}"
				echo "==========================================="
				echo "ERROR: /dev/sda${i} HAS XXHSUM MISMATCH(ES)"
				echo "Adding /dev/sda${i} onto the bad list..."
				echo "==========================================="
				echo "${NC}"
				BAD_BOYS+=(sda${i})
			fi
		
			if [ "$EXIT" == "false" ]; then
				echo "unmount: /dev/sda${i}"
				sudo umount /dev/sda${i}1
			fi
		fi
		if [ -b /dev/sda${i} ] && [ ! -b /dev/sda${i}1 ] && [ "sda${i}" != "${PARTIMAG}" ]; then
			echo "${RED}"
			echo "================================================================="
			echo "ERROR: /dev/sda${i} DOES NOT HAVE ANY PARTITIONS"
			echo "Adding /dev/sda${i} onto the bad list..."
			echo "================================================================="
			echo "${NC}"
			BAD_BOYS+=(sda${i})
		fi
	done
	
	echo ""
	echo "========================================="
	echo "Done xxhsumming files inside USB drives."
	echo "========================================="
	echo ""
fi

umount /mnt &> /dev/null

if [ "${#BAD_BOYS[@]}" != "0" ]; then
	echo ""
	echo "========================================================"
	echo "The following list of drives are determined to be ${RED}BAD${NC}:"
	echo "========================================================"
	echo ""

	for i in "${BAD_BOYS[@]}"; do
		echo "* ${i}"
	done
	echo ""
	echo ""
fi

if [ "${#BAD_BOYS[@]}" == "0" ]; then
	echo ""
	echo "========================================================"
	echo "${GREEN}All drives passed checksum QA!${NC}:"
	echo "========================================================"
	echo ""
	echo ""
fi

if [ "${SKIP_PULLOUTS}" == "false" ]; then
	
	echo "Checksum filename: ${XXHSUM_FILE}"
	echo "Total # of drives: ${NUMBER_OF_DRIVES}"
	echo ""
	echo ""
	echo "==========================================================="
	echo " Watching /dev as you remove each USB drive individually..."
	echo " Press Ctrl + C when you're finished to exit"
	echo "==========================================================="
	echo ""
	
	inotifywait -m /dev -e delete |
		while read path action file; do
			IGNORE=false
			
			# Possible ${file} input: sg1
			# Seen in Ubuntu 18.04		
			if [ "$(echo ${file} | grep "sd")" == "" ]; then
				IGNORE=true
			fi
			
			# Input: sdb or sdb1
			# Ignore: sd*1
			if [[ ${file} == sd*1 ]]; then
				IGNORE=true
			fi
			
			if [ "${IGNORE}" == "false" ]; then
				BAD=false
			
				for i in "${BAD_BOYS[@]}"; do
					if [ "${file}" == "${i}" ]; then
						echo "${RED}"
						echo "${j}. BAD USB DRIVE!!!"
						echo "${NC}"
						BAD=true
						j=$((j+1))
					fi
				done
			
				if [ "${BAD}" == "false" ]; then
					echo "${GREEN}"
					echo "${j}. GOOD USB DRIVE!!!"
					echo "${NC}"
					j=$((j+1))			
				fi
			fi
			

		done
fi

if [ "${DEBUG}" == "true" ]; then
	set +x
fi
