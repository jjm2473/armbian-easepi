
function pre_install_distribution_specific__sing-box() {
	display_alert "Preparing sing-box binaries..." "${EXTENSION}" "info"
	local sha256
	local CACHEDIR="${SRC}/cache/sing-box"
	echo "Try download sing-box"
	mkdir -p "${CACHEDIR}"
	local version="1.13.3"
	if [[ "${ARCH}" = "amd64" ]]; then
		sha256='8f5336cc671851147b695b28bb69a8ae9e7b7bb9ad0513a2099a1e9be413be8f'
	elif [[ "${ARCH}" = "arm64" ]]; then
		sha256='7c0bf8918f1c558d184b2a8c10855bbe3e14f813322b3354e42104937c8c9870'
	else
		echo "sing-box is unsupported in this ARCH: ${ARCH}"
		return 1
	fi
	local filename="sing-box-${version}-linux-${ARCH}-glibc.tar.gz"

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
	local version="1.13.3"
	local dirname="sing-box-${version}-linux-${ARCH}-glibc"
	local path="${SRC}/cache/sing-box/${dirname}.tar.gz"
	mkdir -p "${SDCARD}/usr/local/bin"
	tar -xzf "${path}" -C "${SDCARD}/usr/local/bin" --strip-components=1 "${dirname}/sing-box"
	chmod 0755 "${SDCARD}"/usr/local/bin/sing-box
}
