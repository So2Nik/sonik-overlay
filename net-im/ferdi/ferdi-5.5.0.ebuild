# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

_recipescommit='3054fd4c362b5be81b5cdd48535a0e7078fcd0a6'
_internalservercommit='95ae59926dbd88d55a5377be997558a9e112ab49'
_sourcedirectory="${PN}-${PV}"
_homedirectory="${PN}-${PVR}-home"

case "$CARCH" in
	i686)
		_electronbuilderarch='ia32'
	;;
	armv7h)
		_electronbuilderarch='armv7l'
	;;
	aarch64)
		_electronbuilderarch='arm64'
	;;
	*)
		_electronbuilderarch='x64'
	;;
esac

_outpath='out/linux'
if [ "$_electronbuilderarch" != 'x64' ]; then
	_outpath="$_outpath-$_electronbuilderarch"
fi
_outpath="$_outpath-unpacked"

inherit xdg-utils

DESCRIPTION="A messaging browser that allows you to combine your favorite messaging services into one application"
HOMEPAGE="https://get${PN}.com"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
SRC_URI="https://github.com/get${PN}/${PN}/archive/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz
	      https://github.com/get${PN}/recipes/archive/$_recipescommit.tar.gz -> ${PN}-$_recipescommit.tar.gz
	      https://github.com/get${PN}/internal-server/archive/$_internalservercommit.tar.gz -> ${PN}-$_internalservercommit.tar.gz"
        
RDEPEND="dev-util/electron:8
        x11-libs/libxkbfile"
        
BDEPEND="dev-vcs/git
        net-libs/nodejs[npm]
        python:2.7
        || ( python:3.7
              python:3.8
              python:3.9
           )"

DEPEND="!net-im/ferdi-bin"
           
S=${WORKDIR}

src_prepare() {
	cd "${S}/$_sourcedirectory/"

	# Provide git submodules
	rm -rf 'recipes/' 'src/internal-server/'
	mv "../recipes-$_recipescommit/" 'recipes/'
	mv "../internal-server-$_internalservercommit/" 'src/internal-server/'

	# Set system Electron version for ABI compatibility
	sed -E -i -e 's|("electron": ").*"|\1'"$(cat '/usr/lib/electron8/version')"'"|' 'package.json'

	# Set node-sass version for node 14 compatibility
	sed -E -i 's|("node-sass": ").*"|\14.14.0"|' 'package.json'

	# Prevent Ferdi from being launched in dev mode
	sed -i "s|import isDevMode from 'electron-is-dev'|const isDevMode = false|g" 'src/index.js' 'src/config.js'
	sed -i "s|import isDev from 'electron-is-dev'|const isDev = false|g" 'src/environment.js'

	# Specify path for autostart file
	patch --forward -p1 < '${FILESDIR}/fix-autostart-path.diff'

	# Prepare dependencies
	HOME="${S}/$_homedirectory" npx lerna bootstrap

	# Build node-sass manually for platforms where pre-compiled binaries are not available
	if [ "$_electronbuilderarch" != 'x64' ] && [ "$_electronbuilderarch" != 'ia32' ]; then
		HOME="${S}/$_homedirectory" npm rebuild node-sass
	fi
	
    cat << EOF > "${S}/usr/bin/${PN}"
#!/bin/sh
NODE_ENV=production exec electron8 '/usr/lib/${PN}/app.asar' "\$@"
EOF
	
	cat << EOF > "${S}/usr/share/applications/${PN}.desktop"
[Desktop Entry]
Name=${PN^}
Exec=/usr/bin/${PN} %U
Terminal=false
Type=Application
Icon=${PN}
StartupWMClass=${PN^}
Comment=Ferdi is your messaging app / former Emperor of Austria and combines chat & messaging services into one application. Ferdi currently supports Slack, WhatsApp, WeChat, HipChat, Facebook Messenger, Telegram, Google Hangouts, GroupMe, Skype and many more. You can download Ferdi for free for Mac & Windows.
MimeType=x-scheme-handler/ferdi;
Categories=Network;InstantMessaging;
EOF
	
	default
}

src_compile() {
    cd "${S}/$_sourcedirectory/"

	NODE_ENV='production' HOME="${S}/$_homedirectory" npx gulp build
	NODE_ENV='production' HOME="${S}/$_homedirectory" npx electron-builder --linux dir "--$_electronbuilderarch" -c.electronDist='/usr/lib/electron8' -c.electronVersion="$(cat '/usr/lib/electron8/version')"
}

src_install() {
    declare FERDI_HOME="${S}/$_sourcedirectory/"

	insinto /usr/lib/${PN}
        doins ${FERDI_HOME}/${_outpath}/resources/app.asar
    
    exeinto /usr/lib/${PN}/app.asar.unpacked
        doexe -r ${S}/usr/lib/${PN}/app.asar.unpacked/*
    
    insinto /usr/lib/${PN}/app.asar.unpacked/recipes
        doins -r --no-preserve=ownership --preserve=mode ${FERDI_HOME}/${_outpath}/resources/app.asar.unpacked/recipes/*

	exeinto /usr/bin
        doexe -r ${S}/usr/bin/*
  
    exeinto /usr/bin
        doexe ${S}/usr/bin/${PN}

	insinto /usr/share/applications
        doins ${S}/usr/share/applications/${PN}.desktop

	for _size in 16 24 32 48 64 96 128 256 512 1024; do
        insinto /usr/share/icons/hicolor/${_size}x${_size}/apps/${PN}.png
            doins ${FERDI_HOME}/build-helpers/images/icons/${_size}x${_size}.png
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
