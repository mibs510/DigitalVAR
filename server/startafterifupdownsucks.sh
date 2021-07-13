#!/bin/bash

ETH_IFACE=${1}
ETH_MAC=$(cat /sys/class/net/$ETH_IFACE/address)
SERVER1_MAC="00:1e:67:cf:ee:8f"

# set -x
while true; do
	ETH_IP=$(/sbin/ifconfig "$ETH_IFACE" | grep 'inet ' | cut -d' ' -f10)
	if [ "$ETH_IFACE" != "" ]; then
		break
	fi
	sleep 2
done

# Now we may start:
sudo systemctl start ssh
sudo systemctl start syncthing@root.service
# Update all scripts from Github
update.sh &
# Start services and deamons on specific machines only
if [ "${ETH_MAC}" = "${SERVER1_MAC}" ]; then
	sudo systemctl start nut-client
fi

exit 0
# set +x
