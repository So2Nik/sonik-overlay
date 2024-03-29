# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_PN="${PN/-bin/}"

ELECTRON_LANGS="am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW"

inherit desktop electron xdg-utils

DESCRIPTION="Combine your favorite messaging services into one application"
HOMEPAGE="https://getferdi.com"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="wayland"
KEYWORDS="-* ~amd64 ~arm ~arm64"
SRC_URI="
	amd64? ( https://github.com/get${_PN}/${_PN}/releases/download/v${PV}/${_PN}_${PV}_amd64.deb )
	arm? ( https://github.com/get${_PN}/${_PN}/releases/download/v${PV}/${_PN}_${PV}_armv7l.deb )
	arm64? ( https://github.com/get${_PN}/${_PN}/releases/download/v${PV}/${_PN}_${PV}_arm64.deb )
"

RDEPEND="
	media-libs/alsa-lib
	net-dns/c-ares
	media-video/ffmpeg
	x11-libs/gtk+:3
	dev-python/http-parser
	dev-libs/libevent
	net-libs/nghttp2
	app-crypt/libsecret
	x11-libs/libxkbfile
	dev-libs/libxslt
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	sys-libs/zlib[minizip]
	dev-libs/nss
	dev-libs/re2
	app-arch/snappy
	wayland? ( dev-libs/wayland )
"

DEPEND="!net-im/ferdi"

QA_PREBUILT="
	/opt/ferdi/chrome-sandbox
	/opt/ferdi/chrome_crashpad_handler
	/opt/ferdi/libEGL.so
	/opt/ferdi/libGLESv2.so
	/opt/ferdi/libffmpeg.so
	/opt/ferdi/libvk_swiftshader.so
	/opt/ferdi/libvulkan.so*
	/opt/ferdi/swiftshader/libEGL.so
	/opt/ferdi/swiftshader/libGLESv2.so
	/opt/ferdi/ferdi
"

S="${WORKDIR}"

src_prepare() {
	bsdtar -x -f data.tar.xz
	rm data.tar.xz control.tar.gz debian-binary
	if use wayland; then
		cp "usr/share/applications/${_PN}.desktop" "usr/share/applications/${_PN}-wayland.desktop"
		sed -E -i -e "s|Name=${_PN^}|Name=${_PN^} Wayland|" "usr/share/applications/${_PN}-wayland.desktop"
		sed -E -i -e "s|Exec=/opt/${_PN^}/${_PN}|Exec=/usr/bin/${_PN} --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-webrtc-pipewire-capturer|" "usr/share/applications/${_PN}-wayland.desktop"
	fi
	sed -E -i -e "s|Exec=/opt/${_PN^}/${_PN}|Exec=/usr/bin/${_PN}|" "usr/share/applications/${_PN}.desktop"
	default
}

src_install() {
	declare FERDI_HOME=/opt/${_PN}

	pushd opt/Ferdi/locales > /dev/null
	electron_remove_language_paks
	popd

	dodir ${FERDI_HOME%/*}

	insinto ${FERDI_HOME}
	doins -r opt/${_PN^}/*

	exeinto ${FERDI_HOME}
	exeopts -m0755
	doexe "opt/${_PN^}/${_PN}"

	dosym "${FERDI_HOME}/${_PN}" "/usr/bin/${_PN}"

	domenu usr/share/applications/${_PN}.desktop
	if use wayland; then
		domenu usr/share/applications/${_PN}-wayland.desktop
	fi

	for _size in 16 24 32 48 64 96 128 256 512; do
		doicon -s ${_size} "usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png"
	done

	# desktop eclass does not support installing 1024x1024 icons
	insinto /usr/share/icons/hicolor/1024x1024/apps
	doins "usr/share/icons/hicolor/1024x1024/apps/${_PN}.png"

	# Installing 128x128 icon in /usr/share/pixmaps for legacy DEs
	doicon "usr/share/icons/hicolor/128x128/apps/${_PN}.png"

	insinto /usr/share/licenses/${PN}
	for _license in 'LICENSE.electron.txt' 'LICENSES.chromium.html'; do
		doins opt/${_PN^}/$_license
	done
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}
