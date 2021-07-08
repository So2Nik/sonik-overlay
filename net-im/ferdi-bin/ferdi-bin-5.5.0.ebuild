# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

_PN="${PN/-bin/}"

SONIK_LANGS="am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW"

inherit desktop sonik xdg-utils

DESCRIPTION="Combine your favorite messaging services into one application"
HOMEPAGE="https://getferdi.com"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
SRC_URI="https://github.com/get${_PN}/${_PN}/releases/download/v${PV}/${_PN}-${PV}.x86_64.rpm"

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
app-arch/snappy"

DEPEND="!net-im/ferdi"

QA_PREBUILT="*"

S=${WORKDIR}

src_unpack() {
    bsdtar -x -f ${DISTDIR}/${_PN}-${PV}.x86_64.rpm
}

src_prepare() {
	sed -E -i -e "s|Exec=/opt/${_PN^}/${_PN}|Exec=/usr/bin/${PN}|" "usr/share/applications/${_PN}.desktop"
	default
}

src_install() {
    declare FERDI_HOME=/opt/${_PN}

    pushd opt/Ferdi/locales > /dev/null
    sonik_remove_language_paks
    popd

	dodir ${FERDI_HOME%/*}

	insinto ${FERDI_HOME}
    doins -r opt/${_PN^}/*

    exeinto ${FERDI_HOME}
    exeopts -m0755
    doexe "opt/${_PN^}/${_PN}"

	dosym "${FERDI_HOME}/${_PN}" "/usr/bin/${PN}"

	newmenu usr/share/applications/${_PN}.desktop ${PN}.desktop

	for _size in 16 24 32 48 64 96 128 256 512; do
        newicon -s ${_size} "usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png" "${PN}.png"
    done

    # desktop eclass does not support installing 1024x1024 icons
    insinto /usr/share/icons/hicolor/1024x1024/apps
    newins "usr/share/icons/hicolor/1024x1024/apps/${_PN}.png" "${PN}.png"

    # Installing 128x128 icon in /usr/share/pixmaps for legacy DEs
    newicon "usr/share/icons/hicolor/128x128/apps/${_PN}.png" "${PN}.png"

    insinto /usr/share/licenses/${PN}
    for _license in 'LICENSE.electron.txt' 'LICENSES.chromium.html'; do
    doins opt/${_PN}/$_license
    done
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
