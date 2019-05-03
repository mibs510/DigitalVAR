#!/bin/bash

DEBUG=false
SKIP_XXHSUM=false
SKIP_PULLOUTS=false

if [ "${1}" != "7880" ] && [ "${1}" != "8500" ] && [ "${1}" != "8609" ] && [ "${1}" != "8610" ] && [ "${1}" != "8599" ]; then
	echo "${RED}ERROR${NC}: Invalid arguments"
	echo "Example: ${0} 7880"
	echo "         ${0} [PART NUMBER]"
	echo ""
	echo "PART NUMBER:  7880, 8500, 8599, 8609, 8610"
	exit 1
fi

j=1
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
	echo "${RED}ERROR${NC}: No USB drives found to QA?"
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

if [ ! -f /etc/${XXHSUM_FILE}.xxhsums ]; then
	echo "ERROR: /etc/${XXHSUM_FILE}.xxhsums DOES NOT EXIST!"
	echo "This part number may not be supported at the time"
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
				echo "==========================================="
				echo ""
				BAD_BOYS+=(sd${i})
			fi
		
			if [ "$EXIT" == "false" ]; then
				echo "unmount: /dev/sd${i}"
				sudo umount /dev/sd${i}1
			fi
		fi
		if [ -b /dev/sd${i} ] && [ ! -b /dev/sd${i}1 ] && [ "sd${i}" != "${PARTIMAG}" ]; then
			echo ""
			echo "================================================================="
			echo "ERROR: /dev/sd${i} DOES NOT HAVE ANY PARTITIONS"
			echo "Adding /dev/sd${i} onto the bad list..."
			echo "================================================================="
			echo ""
			BAD_BOYS+=(sd${i})
		fi
	done

	if [ -b /dev/sdaa1 ] && [ "sdaa" != "${PARTIMAG}" ]; then
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
	
	if [  -b /dev/sdaa ] && [ ! -b /dev/sdaa1 ] && [ "sdaa" != "${PARTIMAG}" ]; then
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
	echo "The following list of drives are determined to be ${RED}BAD${NC}:"
	echo "========================================================"
	echo ""

	for i in "${BAD_BOYS[@]}"; do
		echo "* ${i}"
	done
	echo ""
	echo ""
fi

if [ "${SKIP_PULLOUTS}" == "false" ]; then

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
