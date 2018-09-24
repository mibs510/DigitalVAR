#!/bin/bash

if [ "${1}" != "7880" ] && [ "${1}" != "8500" ] && [ "${1}" != "8609" ] && [ "${1}" != "8610" ] && [ "${1}" != "8599" ]; then
	echo "ERROR: Invalid arguments"
	echo "Example: ${0} 7880"
	echo "         ${0} [PART NUMBER]"
	echo ""
	echo "PART NUMBER:  7880, 8500, 8599, 8609, 8610"
	exit 1
fi

USB_LIST=""

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
	XXHSUM_FILE="blue8610"
fi

for i in {b..z}; do
	if [ -b /dev/sd${i} ]; then
		if [ ! -b /dev/sd${i}1 ]; then
			echo ""
			echo "========================================================================="
			echo "ERROR: /dev/sd${i} DOESN'T HAVE A PROPERLY FORMATTED PRIMRARY PARTITION"
			echo "Making /dev/sd${i} flash rapidly..."
			echo "Pull drive out of USB hub!"
			echo "========================================================================="
			echo ""
			(sudo dd if=/dev/zero of=/dev/sd${i} &) > /dev/null 2>&1
			while [ "$(pidof dd)" != "" ]
			do
				sleep 1
			done
			break
		fi
		sudo mount /dev/sd${i}1 /mnt
		if [ "$?" != "0" ]; then
			echo ""
			echo "================================================================="
			echo "ERROR: /dev/sd${i}1 COULDN'T BE MOUNTED!!"
			echo "Making /dev/sd${i} flash rapidly..."
			echo "Pull drive out of USB hub!"
			echo "================================================================="
			echo ""
			(sudo dd if=/dev/zero of=/dev/sd${i} &) > /dev/null 2>&1
			while [ "$(pidof dd)" != "" ]
			do
				sleep 1
			done
			break
		fi
		sudo xxhsum -c /etc/${XXHSUM_FILE}.xxhsums &> /dev/null
		if [ "$?" != "0" ]; then
			sudo umount /dev/sd${i}1
			echo ""
			echo "==========================================="
			echo "ERROR: /dev/sd${i} HAS XXHSUM MISMATCH(ES)"
			echo "Making /dev/sd${i} flash rapidly..."
			echo "Pull drive out of USB hub!"
			echo "==========================================="
			echo ""
			(sudo dd if=/dev/zero of=/dev/sd${i} &) > /dev/null 2>&1
			while [ "$(pidof dd)" != "" ]
			do
				sleep 1
			done
			break
		fi
		sudo umount /dev/sd${i}1
	fi
done

if [ -b /dev/sdaa ]; then
	if [ ! -b /dev/sdaa1 ]; then
		echo ""
		echo "========================================================================="
		echo "ERROR: /dev/sdaa DOESN'T HAVE A PROPERLY FORMATTED PRIMRARY PARTITION"
		echo "Making /dev/sdaa flash rapidly..."
		echo "Pull drive out of USB hub!"
		echo "========================================================================="
		echo ""
		(sudo dd if=/dev/zero of=/dev/sdaa &) > /dev/null 2>&1
		while [ "$(pidof dd)" != "" ]
		do
			sleep 1
		done
		exit 1
	fi
	
	sudo mount /dev/sdaa1 /mnt
	
	if [ "$?" != "0" ]; then
		echo ""
		echo "================================================================="
		echo "ERROR: /dev/sdaa1 COULDN'T BE MOUNTED!!"
		echo "Making /dev/sdaa flash rapidly..."
		echo "Pull drive out of USB hub!"
		echo "================================================================="
		echo ""
		(sudo dd if=/dev/zero of=/dev/sdaa &) > /dev/null 2>&1
		while [ "$(pidof dd)" != "" ]
		do
			sleep 1
		done
		exit 1
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
		while [ "$(pidof dd)" != "" ]
		do
			sleep 1
		done
		exit 1
	fi
	sudo umount /dev/sdaa1
fi

