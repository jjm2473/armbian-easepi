enable_extension "ddnsto"
enable_extension "jellyfin-ffmpeg"

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

	add_packages_to_image python3-pip pipx nginx \
		docker.io qemu-system-x86 qemu-utils \
		libvirt-daemon-system libvirt-clients virtinst ovmf cpu-checker websockify \
		chromium-headless-shell fonts-noto-cjk fonts-noto-color-emoji ${MONO_FONTS} \
		7zip unrar zip unzip xz-utils \
		parted e2fsprogs xfsprogs btrfs-progs ntfs-3g dosfstools exfatprogs mdadm smartmontools \
		cifs-utils smbclient sshpass nfs-common fuse3 \
		aria2 qbittorrent-nox

}

function pre_customize_image__istorenext_patch() {
	display_alert "Apply iStoreNext rootfs patches..." "${EXTENSION}" "info"

	rm -f "${SDCARD}"/etc/apt/sources.list.d/temp.list "${SDCARD}"/etc/apt/sources.list.d/temp.sources || true

	# decrease networkd wait-online timeout to 12 seconds to avoid boot delays on some boards
	sed -i 's#/lib/systemd/systemd-networkd-wait-online$#/lib/systemd/systemd-networkd-wait-online --timeout=12#' \
		"${SDCARD}"/lib/systemd/system/systemd-networkd-wait-online.service 2>/dev/null || true

	ln -s chromium-headless-shell "${SDCARD}"/usr/bin/chromium-browser


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
	display_alert "$BOARD" "Change Rootfs part size to 16GB" "info"
	echo "30507008s" > "${SDCARD}/root/.rootfs_resize"
	return 0
}
