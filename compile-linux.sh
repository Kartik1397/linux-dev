#!/bin/bash

cd /linux

make LLVM=1 rustavailable
sysctl -w fs.file-max=803018
make LLVM=1 -j$(nproc)
