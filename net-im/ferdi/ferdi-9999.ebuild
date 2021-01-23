# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

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

inherit desktop git-r3 xdg-utils

DESCRIPTION="A messaging browser that allows you to combine your favorite messaging services into one application"
HOMEPAGE="https://get${PN}.com"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
EGIT_REPO_URI="https://github.com/get${PN}/${PN}.git
	      https://github.com/get${PN}/recipes.git
	      https://github.com/get${PN}/internal-server.git"
	      
PATCHES=( "${FILESDIR}"/fix-autostart-path-git.diff )
        
RDEPEND="dev-util/electron:9
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
	git submodule init
	git config submodule.recipes.url "${S}/${PN}-recipes"
	git config submodule.src/internal-server.url "${S}/${PN}-internal-server"
	git submodule update --init --recursive

	# Set system Electron version for ABI compatibility
	sed -E -i 's|("electron": ").*"|\1'"$(cat '/usr/lib/electron9/version')"'"|' 'package.json'

	# Prevent Ferdi from being launched in dev mode
	sed -i "s|import isDevMode from 'electron-is-dev'|const isDevMode = false|g" 'src/index.js' 'src/config.js'
	sed -i "s|import isDev from 'electron-is-dev'|const isDev = false|g" 'src/environment.js'

	# Specify path for autostart file
	patch --forward -p1 < '${FILESDIR}/fix-autostart-path-git.diff'

	# Build recipe archives
	cd "${S}/$_sourcedirectory/recipes/"
	HOME="${S}/$_homedirectory" npm install
	HOME="${S}/$_homedirectory" npm run package
	cd "${S}/$_sourcedirectory/"
	
	# Prepare dependencies
	HOME="${S}/$_homedirectory" npx lerna bootstrap

	# Build node-sass manually for platforms where pre-compiled binaries are not available
	if [ "$_electronbuilderarch" != 'x64' ] && [ "$_electronbuilderarch" != 'ia32' ]; then
		HOME="${S}/$_homedirectory" npm rebuild node-sass
	fi
	
	cat << EOF > "${S}/usr/bin/${PN}"
#!/bin/sh
NODE_ENV=production exec electron9 '/usr/lib/${PN}/app.asar' "\$@"
EOF

#    cat << EOF > "${S}/usr/share/applications/${PN}.desktop"
#[Desktop Entry]
#Name=${PN^}
#Exec=/usr/bin/${PN} %U
#Terminal=false
#Type=Application
#Icon=${PN}
#StartupWMClass=${PN^}
#Comment=Ferdi is your messaging app / former Emperor of Austria and combines chat & messaging services into one application. Ferdi currently supports Slack, WhatsApp, WeChat, HipChat, Facebook Messenger, Telegram, Google Hangouts, GroupMe, Skype and many more. You can download Ferdi for free for Mac & Windows.
#MimeType=x-scheme-handler/ferdi;
#Categories=Network;InstantMessaging;
#EOF
	
	default
}

src_compile() {
    cd "$_sourcedirectory/"

	NODE_ENV='production' HOME="${S}/$_homedirectory" npx gulp build
	NODE_ENV='production' HOME="${S}/$_homedirectory" npx electron-builder --linux dir "--$_electronbuilderarch" -c.electronDist='/usr/lib/electron9' -c.electronVersion="$(cat '/usr/lib/electron9/version')"
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
        doexe usr/bin/${PN}

    make_desktop_entry "/usr/bin/${PN} %U" "${PN^}" "${PN}" "Network;InstantMessaging;" "Type=Application\nStartupWMClass=${PN^}\nComment=Ferdi is your messaging app / former Emperor of Austria and combines chat & messaging services into one application. Ferdi currently supports Slack, WhatsApp, WeChat, HipChat, Facebook Messenger, Telegram, Google Hangouts, GroupMe, Skype and many more. You can download Ferdi for free for Mac & Windows.\nMimeType=x-scheme-handler/ferdi;\nTerminal=false"
        
#	insinto /usr/share/applications
#       doins ${S}/usr/share/applications/${PN}.desktop

	for _size in 16 24 32 48 64 96 128 256 512; do
        newicon -s ${_size} "usr/share/icons/hicolor/${_size}x${_size}/apps/${_PN}.png" "${PN}.png" || die
    done
    
    # desktop eclass does not support installing 1024x1024 icons
    insinto /usr/share/icons/hicolor/1024x1024/apps
        newins "usr/share/icons/hicolor/1024x1024/apps/${_PN}.png" "${PN}.png" || die
    
    # Installing 128x128 icon in /usr/share/pixmaps for legacy DEs
    newicon "usr/share/icons/hicolor/128x128/apps/${_PN}.png" "${PN}.png" || die
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
