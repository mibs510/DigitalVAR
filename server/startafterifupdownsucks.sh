#!/bin/bash

ETH1_IFACE="eth1"

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
# sudo systemctl start syncthing@root.service

exit 0
# set +x
