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

function post_family_tweaks__easepi_r1_udev_network_interfaces() {
	display_alert "$BOARD" "Renaming EasePi R1 network interfaces to eth0-3" "info"

	mkdir -p $SDCARD/etc/udev/rules.d/
	cat <<- EOF > "${SDCARD}/etc/udev/rules.d/70-persistent-net.rules"
		SUBSYSTEM=="net", ACTION=="add", KERNELS=="fe010000.ethernet", NAME:="eth0"
		SUBSYSTEM=="net", ACTION=="add", KERNELS=="fe2a0000.ethernet", NAME:="eth1"
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="r8169", KERNELS=="0001:11:00.0", NAME:="eth2"
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="r8169", KERNELS=="0000:01:00.0", NAME:="eth3"
	EOF

	echo "DEFAULT_INTERFACE=eth3" >/root/.default-network

}
