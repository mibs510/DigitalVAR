#!/bin/bash

# Written by: Connor McMillan

if [ $# -lt 2 ]; then
	echo "ERROR: Not enough arguments."
	echo "${0} [master/from] [target] [target] [target] [target] ..."
	echo "Example: ${0} a b c d e f g h i j k l"
	exit 1
fi

echo ""
echo ""
echo "======================================="
echo " BE SURE /dev/sd${1} IS YOUR MASTER!!"
echo "======================================="
echo ""
echo ""

lsblk -o name,serial
echo ""
echo "Press Ctrl+C to exit"
read -p "Press Enter to continue"


for i in "${@:2}"; do
	echo ""
	echo ""
	echo "======================================================================================================================================"
	echo "EXECUTING: sudo ocs-onthefly -batch -nogui -pa command -g auto -e1 auto -e2 -r -j2 -f sd${1} -t sd${i} | tee /tmp/sd${i}.txt"
	echo "======================================================================================================================================"
	echo ""
	echo ""
	sudo ocs-onthefly -batch -nogui -pa command -g auto -e1 auto -e2 -r -j2 -f sd${1} -t sd${i} | tee /tmp/sd${i}.txt
done

for i in "${@:2}"; do
	echo "============================================"
	echo "/dev/sd${i} completed: "
	cat /tmp/sd${i}.txt | grep "error"
	echo "============================================"
done

echo ""
echo ""
echo "==========================================="
echo " LOGS OF IMAGED DRIVES ARE LOCATED IN /tmp"
echo "==========================================="
echo ""
