#!/bin/bash

cd /busybox/_install

mkdir -p etc/init.d

cat <<EOF >>etc/init.d/rcS
mkdir -p /proc
mount -t proc none /proc
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

find . | cpio -H newc -o | gzip > ../ramdisk.img

