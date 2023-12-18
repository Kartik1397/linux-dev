#!/bin/bash

cd /linux

make LLVM=1 allnoconfig qemu-busybox-min.config rust.config

