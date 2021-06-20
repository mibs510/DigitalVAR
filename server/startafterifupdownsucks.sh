#!/bin/bash

ETH1_IFACE="eth1"
ETH1_MAC=$(cat /sys/class/net/$ETH1_IFACE/address)
SERVER1_MAC="00:1e:67:cf:ee:8f"

# set -x
while true; do
	ETH1_IP=$(/sbin/ifconfig "$ETH1_IFACE" | grep 'inet ' | cut -d' ' -f10)
	if [ "$ETH1_IP" != "" ]; then
		break
	fi
	sleep 2
done

# Now we may start:
sudo systemctl start ssh
sudo systemctl start syncthing@root.service
# Update all scripts from Github
update.sh &
if [ "${ETH1_MAC}" = "${SERVER1_MAC}" ]; then
	sudo systemctl start nut-client
fi

exit 0
# set +x
