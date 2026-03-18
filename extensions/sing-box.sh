
function pre_install_distribution_specific__sing-box() {
	display_alert "Preparing sing-box binaries..." "${EXTENSION}" "info"
	local sha256
	local CACHEDIR="${SRC}/cache/sing-box"
	echo "Try download sing-box"
	mkdir -p "${CACHEDIR}"
	local version="1.10.7"
	if [[ "${ARCH}" = "amd64" ]]; then
		sha256='1951a0785c8b4e1e21e0640227a49528ca772aec3d680061652e3d6b687e00fe'
	elif [[ "${ARCH}" = "arm64" ]]; then
		sha256='15b43a0a50b4e6962aca819d4f3055aaac75ca7481350d4aaebe93ed06b7af49'
	else
		echo "sing-box is unsupported in this ARCH: ${ARCH}"
		return 1
	fi
	local filename="sing-box-${version}-linux-${ARCH}.tar.gz"

	[[ -e "${CACHEDIR}/${filename}" ]] && \
		echo "${sha256} ${CACHEDIR}/${filename}" | sha256sum -c - && {
		echo "sing-box binary already cached."
		return 0
	}

	rm -f "${CACHEDIR}/${filename}.part" 2>/dev/null || true
	local url="https://github.com/SagerNet/sing-box/releases/download/v${version}/${filename}"
	echo "Fetching $url"
	curl -fsSL "$url" -o "${CACHEDIR}/${filename}.part" || {
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}
	[[ -e "${CACHEDIR}/${filename}.part" ]] || return 1

	echo "Checking sing-box sha256sum"
	echo "${sha256} ${CACHEDIR}/${filename}.part" | sha256sum -c - || {
		echo "sing-box sha256sum mismatch!"
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}

	rm -f "${CACHEDIR}/${filename}" 2>/dev/null || true
	mv "${CACHEDIR}/${filename}.part" "${CACHEDIR}/${filename}"
}

function pre_customize_image__install_sing-box() {
	display_alert "Install sing-box..." "${EXTENSION}" "info"
	local version="1.10.7"
	local dirname="sing-box-${version}-linux-${ARCH}"
	local path="${SRC}/cache/sing-box/${dirname}.tar.gz"
	mkdir -p "${SDCARD}/usr/local/bin"
	tar -xzf "${path}" -C "${SDCARD}/usr/local/bin" --strip-components=1 "${dirname}/sing-box"
	chmod 0755 "${SDCARD}"/usr/local/bin/sing-box
}
