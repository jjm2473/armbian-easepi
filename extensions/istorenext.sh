enable_extension "ddnsto"
enable_extension "jellyfin-ffmpeg"
enable_extension "ndpi-upstream"

declare -g VENDOR="Armbian-iStoreNext"
declare -g HOST="iStoreNext"

function pre_install_distribution_specific__istorenext_add_desktop_repo() {
	display_alert "Preparing iStoreNext desktop repository..." "${EXTENSION}" "info"

	# chromium-headless-shell needs armbian desktop repo
	[[ -s "${SDCARD}"/etc/apt/sources.list.d/armbian.list.disabled ]] && cat "${SDCARD}"/etc/apt/sources.list.d/armbian.list.disabled > "${SDCARD}"/etc/apt/sources.list.d/temp.list
	# [[ -s "${SDCARD}"/etc/apt/sources.list.d/armbian.sources.disabled ]] && cat "${SDCARD}"/etc/apt/sources.list.d/armbian.sources.disabled > "${SDCARD}"/etc/apt/sources.list.d/temp.sources

	return 0
}

function extension_prepare_config__prepare_istorenext_config() {
	display_alert "Preparing iStoreNext extra packages..." "${EXTENSION}" "info"

	local MONO_FONTS=fonts-dejavu-mono

	if [[ "${RELEASE}" = "bookworm" ]]; then
		MONO_FONTS="fonts-dejavu-core"
	fi

	if [[ "${ARCH}" = "amd64" ]]; then
		add_packages_to_image qemu-system-x86 qemu-system-arm qemu-utils \
		libvirt-daemon-system libvirt-clients virtinst ovmf qemu-efi-aarch64 cpu-checker
	fi

	add_packages_to_image python3-pip pipx nginx \
		curl wget git rsync procps gpg \
		docker.io \
		websockify \
		chromium-headless-shell fonts-noto-cjk fonts-noto-color-emoji ${MONO_FONTS} \
		7zip unrar zip unzip xz-utils \
		parted e2fsprogs xfsprogs btrfs-progs ntfs-3g dosfstools exfatprogs mdadm smartmontools \
		cifs-utils smbclient sshpass nfs-common rclone fuse3 \
		aria2 qbittorrent-nox \
		vim htop iproute2 dnsutils net-tools traceroute \
		nftables \
		openvswitch-switch \
		modemmanager \
		isc-dhcp-client dhcpcd dnsmasq openresolv pppoe \
		ifupdown-ng ifupdown-ng-compat \
		docker-cli docker-compose

}

function pre_customize_image__istorenext_patch() {
	display_alert "Apply iStoreNext rootfs patches..." "${EXTENSION}" "info"

	rm -f "${SDCARD}"/etc/apt/sources.list.d/temp.list "${SDCARD}"/etc/apt/sources.list.d/temp.sources || true

	# decrease networkd wait-online timeout to 12 seconds to avoid boot delays on some boards
	sed -i 's#/lib/systemd/systemd-networkd-wait-online$#/lib/systemd/systemd-networkd-wait-online --timeout=12#' \
		"${SDCARD}"/lib/systemd/system/systemd-networkd-wait-online.service 2>/dev/null || true

	ln -s chromium-headless-shell "${SDCARD}"/usr/bin/chromium

	cat <<- EOF > "${SDCARD}"/usr/local/bin/yt-dlp-upgrade.sh
	#!/bin/sh

	export PIPX_HOME=/usr/local/share/pipx
	export PIPX_BIN_DIR=/usr/local/bin
	export PIPX_MAN_DIR=/usr/local/share/man
	if [ "\$1" = "install" ]; then
		pipx install yt-dlp
	else
		pipx upgrade yt-dlp
	fi

	EOF

	chmod 755 "${SDCARD}"/usr/local/bin/yt-dlp-upgrade.sh

	echo "Installing yt-dlp via pipx..."
	chroot_sdcard /usr/local/bin/yt-dlp-upgrade.sh install || exit 1

}

function post_family_tweaks__istorenext_rootfs_part_size() {
	display_alert "Change Rootfs part size to 16GB" "${EXTENSION}" "info"
	echo "30507008s" > "${SDCARD}/root/.rootfs_resize"
	return 0
}

function post_family_tweaks__istorenext_rootfs_copy() {
	display_alert "Copying iStoreNext files..." "${EXTENSION}" "info"

	mkdir -p "${SDCARD}"/usr/lib/istorenext

	cp -f "${SRC}"/packages/bsp/istorenext/istorenext-init-network \
			"${SDCARD}"/usr/lib/istorenext/istorenext-init-network
	cp -f "${SRC}"/packages/bsp/istorenext/istorenext-init-network.service \
			"${SDCARD}"/etc/systemd/system/istorenext-init-network.service

	cp -f "${SRC}"/packages/bsp/istorenext/fix-ifaces-name \
			"${SDCARD}"/usr/lib/istorenext/fix-ifaces-name
	cp -f "${SRC}"/packages/bsp/istorenext/fix-ifaces-name.service \
			"${SDCARD}"/etc/systemd/system/fix-ifaces-name.service

}

post_post_debootstrap_tweaks__istorenext_network() {
	display_alert "Configuring network for iStoreNext..." "${EXTENSION}" "info"

	chroot_sdcard systemctl --no-reload enable fix-ifaces-name.service
	chroot_sdcard systemctl --no-reload enable networking.service
	chroot_sdcard systemctl --no-reload enable istorenext-init-network.service
	chroot_sdcard systemctl --no-reload disable dhcpcd.service

	chroot_sdcard systemctl --no-reload enable serial-option-new-id.service

	# change resolv.conf after all packages installed, since this will break network in chroot,
	# but we want to use openresolv instead of systemd-resolved in the final image.

	# revert armbian /etc/resolv.conf symlink to systemd-resolved stub-resolv.conf.
	rm -fv "${SDCARD}"/etc/resolv.conf
	touch "${SDCARD}"/etc/resolv.conf

	# openresolv merge dns servers for dnsmasq, see `man resolvconf.conf`.
	cat <<- EOF >> "${SDCARD}"/etc/resolvconf.conf
	name_servers=127.0.0.1
	dnsmasq_conf=/etc/dnsmasq.d/resolvconf.conf
	dnsmasq_resolv=/run/dnsmasq/resolv.conf
	EOF
}
