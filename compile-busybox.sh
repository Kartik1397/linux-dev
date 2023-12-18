#!/bin/bash

cd /busybox

make -j$(nproc)
make install

