# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

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

#inherit xdg-utils
inherit desktop

DESCRIPTION="A messaging browser that allows you to combine your favorite messaging services into one application"
HOMEPAGE="https://get${PN}.com"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
SRC_URI="https://github.com/get${PN}/${PN}/archive/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz
	      https://github.com/get${PN}/recipes/archive/$_recipescommit.tar.gz -> ${PN}-$_recipescommit.tar.gz
	      https://github.com/get${PN}/internal-server/archive/$_internalservercommit.tar.gz -> ${PN}-$_internalservercommit.tar.gz"
        
PATCHES=( "${FILESDIR}"/fix-autostart-path.diff )

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
	cd "$_sourcedirectory/"

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
	
    cat << EOF > "usr/bin/${PN}"
#!/bin/sh
NODE_ENV=production exec electron8 '/usr/lib/${PN}/app.asar' "\$@"
EOF
	
	default
}

src_compile() {
    cd "$_sourcedirectory/"

	NODE_ENV='production' HOME="${S}/$_homedirectory" npx gulp build
	NODE_ENV='production' HOME="${S}/$_homedirectory" npx electron-builder --linux dir "--$_electronbuilderarch" -c.electronDist='/usr/lib/electron8' -c.electronVersion="$(cat '/usr/lib/electron8/version')"
}

src_install() {
	insinto /usr/lib/${PN}
        doins ${_sourcedirectory}/${_outpath}/resources/app.asar
    
    insinto /usr/lib/${PN}/app.asar.unpacked
        doins -r usr/lib/${PN}/app.asar.unpacked/*
    
    insinto /usr/lib/${PN}/app.asar.unpacked/recipes
        doins -r ${_sourcedirectory}/${_outpath}/resources/app.asar.unpacked/recipes/*

	insinto /usr/bin
        doins -r usr/bin/*
  
    exeinto /usr/bin
        doexe "usr/bin/${PN}"
        
    make_desktop_entry "/usr/bin/${PN} %U" "${PN^}" "${PN}" "Network;InstantMessaging;" "Type=Application\nStartupWMClass=${PN^}\nComment=Ferdi is your messaging app / former Emperor of Austria and combines chat & messaging services into one application. Ferdi currently supports Slack, WhatsApp, WeChat, HipChat, Facebook Messenger, Telegram, Google Hangouts, GroupMe, Skype and many more. You can download Ferdi for free for Mac & Windows.\nMimeType=x-scheme-handler/ferdi;\nTerminal=false"

	for _size in 16 24 32 48 64 96 128 256 512; do
        newicon -s ${_size} "usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png" "${PN}.png" || die
    done
    
    # desktop eclass does not support installing 1024x1024 icons
    insinto /usr/share/icons/hicolor/1024x1024/apps
        newins "usr/share/icons/hicolor/1024x1024/apps/${_PN}.png" "${PN}.png" || die
    
    # Installing 128x128 icon in /usr/share/pixmaps for legacy DEs
    newicon "usr/share/icons/hicolor/128x128/apps/${_PN}.png" "${PN}.png" || die
}
