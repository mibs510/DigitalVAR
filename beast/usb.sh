#!/bin/bash

if [ "${1}" != "7880" ] || [ "${1}" != "8500" ] || [ "${1}" != "8609" ] || [ "${1}" != "8610" ] || [ "${1}" != "8599" ]; then
	echo "ERROR: Invalid arguments"
	echo "Example: ${0} 7880"
	echo "		   ${0} [PART NUMBER]"
	echo ""
	echo "PART NUMBER:	7880"
	echo "				8500"
	echo "				8609"
	echo "				8610"
	echo "				8599"
fi

for i in {b..z}; do
	if [ ! -b /dev/sd${i} ]; then
		echo "ERROR: I need at least 26 USB drives!"
		exit 1
	fi
	if [ ! -b /dev/sdaa ]; then
		echo "ERROR: I need at least 26 USB drives!"
		exit 1
	fi
done

if [ "$(df -P /home/partimag | tail -1 | cut -d' ' -f1)" != "/dev/sda1" ]; then
	echo "Mounting /dev/sda1 onto /home/partimag"
	sudo mount /dev/sda1 /home/partimag
fi

# green7880
if [ "${1}" == "7880" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr green7880 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr green7880 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
fi

# yellow8500
if [ "${1}" == "8500" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr yellow8500 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr yellow8500 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
fi

# red8609
if [ "${1}" == "8609" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr red8609 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr red8609 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
fi

# blue8610
if [ "${1}" == "8610" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr blue8610 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr blue8610 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
fi

# lightblue8599
if [ "${1}" == "8599" ]; then
	echo ""
	echo ""
	echo "==================================================================================================================================================================================================================="
	echo "EXECUTING: sudo ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr lightblue8599 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa"
	echo "==================================================================================================================================================================================================================="
	echo ""
	echo ""
	ocs-restore-mdisks -batch -p -nogui -batch -p true -icds -t -iefi -j2 -j0 -scr lightblue8599 sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz sdaa
	echo "THESE SHOULD ALL MATCH"
	sudo blkid | less
fi
