
function pre_install_distribution_specific__frp() {
	display_alert "Preparing frp binaries..." "${EXTENSION}" "info"
	local sha256
	local CACHEDIR="${SRC}/cache/frp"
	echo "Try download frp"
	mkdir -p "${CACHEDIR}"
	local version="0.67.0"
	if [[ "${ARCH}" = "amd64" ]]; then
		sha256='f8629ca7ca56b8e7e7a9903779b8d5c47c56ad1b75b99b2d7138477acc4c7105'
	elif [[ "${ARCH}" = "arm64" ]]; then
		sha256='0e9683226acdcbbb2ac8d073f35ba8be2a8b1e7584684d2073f39d337ebd6de7'
	else
		echo "frp is unsupported in this ARCH: ${ARCH}"
		return 1
	fi
	local filename="frp_${version}_linux_${ARCH}.tar.gz"

	[[ -e "${CACHEDIR}/${filename}" ]] && \
		echo "${sha256} ${CACHEDIR}/${filename}" | sha256sum -c - && {
		echo "frp binary already cached."
		return 0
	}

	rm -f "${CACHEDIR}/${filename}.part" 2>/dev/null || true
	local url="https://github.com/fatedier/frp/releases/download/v${version}/${filename}"
	echo "Fetching $url"
	curl -fsSL "$url" -o "${CACHEDIR}/${filename}.part" || {
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}
	[[ -e "${CACHEDIR}/${filename}.part" ]] || return 1

	echo "Checking frp sha256sum"
	echo "${sha256} ${CACHEDIR}/${filename}.part" | sha256sum -c - || {
		echo "frp sha256sum mismatch!"
		rm -f "${CACHEDIR}/${filename}.part"
		return 1
	}

	rm -f "${CACHEDIR}/${filename}" 2>/dev/null || true
	mv "${CACHEDIR}/${filename}.part" "${CACHEDIR}/${filename}"
}

function pre_customize_image__install_frp() {
	display_alert "Install frp..." "${EXTENSION}" "info"
	local version="0.67.0"
	local dirname="frp_${version}_linux_${ARCH}"
	local path="${SRC}/cache/frp/${dirname}.tar.gz"
	mkdir -p "${SDCARD}/usr/local/bin"
	tar -xzf "${path}" -C "${SDCARD}/usr/local/bin" --strip-components=1 "${dirname}/frpc"
	chmod 0755 "${SDCARD}"/usr/local/bin/frpc
}
