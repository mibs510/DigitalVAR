#!/bin/bash

DEBUG=false
SKIP_XXHSUM=false
SKIP_PULLOUTS=false

if [ "${1}" != "7880" ] && [ "${1}" != "8500" ] && [ "${1}" != "8609" ] && [ "${1}" != "8610" ] && [ "${1}" != "8599" ]; then
	echo "ERROR: Invalid arguments"
	echo "Example: ${0} 7880"
	echo "         ${0} [PART NUMBER]"
	echo ""
	echo "PART NUMBER:  7880, 8500, 8599, 8609, 8610"
	exit 1
fi

WAIT_FOR_DD=5
i=0

USB_LIST=""

RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`


for i in {b..z}; do
	if [ -b /dev/sd${i} ]; then
		USB_LIST=$USB_LIST"sd$i "
	fi
done

if [ -b /dev/sdaa ]; then
	USB_LIST=$USB_LIST"sdaa "
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
	for i in {b..z}; do
		EXIT=false
		if [ -b /dev/sd${i}1 ]; then
			sudo mount /dev/sd${i}1 /mnt
		
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				echo ""
				echo "================================================================="
				echo "ERROR: /dev/sd${i}1 COULDN'T BE MOUNTED!!"
				echo "Making /dev/sd${i} flash rapidly..."
				echo "Pull drive out of USB hub!"
				echo "================================================================="
				echo ""
				(sudo dd if=/dev/zero of=/dev/sd${i} &) > /dev/null 2>&1
				sleep ${WAIT_FOR_DD}
				while [ "$(pidof dd)" != "" ]
				do
					sleep 1
				done
			fi
		
			if [ "$EXIT" == "false" ]; then
				sudo xxhsum -c /etc/${XXHSUM_FILE}.xxhsums &> /dev/null
			fi
			
			if [ "$?" != "0" ] && [ "$EXIT" == "false" ]; then
				EXIT=true
				sudo umount /dev/sd${i}1
				echo ""
				echo "==========================================="
				echo "ERROR: /dev/sd${i} HAS XXHSUM MISMATCH(ES)"
				echo "Making /dev/sd${i} flash rapidly..."
				echo "Pull drive out of USB hub!"
				echo "==========================================="
				echo ""
				(sudo dd if=/dev/zero of=/dev/sd${i} &) > /dev/null 2>&1
				sleep ${WAIT_FOR_DD}
				while [ "$(pidof dd)" != "" ]
				do
					sleep 1
				done
			fi
		
			if [ "$EXIT" == "false" ]; then
				sudo umount /dev/sd${i}1
			fi
		fi
	done

	if [ -b /dev/sdaa1 ]; then
	
		if [ "$?" != "0" ]; then
			echo ""
			echo "================================================================="
			echo "ERROR: /dev/sdaa1 COULDN'T BE MOUNTED!!"
			echo "Making /dev/sdaa flash rapidly..."
			echo "Pull drive out of USB hub!"
			echo "================================================================="
			echo ""
			(sudo dd if=/dev/zero of=/dev/sdaa &) > /dev/null 2>&1
			sleep ${WAIT_FOR_DD}
			while [ "$(pidof dd)" != "" ]
			do
				sleep 1
			done
		fi
	
		sudo xxhsum -c /etc/${XXHSUM_FILE}.xxhsums &> /dev/null
		if [ "$?" != "0" ]; then
			sudo umount /dev/sdaa1
			echo ""
			echo "========================================="
			echo "ERROR: /dev/sdaa HAS XXHSUM MISMATCH(ES)"
			echo "Making /dev/sdaa flash rapidly..."
			echo "Pull drive out of USB hub!"
			echo "========================================="
			echo ""
			(sudo dd if=/dev/zero of=/dev/sdaa &) > /dev/null 2>&1
			sleep ${WAIT_FOR_DD}
			while [ "$(pidof dd)" != "" ]
			do
				sleep 1
			done
		fi
		sudo umount /dev/sdaa1
	fi
fi

if [ "${SKIP_PULLOUTS" == "false" ]; then
	# INITIAL_MAP
	ls /dev/sd* | grep -vw "sda" | grep -vw "sda1" > /tmp/first

	while [ "$(cat /tmp/current)" != "" ]
	do
		
		ls /dev/sd* | grep -vw "sda" | grep -vw "sda1" > /tmp/second
		DIFFERENCE="$(diff /tmp/first /tmp/second)"

		if [ "${DIFFERENCE}" != "" ]; then
		
			i=$((i+1))
			BAD_DRIVE=$(echo ${DIFFERENCE} | grep "<" | cut -d' ' -f2)
			GOOD_DRIVE=$(echo ${DIFFERENCE} | grep "1")
		
			if [ "${GOOD_DRIVE}" != "" ]; then
				echo "${GREEN}"
				echo " ${i}. THROW THIS DRIVE INTO THE GOOD PILE! (${GOOD_DRIVE})"
				echo "${NC}"
			else
				echo "${RED}"
				echo "THROW THIS DRIVE INTO THE BAD PILE! ${BAD_DRIVE}"
				echo "${NC}"
			fi
		fi
	
		ls /dev/sd* | grep -vw "sda" | grep -vw "sda1" > /tmp/first
	done
fi

if [ "${DEBUG}" == "true" ]; then
	set +x
fi
