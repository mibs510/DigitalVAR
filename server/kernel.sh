#!/bin/sh
make -j 16
rm -rf install/*
INSTALL_MOD_PATH="install" make modules_install
sudo rm -rf /home/user/Devel/DigitalVAR/server/initrd-root/lib/modules/*
sudo rm -rf install/lib/modules/*/{build,source}
find install/ -iname "*.ko" -exec strip --strip-debug {} \;
sudo cp -r install/lib/modules/* /home/user/Devel/DigitalVAR/server/initrd-root/lib/modules
sudo cp arch/x86/boot/bzImage /home/user/Devel/DigitalVAR/server/vmlinuz
