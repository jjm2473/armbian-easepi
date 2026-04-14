
function pre_install_distribution_specific__accel-ppp() {
	display_alert "Preparing accel-ppp binaries..." "${EXTENSION}" "info"
	local url sha256
	local CACHEDIR="${SRC}/cache/accel-ppp"
	echo "Try download accel-ppp"
	mkdir -p "${CACHEDIR}"
	local filename="accel-ppp-1.14.0-048d31c-Debian12.tar.gz"
	local url='https://github.com/jjm2473/accel-ppp-build/releases/download/v0-prebuilt/'"${filename}"
	if [[ "${ARCH}" = "amd64" || "${ARCH}" = "arm64" ]]; then
		sha256='6d504e508eeda4bc3df6887f0e51375b8133fd5b1573fa7e3cb43535d8474334'
	else
		echo "accel-ppp is unsupported in this ARCH: ${ARCH}"
		return 1
	fi

	[[ -e "${CACHEDIR}/${filename}" ]] && \
		echo "${sha256} ${CACHEDIR}/${filename}" | sha256sum -c - && {
		echo "accel-ppp binary already cached."
		return 0
	}

	rm -f "${CACHEDIR}/${filename}.part" 2>/dev/null || true
	echo "Fetching $url"
	curl -fsSL "$url" -o "${CACHEDIR}/${filename}.part" || {
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}
	[[ -e "${CACHEDIR}/${filename}.part" ]] || return 1

	echo "Checking accel-ppp sha256sum"
	echo "${sha256} ${CACHEDIR}/${filename}.part" | sha256sum -c - || {
		echo "accel-ppp sha256sum mismatch!"
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}

	rm -f "${CACHEDIR}/${filename}" 2>/dev/null || true
	mv "${CACHEDIR}/${filename}.part" "${CACHEDIR}/${filename}"
}

function pre_install_kernel_debs__install_accel-ppp() {
	display_alert "Install accel-ppp..." "${EXTENSION}" "info"
	tar -xzf "${SRC}"/cache/accel-ppp/accel-ppp-1.14.0-048d31c-Debian12.tar.gz -C "${SDCARD}/tmp" --strip-components=1 "${ARCH}/accel-ppp.deb"

	chroot_sdcard_apt_get_install /tmp/accel-ppp.deb || return 1
	rm -f "${SDCARD}/tmp/accel-ppp.deb"
}
