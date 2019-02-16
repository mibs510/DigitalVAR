#!/bin/bash

DEBUG=false
SKIP_XXHSUM=false
SKIP_PULLOUTS=true

if [ "${1}" != "7880" ] && [ "${1}" != "8500" ] && [ "${1}" != "8609" ] && [ "${1}" != "8610" ] && [ "${1}" != "8599" ]; then
	echo "ERROR: Invalid arguments"
	echo "Example: ${0} 7880"
	echo "         ${0} [PART NUMBER]"
	echo ""
	echo "PART NUMBER:  7880, 8500, 8599, 8609, 8610"
	exit 1
fi


USB_LIST=""
declare -a BAD_BOYS

RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`


PARTIMAG=$(lsblk -o name,serial | grep 07013A | cut -d' ' -f1)
USB_LIST=""

for i in {a..z}; do
	if [ -b /dev/sd${i} ] && [ "sd${i}" != "${PARTIMAG}" ]; then
		USB_LIST=$USB_LIST"sd$i "
	fi
done

if [ -b /dev/sdaa ] && [ "sdaa" != "${PARTIMAG}" ]; then
	USB_LIST=$USB_LIST"sdaa"
fi

if [ "${USB_LIST}" == "" ]; then
	echo "ERROR: No USB drives found to QA?"
	exit 1
fi

#echo "I will check the following drives: $USB_LIST"
#echo ""
#echo "Is this correct?"
#echo "Press Ctrl+C to exit"
#read -p "Press Enter to continue"

# green7880
if [ "${1}" == "7880" ]; then
	XXHSUM_FILE="green7880"
fi

# yellow8500
if [ "${1}" == "8500" ]; then
	XXHSUM_FILE="yellow8500"
fi

# red8609
if [ "${1}" == "8609" ]; then
	XXHSUM_FILE="red8609"
fi

# blue8610
if [ "${1}" == "8610" ]; then
	XXHSUM_FILE="blue8610"
fi

# lightblue8599
if [ "${1}" == "8599" ]; then
	XXHSUM_FILE="lightblue8599"
fi

if [ "${DEBUG}" == "true" ]; then
	set -x
fi

if [ "${SKIP_XXHSUM}" == "false" ]; then
	for i in {a..z}; do
		EXIT=false
		if [ -b /dev/sd${i}1 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
			echo "mount: /dev/sd${i}"
			sudo mount /dev/sd${i}1 /mnt
		
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				echo ""
				echo "================================================================="
				echo "ERROR: /dev/sd${i}1 COULDN'T BE MOUNTED!!"
				echo "Adding /dev/sd${i} onto the bad list..."
				echo "================================================================="
				echo ""
				BAD_BOYS+=(sd${i})
			fi
		
			if [ "$EXIT" == "false" ]; then
				echo "xxhsum: /dev/sd${i}"
				sudo xxhsum -c /etc/${XXHSUM_FILE}.xxhsums &> /dev/null
			fi
			
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				echo "unmount: /dev/sd${i}"
				sudo umount /dev/sd${i}1
				echo ""
				echo "==========================================="
				echo "ERROR: /dev/sd${i} HAS XXHSUM MISMATCH(ES)"
				echo "Adding /dev/sd${i} onto the bad list..."
				echo "================================================================="
				echo ""
				BAD_BOYS+=(sd${i})
			fi
		
			if [ "$EXIT" == "false" ]; then
				echo "unmount: /dev/sd${i}"
				sudo umount /dev/sd${i}1
			fi
		fi
		if [ ! -b /dev/sd${i}1 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
			echo ""
			echo "================================================================="
			echo "ERROR: /dev/sd${i} DOES NOT HAVE ANY PARTITIONS"
			echo "Adding /dev/sd${i} onto the bad list..."
			echo "================================================================="
			echo ""
			BAD_BOYS+=(sd${i})
		fi
	done

	if [ -b /dev/sdaa1 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
		EXIT=false
		echo "mount: /dev/sdaa"
		sudo mount /dev/sdaa1 /mnt
		if [ "$?" != "0" ]; then
			echo ""
			echo "================================================================="
			echo "ERROR: /dev/sdaa1 COULDN'T BE MOUNTED!!"
			echo "Adding /dev/sd${i} onto the bad list..."
			echo "================================================================="
			echo ""
			BAD_BOYS+=(sd${i})
			EXIT=true
		fi
		
		if [ "$EXIT" == "false" ]; then
			echo "xxhsum: /dev/sdaa"
			sudo xxhsum -c /etc/${XXHSUM_FILE}.xxhsums &> /dev/null
		fi
		
		if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
			echo "unmount: /dev/sdaa"
			sudo umount /dev/sdaa1
			echo ""
			echo "========================================="
			echo "ERROR: /dev/sdaa HAS XXHSUM MISMATCH(ES)"
			echo "Adding /dev/sdaa onto the bad list..."
			echo "========================================="
			echo ""
			BAD_BOYS+=(sdaa)
		fi
	fi
	
	if [ ! -b /dev/sdaa1 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
		echo ""
		echo "================================================================="
		echo "ERROR: /dev/sd${i} DOES NOT HAVE ANY PARTITIONS"
		echo "Adding /dev/sd${i} onto the bad list..."
		echo "================================================================="
		echo ""
		BAD_BOYS+=(sd${i})
	fi
	
	echo ""
	echo "============================================"
	echo "Done xxhsumming files inside the USB drives."
	echo "============================================"
	echo ""
fi

if [ "${#BAD_BOYS[@]}" != "0" ]; then
	echo ""
	echo "========================================================"
	echo "The following list of drives were determined to be bad:"
	echo "========================================================"
	echo ""

	for i in "${BAD_BOYS[@]}"; do
		echo "${i}"
	done
fi

if [ "${SKIP_PULLOUTS}" == "false" ]; then

	echo ""
	echo "==========================================================="
	echo " Watching /dev as you remove each USB drive individually..."
	echo "==========================================================="
	echo ""
	
	inotifywait -m /dev -e delete |
		while read path action file; do
			# Are we done pulling out everyone?
			if [ "$(ls /dev/sd* 2>/dev/null | grep -vw "${PARTIMAG}" | grep -vw "${PARTIMAG}1" | wc -l)" == "0" ]; then
				echo "We're finished!"
				return
			fi
			
			# Possible ${file} input: sg1
			# Seen in Ubuntu 18.04		
			if [ "$(echo ${file} | grep "sd")" == "" ]; then
				return
			fi
			
			# Input: sdb or sdb1
			# Output: sdb
			CURRENT_DRIVE=$(echo ${file} | sed 's/1//g')
			
			i=$((i+1))
			
			if [ "$(echo ${file} | grep "1")" != "" ]; then
				echo "${GREEN}"
				echo " ${i}. THROW THIS DRIVE INTO THE GOOD PILE! (${path}/${file}1)"
				echo "${NC}"
			fi
			
			if [ "$(echo ${file} | grep "1")" == "" ] && [ "${LAST_DRIVE}" != "${CURRENT_DRIVE}" ]; then
				echo "${RED}"
				echo " ${i}. THROW THIS DRIVE INTO THE BAD PILE! (${path}/${file})"
				echo "${NC}"
			fi
			
			LAST_DRIVE=$(echo ${file} | sed 's/1//g')
		done
fi

if [ "${DEBUG}" == "true" ]; then
	set +x
fi
