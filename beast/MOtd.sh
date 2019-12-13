#!/bin/bash

if [ "${1}" == "" ] || [ "${2}" == "" ]; then
	echo "ERROR: Not enough valid arguments!"
	echo "      Example: ${0} x y"
	echo "      x = MO # y = Status"
	echo "      ${0} 1337 Done!"
	exit 1
fi

clear

echo ""
echo ""
echo ""
echo "                       ██████╗ ██╗ ██████╗ ██╗████████╗ █████╗ ██╗    ██╗   ██╗ █████╗ ██████╗ "
echo "                       ██╔══██╗██║██╔════╝ ██║╚══██╔══╝██╔══██╗██║    ██║   ██║██╔══██╗██╔══██╗"
echo "                       ██║  ██║██║██║  ███╗██║   ██║   ███████║██║    ██║   ██║███████║██████╔╝"
echo "                       ██║  ██║██║██║   ██║██║   ██║   ██╔══██║██║    ╚██╗ ██╔╝██╔══██║██╔══██╗"
echo "                       ██████╔╝██║╚██████╔╝██║   ██║   ██║  ██║███████╗╚████╔╝ ██║  ██║██║  ██║"
echo "                       ╚═════╝ ╚═╝ ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝ ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝ "


echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
figlet -k -w $(tput cols) -f /etc/colossal.flf -c "MO:   ${1}"
echo ""
echo ""
echo ""
figlet -k -w $(tput cols) -f /etc/colossal.flf -c "Progress:  ${2}"

while [ "x" == "x" ]
do
	sleep 10
done
