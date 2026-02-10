
function pre_install_distribution_specific__ddnsto() {
	display_alert "Preparing ddnsto binaries..." "${EXTENSION}" "info"
	local suffix sha256
	local CACHEDIR="${SRC}/cache/ddnsto"
	echo "Try download ddnsto"
	mkdir -p "${CACHEDIR}"
	if [[ "${ARCH}" = "amd64" ]]; then
		suffix='amd64'
		sha256='68a9f3e7d91ed51a5f5bfcedc91a3fc3b5b8031665f130c81116d04113a9d7ee'
	elif [[ "${ARCH}" = "arm64" ]]; then
		suffix='arm64'
		sha256='7dcc32d0e8abd0a0918d78ee37e990899b702aeebc604df787ebd69ddb048ab4'
	else
		echo "DDNSTO is unsupported in this ARCH: ${ARCH}"
		return 1
	fi
	local filename="ddnsto.${suffix}"

	[[ -e "${CACHEDIR}/${filename}" ]] && \
		echo "${sha256} ${CACHEDIR}/${filename}" | sha256sum -c - && {
		echo "ddnsto binary already cached."
		return 0
	}

	rm -f "${CACHEDIR}/${filename}.part" 2>/dev/null || true
	local url="https://fw.koolcenter.com/binary/ddnsto/linux/${filename}"
	echo "Fetching $url"
	curl -fsSL "$url" -o "${CACHEDIR}/${filename}.part" || {
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}
	[[ -e "${CACHEDIR}/${filename}.part" ]] || return 1

	echo "Checking ddnsto sha256sum"
	echo "${sha256} ${CACHEDIR}/${filename}.part" | sha256sum -c - || {
		echo "ddnsto sha256sum mismatch!"
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}

	rm -f "${CACHEDIR}/${filename}" 2>/dev/null || true
	mv "${CACHEDIR}/${filename}.part" "${CACHEDIR}/${filename}"
}

function pre_customize_image__install_ddnsto() {
	display_alert "Install ddnsto..." "${EXTENSION}" "info"
	cp "${SRC}"/cache/ddnsto/ddnsto.${ARCH} "${SDCARD}"/usr/local/bin/ddnsto
	chmod 0755 "${SDCARD}"/usr/local/bin/ddnsto
}
