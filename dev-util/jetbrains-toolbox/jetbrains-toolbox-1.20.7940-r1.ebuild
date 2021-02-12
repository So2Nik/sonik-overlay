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

QA_PRESTRIPPED="
    /opt/jetbrains-toolbox/jetbrains-toolbox
    /opt/jetbrains-toolbox/jetbrains-toolbox-helper
    /opt/jetbrains-toolbox/jre/lib/server/libjsig.so
    /opt/jetbrains-toolbox/jre/lib/server/libjvm.so
    /opt/jetbrains-toolbox/jre/lib/libjava.so
    /opt/jetbrains-toolbox/jre/lib/libjimage.so
    /opt/jetbrains-toolbox/jre/lib/libjsig.so
    /opt/jetbrains-toolbox/jre/lib/libmanagement.so
    /opt/jetbrains-toolbox/jre/lib/libmanagement_ext.so
    /opt/jetbrains-toolbox/jre/lib/libnet.so
    /opt/jetbrains-toolbox/jre/lib/libnio.so
    /opt/jetbrains-toolbox/jre/lib/libprefs.so
    /opt/jetbrains-toolbox/jre/lib/libsunec.so
    /opt/jetbrains-toolbox/jre/lib/libverify.so
    /opt/jetbrains-toolbox/jre/lib/libzip.so
    /opt/jetbrains-toolbox/libXss.so.1
    /opt/jetbrains-toolbox/libappindicator3.so.1
    /opt/jetbrains-toolbox/libcef.so
    /opt/jetbrains-toolbox/libdbusmenu-glib.so.4
    /opt/jetbrains-toolbox/libdbusmenu-gtk3.so.4
    /opt/jetbrains-toolbox/libindicator3.so.7
    /opt/jetbrains-toolbox/libxcb-keysyms.so.1
    /opt/jetbrains-toolbox/swiftshader/libEGL.so
    /opt/jetbrains-toolbox/swiftshader/libGLESv2.so
    /opt/jetbrains-toolbox/unzip"

src_prepare() {
        default
        ./"${PN}" --appimage-extract
        rm ${PN} || die
        rm squashfs-root/AppRun || die
        mv squashfs-root/${PN}.desktop ${PN}.desktop || die
        sed '/X-AppImage-Integrate/d' ${PN}.desktop || die
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
        
        dosym /opt/${PN}/${PN} /usr/bin/${PN}
}

pkg_postinst() {
        xdg_desktop_database_update
}

pkg_postrm() {
        xdg_desktop_database_update
}
