function pre_install_distribution_specific__add_jellyfin-ffmpeg-repo() {
	display_alert "Preparing jellyfin ffmpeg repository..." "${EXTENSION}" "info"

	local keyring_url repo_url
	if [[ "${DISTRIBUTION}" == "Ubuntu" ]]; then
		keyring_url="https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key"
		repo_url="https://repo.jellyfin.org/ubuntu"
	else
		keyring_url="https://repo.jellyfin.org/jellyfin_team.gpg.key"
		repo_url="https://repo.jellyfin.org/debian"
	fi
	curl -fsSL "$keyring_url" -o "${SDCARD}"/tmp/jellyfin.gpg.key || return 1
	gpg --yes --dearmor -o "${SDCARD}"/etc/apt/keyrings/jellyfin.gpg "${SDCARD}"/tmp/jellyfin.gpg.key || return 1
	rm -f "${SDCARD}"/tmp/jellyfin.gpg.key
	echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/jellyfin.gpg] $repo_url ${RELEASE} main" > "${SDCARD}"/etc/apt/sources.list.d/jellyfin.list
}

function extension_prepare_config__prepare_jellyfin-ffmpeg_config() {
	display_alert "Preparing jellyfin ffmpeg packages..." "${EXTENSION}" "info"

	local FFMPEG_PACKAGE=jellyfin-ffmpeg7

	add_packages_to_image ${FFMPEG_PACKAGE}
}
