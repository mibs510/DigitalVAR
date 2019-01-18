#!/bin/bash

# Because ifupdown sucks horribly at deciding who gets what ip address based on their MAC address
# without the need of a DHCP server. It's probably not to be blamed as ifupdown's configuration
# file is not ideally mean't for live filesystems on two different machines with an interface name
# of eth1 and different MAC addresses, but meh.

ETH1_IFACE="eth1"
ETH1_MAC=$(cat /sys/class/net/$ETH1_IFACE/address)
SERVER1_MAC="00:1e:67:cf:ee:8f"
SERVER2_MAC="00:1e:67:e0:9d:6f"
SERVER1_IP="192.168.1.241"
SERVER2_IP="192.168.1.242"
SERVERX_SUBNET="255.255.255.0"
LOG_FILE=/var/log/ifupdownsucks.log

touch $LOG_FILE

# set -x
while true; do
	ETH1_OPERSTATE=$(cat /sys/class/net/$ETH1_IFACE/operstate)
	if [ "$ETH1_MAC" == "$SERVER1_MAC" ] && [ "$(pidof dhcpd)" != "" ]; then
		echo "$(date +"%m/%d/%y@%r") -- This is server #1" >> $LOG_FILE
		if [ "$ETH1_OPERSTATE" == "up" ]; then
			echo "$(date +"%m/%d/%y@%r") -- $ETH1_IFACE is up" >> $LOG_FILE
			ETH1_IP=$(/sbin/ifconfig "$ETH1_IFACE" | grep 'inet ' | cut -d' ' -f10)
			if [ "$ETH1_IP" == "" ]; then
				echo "$(date +"%m/%d/%y@%r") -- $ETH1_IFACE doesn't have an IP address" >> $LOG_FILE
			else
				echo "$(date +"%m/%d/%y@%r") -- IP Address: $ETH1_IP" >> $LOG_FILE
			fi
			if [ "$ETH1_IP" != "$SERVER1_IP" ]; then
				echo "$(date +"%m/%d/%y@%r") -- Setting $ETH1_IFACE with an IP address of $SERVER1_IP" >> $LOG_FILE
				ifconfig $ETH1_IFACE $SERVER1_IP netmask $SERVERX_SUBNET up
			fi
		else
			echo "$(date +"%m/%d/%y@%r") -- $ETH1_IFACE is down/disconnected" >> $LOG_FILE
		fi
	fi
	if [ "$ETH1_MAC" == "$SERVER2_MAC" ] && [ "$(pidof dhcpd)" != "" ]; then
		echo "This is server #2"
		if [ "$ETH1_OPERSTATE" == "up" ]; then
			echo "$(date +"%m/%d/%y@%r") -- $ETH1_IFACE is up" >> $LOG_FILE
			ETH1_IP=$(/sbin/ifconfig "$ETH1_IFACE" | grep 'inet ' | cut -d' ' -f10)
			if [ "$ETH1_IP" == "" ]; then
				echo "$(date +"%m/%d/%y@%r") -- $ETH1_IFACE doesn't have an IP address" >> $LOG_FILE
			else
				echo "$(date +"%m/%d/%y@%r") -- IP Address: $ETH1_IP" >> $LOG_FILE
			fi
			if [ "$ETH1_IP" != "$SERVER2_IP" ]; then
				echo "$(date +"%m/%d/%y@%r") -- Setting $ETH1_IFACE with an IP address of $SERVER2_IP" >> $LOG_FILE
				ifconfig $ETH1_IFACE $SERVER2_IP netmask $SERVERX_SUBNET up
			fi
		else
			echo "$(date +"%m/%d/%y@%r") -- $ETH1_IFACE is down/disconnected" >> $LOG_FILE
		fi
	fi

	sleep 2
done
# set +x
