MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))

CONFIGURE_BUSYBOX_SCRIPT := configure-busybox.sh
COMPILE_BUSYBOX_SCRIPT := compile-busybox.sh

BUILD_INITRAMFS_SCRIPT := build-initramfs.sh

CONFIGURE_LINUX_SCRIPT := configure-linux.sh
COMPILE_LINUX_SCRIPT := compile-linux.sh

# Clone repos

linux/.git:
	git clone --depth=1 git@github.com:Kartik1397/linux.git

busybox/.git:
	git clone git://busybox.net/busybox.git
	git -C busybox checkout remotes/origin/1_36_stable

.PHONY: repos
repos: linux/.git busybox/.git

# Build docker image with all necessary dependency

.PHONY: linux-builder
linux-builder: repos
	docker build . -t linux-builder

# Busybox

busybox/.config:
	docker run -ti \
		-v $(CURRENT_DIR)/busybox:/busybox \
		-v $(CURRENT_DIR)/$(CONFIGURE_BUSYBOX_SCRIPT):/bin/$(CONFIGURE_BUSYBOX_SCRIPT) \
		linux-builder $(CONFIGURE_BUSYBOX_SCRIPT)

.PHONY: configure-busybox
configure-busybox: busybox/.config

busybox/_install: busybox/.config
	docker run -ti \
		-v $(CURRENT_DIR)/busybox:/busybox \
		-v $(CURRENT_DIR)/$(COMPILE_BUSYBOX_SCRIPT):/bin/$(COMPILE_BUSYBOX_SCRIPT) \
		linux-builder $(COMPILE_BUSYBOX_SCRIPT)

.PHONY: compile-busybox
compile-busybox: busybox/_install

.PHONY: clean-busybox
clean-busybox:	
	rm -rf $(CURRENT_DIR)/busybox

# initramfs

busybox/ramdisk.img:
	docker run -ti \
		-v $(CURRENT_DIR)/busybox:/busybox \
		-v $(CURRENT_DIR)/$(BUILD_INITRAMFS_SCRIPT):/bin/$(BUILD_INITRAMFS_SCRIPT) \
		linux-builder $(BUILD_INITRAMFS_SCRIPT)

.PHONY: build-initramfs
build-initramfs: busybox/ramdisk.img
	
.PHONY: clean-initramfs
clean-initramfs:
	rm $(CURRENT_DIR)/busybox/ramdisk.img 

# Linux

linux/.config:
	docker run -ti \
		-v $(CURRENT_DIR)/linux:/linux \
		-v $(CURRENT_DIR)/$(CONFIGURE_LINUX_SCRIPT):/bin/$(CONFIGURE_LINUX_SCRIPT) \
		linux-builder $(CONFIGURE_LINUX_SCRIPT)

.PHONY: configure-linux
configure-linux: linux/.config

.PHONY: compile-linux
compile-linux: configure-linux
	docker run -ti \
		-v $(CURRENT_DIR)/linux:/linux \
		-v $(CURRENT_DIR)/$(COMPILE_LINUX_SCRIPT):/bin/$(COMPILE_LINUX_SCRIPT) \
		linux-builder $(COMPILE_LINUX_SCRIPT)

.PHONY: clean-linux
clean-linux:	
	rm -rf $(CURRENT_DIR)/linux

# All

.PHONY: all
all: linux-builder build-initramfs compile-linux 

# Clean

.PHONY: clean
clean: clean-linux clean-busybox

