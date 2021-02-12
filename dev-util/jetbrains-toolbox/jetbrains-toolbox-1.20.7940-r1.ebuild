# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils xdg-utils

DESCRIPTION="Manage all your JetBrains Projects and Tools"
HOMEPAGE="https://www.jetbrains.com/toolbox/app"
SRC_URI="https://download.jetbrains.com/toolbox/${P}.tar.gz"

LICENSE="JetBrainsToolbox"
SLOT="0"
KEYWORDS="~amd64"

#DEPEND="sys-fs/fuse:0"

#QA_PRESTRIPPED="/opt/jetbrains-toolbox/jetbrains-toolbox"

src_prepare() {
        ./"${PN}" --appimage-extract
        rm ${PN}
        rm squashfs-root/AppRun
        mv squashfs-root/${PN}.desktop ${PN}.desktop
        sed '/X-AppImage-Integrate/d' ${PN}.desktop
        default
}

src_install() {
#        keepdir /opt/${PN}
        insinto /opt/${PN}
        doins -r squashfs-root/*
        
        fperms +x /opt/${PN}/${PN}

#        exeinto /opt/${PN}
#        doexe ${PN}
        
        newicon squashfs-root/.DirIcon "${PN}.svg"

#        make_wrapper "${PN}" /opt/${PN}/${PN}
                
        domenu ${PN}.desktop
}

pkg_postinst() {
        xdg_desktop_database_update
}

pkg_postrm() {
        xdg_desktop_database_update
}
