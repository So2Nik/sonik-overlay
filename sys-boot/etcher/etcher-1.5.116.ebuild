# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="Flash OS images to SD cards & USB drives, safely and easily."
HOMEPAGE="https://etcher.io"
SRC_URI="https://github.com/balena-io/${PN}/archive/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz"
#RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE="notification"

DEPEND="!sys-boot/etcher-bin"
BDEPEND="
    net-libs/nodejs[npm]
    dev-lang/python:2.7
    app-misc/jq
"
#RDEPEND="
# 	app-arch/lzma
# 	dev-libs/atk
# 	dev-libs/expat
# 	dev-libs/libappindicator
# 	gnome-base/gconf:2
# 	media-libs/fontconfig
# 	media-libs/freetype
# 	net-print/cups
# 	sys-apps/dbus
# 	x11-apps/xrandr
# 	x11-libs/cairo
# 	x11-libs/gdk-pixbuf
# 	x11-libs/gtk+:2
# 	x11-libs/libXcomposite
# 	x11-libs/libXcursor
# 	x11-libs/libXdamage
# 	x11-libs/libXext
# 	x11-libs/libXfixes
# 	x11-libs/libXrender
#"

RDEPEND="
	|| ( =dev-util/electron-9*
         dev-util/electron-bin:9
    )
	x11-libs/gtk+:3
	x11-libs/libXtst
	x11-libs/libXScrnSaver
	dev-libs/nss
	net-libs/nodejs
	dev-libs/glib:2
	sys-auth/polkit
	notification? ( x11-libs/libnotify )
"

#S="${WORKDIR}"

src_prepare() {
    git submodule init
    git submodule update || cd "scripts/resin" && git checkout -- || die
    default
}

src_compile() {
    export NPM_VERSION=$(npm --version)
    make electron-develop
    npm run webpack
    npm prune --production
}

src_install() {
    
#    mv * "${D}" || die
#	rm -rd "${D}/usr/share/doc/balena-etcher-electron"
#	sed -i "s/Utility/System/g" "${D}/usr/share/applications/balena-etcher-electron.desktop"
#	fperms 0755 /opt/balenaEtcher/balena-etcher-electron || die

    declare ETCHER_HOME=/usr/lib/${PN}

    insinto $ETCHER_HOME
    doins package.json
    doins -r lib
    doins -r generated
    doins -r node_modules
    
    insinto $ETCHER_HOME/assets
    doins assets/icon.png
    
    insinto $ETCHER_HOME/lib/gui/app
    doins lib/gui/app/index.html
    
    exeinto /usr/bin
    newexe ${PN}-electron.sh ${PN}-electron
    
    sed -i "s/Utility/System/g" "usr/share/applications/balena-etcher-electron.desktop"
    domenu usr/share/applications/${PN}-electron.desktop
    
    for _size in 16 32 48 128 256 512; do
        newicon -s ${_size} "assets/iconset/${_size}x${_size}.png" "${PN}-electron.png" || die
	done
	
#	find . -name package.json -print0 | xargs -r -0 sed -i '/_where/d'
}

#pkg_postinst() {
#	xdg_icon_cache_update
#}

#pkg_postrm() {
#	xdg_icon_cache_update
#}
