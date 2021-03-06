#
# $Id: Makefile 1283 2014-03-01 12:01:39Z ales.bardorfer $
#
# Red Pitaya Ramdisk (root filesystem) Makefile
#

# Where to get buildroot & which version
B_SERVER=http://buildroot.uclibc.org/downloads
B_VERSION=2018.11.1
B_DIR=buildroot-$(B_VERSION)
#B_DIR=buildroot
B_ARCHIVE=$(B_DIR).tar.gz
B_DOWNLOAD=$(B_SERVER)/$(B_ARCHIVE)
UIMAGE=$(B_DIR)/output/images/rootfs.cpio.uboot
GIT_DESCRIPTION=$(shell git describe --tags --dirty --always --match [0-9][0-9][0-9][0-9]\.[0-9][0-9]\.[0-9]*)
SBTOS_VERSION=$(GIT_DESCRIPTION:v%=%)
OSRELEASE=overlay/etc/os-release

INSTALL_DIR ?= .

all: $(UIMAGE)

ifeq ($(CROSS_COMPILE),arm-xilinx-linux-gnueabi-)
$(error Xilinx toolset is unsupported. Please use the Linaro toolset.)
else ifeq ($(CROSS_COMPILE),arm-linux-gnueabihf-)
$(B_DIR)/.config: config.armhf
	cp $< $@
else ifndef CROSS_COMPILE
$(error CROSS_COMPILE must be defined)
endif

ifndef TOOLCHAIN_PATH
$(error TOOLCHAIN_PATH must be defined)
endif

$(UIMAGE): $(B_DIR) overlay $(B_DIR)/.config $(OSRELEASE)
	rm -f $(B_DIR)/output/target/etc/hostname
	rm -f $(B_DIR)/output/target/etc/network/interfaces
	$(MAKE) -C $(B_DIR) BR2_EXTERNAL=../external

$(B_DIR):
	wget $(B_DOWNLOAD)
	tar xfz $(B_ARCHIVE)
	ln -s $(B_DIR) buildroot
	#git clone https://github.com/buildroot/buildroot.git
	#git clone https://github.com/frederikaalund/buildroot.git

install: $(UIMAGE)
	mkdir -p $(INSTALL_DIR)
	cp $(UIMAGE) $(INSTALL_DIR)/uramdisk.image.gz

install-remote: remote_host_defined install
	ssh $(remote_host) "/bin/mount -o rw,remount \$$(readlink /media/system)"
	scp uramdisk.image.gz $(remote_host):/boot
	ssh $(remote_host) "/bin/mount -o ro,remount \$$(readlink /media/system)"

clean:
	-$(MAKE) -C $(B_DIR) clean
	rm *~ -f

mrproper:
	-rm -rf $(B_DIR) $(B_ARCHIVE)
	-rm *~ -f

$(OSRELEASE):
	( \
		echo "NAME=sbtOS"; \
		echo "VERSION=$(SBTOS_VERSION)"; \
		echo "ID=sbtos"; \
		echo "VERSION_ID=$(SBTOS_VERSION)"; \
		echo "PRETTY_NAME=\"sbtOS $(SBTOS_VERSION)\"" \
	) > $@

.PHONY: clean mrproper $(OSRELEASE)

.PHONY: remote_host_defined
remote_host_defined:
ifndef remote_host
	$(error remote_host is not set)
endif
