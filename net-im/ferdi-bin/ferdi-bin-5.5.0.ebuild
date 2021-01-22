# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

_PN="${PN/-bin/}"

inherit xdg-utils

DESCRIPTION="A messaging browser that allows you to combine your favorite messaging services into one application"
HOMEPAGE="https://get${_PN}.com"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
SRC_URI="https://github.com/get${_PN}/${_PN}/releases/download/v${PV}/${_PN}-${PV}.x86_64.rpm"
        
RDEPEND="media-libs/alsa-lib
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
        
QA_PREBUILT="*"

S=${WORKDIR}

src_unpack() {
    xz -d ${DISTDIR}/${_PN}-${PV}.x86_64.rpm
}

src_prepare() {
	sed -E -i -e "s|Exec=/opt/${_PN^}/${_PN}|Exec=/usr/bin/${_PN}|" "${S}/usr/share/applications/${_PN}.desktop"
	
	default
}

src_install() {
    declare FERDI_HOME=/opt/${_PN}

	dodir ${FERDI_HOME%/*}

	insinto ${FERDI_HOME}
		doins -r *
    
    exeinto ${FERDI_HOME}
        exeopts -m0755
        doexe "${S}/opt/${_PN^}/${_PN}"

	dosym "${FERDI_HOME}/${_PN}" "/usr/bin/${_PN}" || die

	insinto /usr/share/applications
        doins ${S}/usr/share/applications/${_PN}.desktop

	for _size in 16 24 32 48 64 96 128 256 512 1024; do
        insinto /usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png
            doins ${S}/usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png
	done
	
	for _license in 'LICENSE.electron.txt' 'LICENSES.chromium.html'; do
		dosym "/opt/${_PN}/$_license" "/usr/share/licenses/${PN}/$_license" || die
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
