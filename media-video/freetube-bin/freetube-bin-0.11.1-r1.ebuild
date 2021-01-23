# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

_PN="${PN/-bin/}"

inherit xdg-utils

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
	bsdtar -x -f data.tar.xz opt/FreeTube
	
	mv opt/FreeTube/* .
    
    rm data.tar.xz control.tar.gz debian-binary
	rm -rf usr/share/applications
	rm -rf opt
	
	default
}

src_install() {
	declare FREETUBE_HOME=/opt/${_PN}

	dodir ${FREETUBE_HOME%/*}

	insinto ${FREETUBE_HOME}
		doins -r *

	exeinto ${FREETUBE_HOME}
        exeopts -m4755
        doexe chrome-sandbox
		
	exeinto ${FREETUBE_HOME}
        exeopts -m0755
		doexe freetube

	dosym ${FREETUBE_HOME}/freetube /usr/bin/${_PN} || die

    for _size in 16 32 48 64 128 256; do
        insinto /usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png
            doins ${S}/usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png
	done

    insinto /usr/share/applications/${_PN}.desktop
        doins ${FILESDIR}/freetube-bin.desktop
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
