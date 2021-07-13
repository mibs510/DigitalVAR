#!/bin/bash

# Because ifupdown sucks horribly at deciding who gets what ip address based on their MAC address
# without the need of a DHCP server. It's probably not to be blamed as ifupdown's configuration
# file is not ideally mean't for live filesystems on two different machines with an interface name
# of ethx and different MAC addresses, but meh.

ETH_IFACE=${1}
ETH_MAC=$(cat /sys/class/net/$ETH_IFACE/address)
SERVER1_MAC="00:1e:67:cf:ee:8f"
SERVER2_MAC="00:1e:67:e0:9d:6f"
USBIMAGER1_MAC="70:b5:e8:47:5c:92"
USBIMAGER2_MAC="70:b5:e8:49:b2:a8"
SERVER1_IP="192.168.1.241"
SERVER2_IP="192.168.1.242"
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
	if [ "$ETH_MAC" == "$SERVER1_MAC" ] || [ "$ETH_MAC" == "$SERVER2_MAC" ] || [ "$ETH_MAC" == "$USBIMAGER1_MAC" ] || [ "$ETH_MAC" == "$USBIMAGER2_MAC" ] && [ "$(pidof dhcpd)" != "" ]; then
		echo "$(date +"%m/%d/%y@%r") -- Machine MAC Address: $ETH_MAC" >> $LOG_FILE
		if [ "$ETH_OPERSTATE" == "up" ]; then
			echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE is up" >> $LOG_FILE
			ETH_IP=$(/sbin/ifconfig "$ETH_IFACE" | grep 'inet ' | cut -d' ' -f10)
			if [ "$ETH_IP" == "" ]; then
				echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE doesn't have an IP address" >> $LOG_FILE
				echo "$(date +"%m/%d/%y@%r") -- Starting dhclient on $ETH_IFACE" >> $LOG_FILE
				dhclient $ETH_IFACE
			else
				echo "$(date +"%m/%d/%y@%r") -- IP Address: $ETH_IP" >> $LOG_FILE
			fi
		else
			echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE is down/disconnected" >> $LOG_FILE
		fi
	fi
	#if [ "$ETH_MAC" == "$SERVER2_MAC" ] && [ "$(pidof dhcpd)" != "" ]; then
		#echo "This is server #2"
		#if [ "$ETH_OPERSTATE" == "up" ]; then
			#echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE is up" >> $LOG_FILE
			#ETH_IP=$(/sbin/ifconfig "$ETH_IFACE" | grep 'inet ' | cut -d' ' -f10)
			#if [ "$ETH_IP" == "" ]; then
				#echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE doesn't have an IP address" >> $LOG_FILE
				#echo "$(date +"%m/%d/%y@%r") -- Starting dhclient on $ETH_IFACE" >> $LOG_FILE
				#dhclient $ETH_IFACE
			#else
				#echo "$(date +"%m/%d/%y@%r") -- IP Address: $ETH_IP" >> $LOG_FILE
			#fi
		#else
			#echo "$(date +"%m/%d/%y@%r") -- $ETH_IFACE is down/disconnected" >> $LOG_FILE
		#fi
	#fi

	sleep 2
done
# set +x
