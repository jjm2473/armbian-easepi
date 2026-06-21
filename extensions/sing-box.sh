
function pre_install_distribution_specific__sing-box() {
	display_alert "Preparing sing-box binaries..." "${EXTENSION}" "info"
	local sha256
	local CACHEDIR="${SRC}/cache/sing-box"
	echo "Try download sing-box"
	mkdir -p "${CACHEDIR}"
	local version="1.13.13"
	if [[ "${ARCH}" = "amd64" ]]; then
		sha256='bb99cabf47694625db421ee17898f36cdc1f9c2cb5decf65b12bac8d8437e842'
	elif [[ "${ARCH}" = "arm64" ]]; then
		sha256='d7fab87b921933eb281d8ee7bd5377cdd8228089f1f7c807c9363a6a2329286c'
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
	local version="1.13.13"
	local dirname="sing-box-${version}-linux-${ARCH}"
	local path="${SRC}/cache/sing-box/${dirname}.tar.gz"
	mkdir -p "${SDCARD}/usr/local/bin"
	tar -xzf "${path}" -C "${SDCARD}/usr/local/bin" --strip-components=1 "${dirname}/sing-box"
	chmod 0755 "${SDCARD}"/usr/local/bin/sing-box
}
