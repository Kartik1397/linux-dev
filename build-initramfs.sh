#!/bin/bash

cd /busybox/_install

# DHCP setup

mkdir -p usr/share/udhcpc 
cp ../examples/udhcp/simple.script usr/share/udhcpc/default.script

# Init script setup

mkdir -p etc/init.d

cat <<EOF >>etc/init.d/rcS
mkdir -p /proc
mount -t proc none /proc

ifconfig lo up

udhcpc -i eth0

mkdir -p /dev/
mount -t devtmpfs none /dev

mkdir -p /dev/pts
mount -t devpts none /dev/pts

telnetd -l /bin/sh
EOF

cat <<EOF >>etc/inittab
::sysinit:/etc/init.d/rcS

::askfirst:-/bin/sh

::restart:/sbin/init

::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a
EOF

chmod a+x etc/init.d/rcS

# Build image using cpio(copy in and out)

find . | cpio -H newc -o | gzip > ../ramdisk.img

