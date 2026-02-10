# Rockchip RK3568 SoC quad core 2-4GB RAM 16GB eMMC 2x GbE 2x 2.5GbE HDMI NVMe USB3
BOARD_NAME="EasePi R1"
BOARDFAMILY="rk35xx"
BOARD_MAINTAINER="jjm2473"
BOOTCONFIG="radxa-e25-rk3568_defconfig"
KERNEL_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3568-easepi-r1.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
BOOTFS_TYPE="fat"

function post_family_tweaks__easepi_r1_hold_dtb() {
	display_alert "$BOARD" "Prevent armbian-upgrade from removing our dtb" "info"
	chroot_sdcard apt-mark hold linux-dtb-vendor-rk35xx || true
	return 0
}
