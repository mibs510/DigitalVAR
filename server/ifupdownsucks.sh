#!/bin/bash

# Because ifupdown sucks horribly at deciding who gets what ip address based on their MAC address
# without the need of a DHCP server. It's probably not to be blamed as ifupdown's configuration
# file is not ideally mean't for live filesystems on two different machines with an interface name
# of ethx and different MAC addresses, but meh.

ETH_IFACE=${1}
ETH_MAC=$(cat /sys/class/net/$ETH_IFACE/address)
SERVER1_MAC="c8:1f:66:ca:9a:e2" # server1
SERVER2_MAC="90:b1:1c:29:91:55" # server2
SERVER3_MAC="14:18:77:53:2c:84" # SSD/HDD Imager
SERVER4_MAC="ec:f4:bb:e8:99:c5" # Middle row
SERVERX_SUBNET="255.255.255.0"
LOG_FILE=/var/log/ifupdownsucks.log

touch $LOG_FILE

# set -x
while true; do
	# chown when needed
	if [ "$(ls -hal /home/partimag | awk '{print $3,$4,$9}' | grep -vw 'root root ..' | grep -v 'user user' | tr -d '\n' | tr -d [:space:])" != "" ]; then
		chown -R user:user /home/partimag
	fi
	ETH_OPERSTATE=$(cat /sys/class/net/$ETH_IFACE/operstate)
	if [ "$ETH_MAC" == "$SERVER1_MAC" ] || [ "$ETH_MAC" == "$SERVER2_MAC" ] || [ "$ETH_MAC" == "$SERVER3_MAC" ] || [ "$ETH_MAC" == "$SERVER4_MAC" ] && [ "$(pidof dhcpd)" != "" ]; then
		echo "$(date +"%m/%d/%y@%r") -- Machine MAC Address: $ETH_MAC"
		if [ "$ETH_OPERSTATE" == "up" ]; then
			echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE is up"
			ETH_IP=$(/sbin/ifconfig "$ETH_IFACE" | grep 'inet ' | cut -d' ' -f10)
			if [ "$ETH_IP" == "" ]; then
				echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE doesn't have an IP address"
				echo "$(date +"%m/%d/%y@%r") -- Starting dhclient on $ETH_IFACE"
				dhclient $ETH_IFACE
			else
				echo "$(date +"%m/%d/%y@%r") -- IP Address: $ETH_IP"
			fi
		else
			echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE is down/disconnected"
		fi
	fi
	sleep 2
done
# set +x
