# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

FREETUBE_PN="${PN/-bin/}"

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
	bsdtar -x -f data.tar.xz
	
	mv opt/FreeTube/* .
    
    rm data.tar.xz control.tar.gz debian-binary
	rm -rf opt
	
	default
}

src_install() {
	declare FREETUBE_HOME=/opt/${FREETUBE_PN}

	dodir ${FREETUBE_HOME%/*}

	insinto ${FREETUBE_HOME}
		doins -r *

	exeinto ${FREETUBE_HOME}
        exeopts -m4755
        doexe chrome-sandbox
		
	exeinto ${FREETUBE_HOME}
        exeopts -m0755
		doexe freetube

	dosym ${FREETUBE_HOME}/freetube /usr/bin/${PN} || die

    insinto /usr/share/pixmaps/${PN}.png
        doins ${FILESDIR}/freetube-bin-icon.png

    insinto /usr/share/applications/${PN}.desktop
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
