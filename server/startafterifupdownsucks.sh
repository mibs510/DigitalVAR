#!/bin/bash

ETH1_IFACE="eth1"
SERVER1_IP="192.168.168.1"
SERVER2_IP="192.168.168.2"


# set -x
while true; do
	ETH1_IP=$(/sbin/ifconfig "$ETH1_IFACE" | grep 'inet ' | cut -d' ' -f10)
	if [ "$ETH1_IP" == "$SERVER1_IP" ] || [ "$ETH1_IP" == "$SERVER2_IP" ]; then
		break
	fi
	sleep 2
done

# Now we may start
sudo systemctl start ssh
# sudo systemctl start syncthing@root.service

exit 0
# set +x
