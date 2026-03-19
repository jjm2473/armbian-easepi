# Rockchip RK3568 SoC quad core 4GB RAM 32GB eMMC GBe HDMI NVMe USB3
BOARD_NAME="EasePi A2"
BOARD_VENDOR="linkease"
BOARDFAMILY="rk35xx"
BOARD_MAINTAINER="jjm2473"
BOOTCONFIG="radxa-e25-rk3568_defconfig"
KERNEL_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3568-easepi-a2.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
BOOTFS_TYPE="fat"

function post_family_tweaks__easepi_a2_hold_dtb() {
	display_alert "$BOARD" "Prevent armbian-upgrade from removing our dtb" "info"
	chroot_sdcard apt-mark hold linux-dtb-vendor-rk35xx || true
	return 0
}

function post_family_tweaks__easepi_a2_root_part_size() {
	display_alert "$BOARD" "Change easepi-a2 Root part size to 16GB" "info"
	echo "50%" > "${SDCARD}/root/.rootfs_resize"
	return 0
}

function post_family_tweaks__easepi_a2_udev_network_interfaces() {
	echo "DEFAULT_INTERFACE=eth0" >/root/.default-network
}
