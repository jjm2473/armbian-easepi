
function pre_install_distribution_specific__ndpi-upstream() {
	display_alert "Preparing nDPI binaries..." "${EXTENSION}" "info"
	local url sha256
	local CACHEDIR="${SRC}/cache/ndpi-upstream"
	echo "Try download nDPI"
	mkdir -p "${CACHEDIR}"
	local filename="libndpi-dev-1180761-debian.tar.gz"
	local url='https://github.com/jjm2473/ndpi-build/releases/download/v0-prebuilt/'"${filename}"
	if [[ "${ARCH}" = "amd64" || "${ARCH}" = "arm64" ]]; then
		sha256='b2065cbe515bff6481d6f852bc569e5317482e8582423efeeb307c15a73ca2a0'
	else
		echo "nDPI is unsupported in this ARCH: ${ARCH}"
		return 1
	fi

	[[ -e "${CACHEDIR}/${filename}" ]] && \
		echo "${sha256} ${CACHEDIR}/${filename}" | sha256sum -c - && {
		echo "nDPI binary already cached."
		return 0
	}

	rm -f "${CACHEDIR}/${filename}.part" 2>/dev/null || true
	echo "Fetching $url"
	curl -fsSL "$url" -o "${CACHEDIR}/${filename}.part" || {
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}
	[[ -e "${CACHEDIR}/${filename}.part" ]] || return 1

	echo "Checking nDPI sha256sum"
	echo "${sha256} ${CACHEDIR}/${filename}.part" | sha256sum -c - || {
		echo "nDPI sha256sum mismatch!"
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}

	rm -f "${CACHEDIR}/${filename}" 2>/dev/null || true
	mv "${CACHEDIR}/${filename}.part" "${CACHEDIR}/${filename}"
}

function pre_customize_image__install_ndpi-upstream() {
	display_alert "Install nDPI upstream..." "${EXTENSION}" "info"
	tar -xzf "${SRC}"/cache/ndpi-upstream/libndpi-dev-1180761-debian.tar.gz -C "${SDCARD}" --strip-components=1 "${ARCH}"
}
