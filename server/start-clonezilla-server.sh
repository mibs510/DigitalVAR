#!/bin/sh
sudo mkdir -p /tftpboot/nbi_img/pxelinux.cfg && sudo cp /opt/default /tftpboot/nbi_img/pxelinux.cfg/ && sudo ocs-srv-live -b start