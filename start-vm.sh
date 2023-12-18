#!/bin/bash

qemu-system-x86_64 \
    -kernel linux/arch/x86_64/boot/bzImage \
    -initrd busybox/ramdisk.img \
    -nographic -append "console=ttyS0"
