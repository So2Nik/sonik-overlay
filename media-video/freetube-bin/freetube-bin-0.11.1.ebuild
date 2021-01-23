# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

_PN="${PN/-bin/}"

inherit desktop xdg-utils

DESCRIPTION="An open source desktop YouTube player built with privacy in mind."
HOMEPAGE="https://github.com/FreeTubeApp/FreeTube"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
SRC_URI="amd64? ( ${HOMEPAGE}/releases/download/v${PV}-beta/freetube_${PV}_amd64.deb -> ${P}-amd64.deb )
        arm64? ( ${HOMEPAGE}/releases/download/v${PV}-beta/freetube_${PV}_arm64.deb -> ${P}-arm64.deb )"

QA_PREBUILT="*"

S=${WORKDIR}

src_prepare() {
	bsdtar -x -f data.tar.xz
    
    rm data.tar.xz control.tar.gz debian-binary
	rm -rf usr/share/applications
	
	default
}

src_install() {
	declare FREETUBE_HOME=/opt/${_PN}

	dodir ${FREETUBE_HOME%/*}

	insinto ${FREETUBE_HOME}
		doins -r opt/FreeTube/*

	exeinto ${FREETUBE_HOME}
        exeopts -m4755
        doexe opt/FreeTube/chrome-sandbox
		
	exeinto ${FREETUBE_HOME}
        exeopts -m0755
		doexe opt/FreeTube/${_PN}

	dosym ${FREETUBE_HOME}/${_PN} /usr/bin/${PN} || die

    for _size in 16 32 48 64 128 256; do
        newicon -s ${_size} "usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png" "${PN}.png"
	done

    # Install a 256x256 icon into /usr/share/pixmaps for legacy DEs
	newicon "usr/share/icons/hicolor/256x256/apps/${_PN}.png" "${PN}.png"

    newmenu "${FILESDIR}/${_PN}.desktop" "${PN}.desktop"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
