#!/bin/bash

GITHUB_URL="https://raw.githubusercontent.com/mibs510/DigitalVAR/master/server"

# Lets wait until we have an internet connection
while true
do
	ping -c1 google.com &> /dev/null && break
done

# Should we update?
curl -sf $GITHUB_URL/update > /tmp/update

if [ "$?" != "0" ]; then
	echo "DigitalVAR repo not found..."
	exit 0
fi

if [ "$(cat /tmp/update)" != "true" ]; then
	exit 0
fi

echo "Updating DigitalVAR specific scripts & binaries..."

# Download list of files
curl -s $GITHUB_URL/files > /tmp/files
curl -s $GITHUB_URL/file-dest > /tmp/file-dest
curl -s $GITHUB_URL/file-chmodx > /tmp/file-chmodx

# Put list of files into an array
i=0
while read line
do
	FILE[$i]="$line"
	echo "Downloading: ${FILE[$i]}"
	curl -s $GITHUB_URL/${FILE[$i]} > /tmp/${FILE[$i]}
	i=$((i+1))
done < /tmp/files

# Put list of file destinations into an array
i=0
while read line
do
	DEST[$i]="$line"
	 mv /tmp/${FILE[$i]} ${DEST[$i]}
	i=$((i+1))
done < /tmp/file-dest

echo "Installing new updates..."

# chmod files as needed
i=0
while read line
do
	CHMODX[$i]="$line"
	chmod +x ${CHMODX[$i]}
	i=$((i+1))
done < /tmp/file-chmodx

exit 0
