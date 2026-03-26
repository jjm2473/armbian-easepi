# Rockchip RK3588 SoC octa core 16GB RAM 64GB eMMC USB3 NVMe 2x SATA 4x 2.5GbE 4G WiFi/BT HDMI HDMI-In
BOARD_NAME="EasePi R2"
BOARD_VENDOR="linkease"
BOARDFAMILY="rockchip-rk3588"
BOARD_MAINTAINER="jjm2473"
BOOTCONFIG="rk3588-generic_defconfig"
KERNEL_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3588-easepi-r2.dtb"
BOOT_SCENARIO="spl-blobs"
BOOT_SOC="rk3588"
IMAGE_PARTITION_TABLE="gpt"
BOOTFS_TYPE="fat"

function post_family_config__easepi_r2_extra_packages() {
	add_packages_to_image "v4l-utils"
}

function post_family_tweaks__easepi_r2_hold_dtb() {
	display_alert "$BOARD" "Prevent armbian-upgrade from removing our dtb" "info"
	chroot_sdcard apt-mark hold linux-dtb-vendor-rk35xx || true
	return 0
}

function post_family_tweaks__easepi_r2_naming_audios() {
	display_alert "$BOARD" "Renaming easepi-r2 audios" "info"

	mkdir -p $SDCARD/etc/udev/rules.d/
	echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-hdmi0-sound", ENV{SOUND_DESCRIPTION}="HDMI0 Audio"' > $SDCARD/etc/udev/rules.d/90-naming-audios.rules
	echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-hdmiin-sound", ENV{SOUND_DESCRIPTION}="HDMI-In Audio"' >> $SDCARD/etc/udev/rules.d/90-naming-audios.rules

	return 0
}

function post_family_tweaks__easepi_r2_udev_network_interfaces() {
	display_alert "$BOARD" "Renaming EasePi R2 network interfaces to eth0-3 usb4g" "info"

	mkdir -p $SDCARD/etc/udev/rules.d/
	cat <<- EOF > "${SDCARD}/etc/udev/rules.d/70-persistent-net.rules"
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="r8169", KERNELS=="0004:41:00.0", NAME:="eth0"
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="r8169", KERNELS=="0002:21:00.0", NAME:="eth1"
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="r8169", KERNELS=="0001:11:00.0", NAME:="eth2"
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="r8169", KERNELS=="0003:31:00.0", NAME:="eth3"
		SUBSYSTEM=="net", ACTION=="add", KERNELS=="fc800000.usb", NAME:="usb4g"
	EOF

	echo "DEFAULT_INTERFACE=eth3" >/root/.default-network

}
