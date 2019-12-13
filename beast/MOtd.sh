#!/bin/sh

if [ "x${1}X" == "xx" ] || [ "x${2}x" == "xx" ]; then
	echo "ERROR: Not enough valid arguments"
	echo "      Example: ${0} x y"
	echo "      x = MO # y = Status"
	exit 1
fi


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
