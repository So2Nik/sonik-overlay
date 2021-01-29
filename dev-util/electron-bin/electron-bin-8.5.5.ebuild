# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

_PN="${PN/-bin/}"

inherit desktop #xdg-utils

DESCRIPTION="Build cross platform desktop apps with web technologies - version 8 - binary version"
HOMEPAGE="https://${_PN}js.org"

IUSE="appindicator deletion kde xdg"

LICENSE="MIT"
SLOT="8"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
COMMON_URI="https://github.com/${_PN}/${_PN}/releases/download/v${PV}"
SRC_URI="amd64? ( ${COMMON_URI}/chromedriver-v${PV}-linux-x64.zip
                   ${COMMON_URI}/${_PN}-v${PV}-linux-x64.zip )
        x86? ( ${COMMON_URI}/chromedriver-v${PV}-linux-ia32.zip
                   ${COMMON_URI}/${_PN}-v${PV}-linux-ia32.zip )
        arm? ( ${COMMON_URI}/chromedriver-v${PV}-linux-armv7l.zip
               ${COMMON_URI}/${_PN}-v${PV}-linux-armv7l.zip )
        arm64? ( ${COMMON_URI}/chromedriver-v${PV}-linux-arm64.zip
                 ${COMMON_URI}/${_PN}-v${PV}-linux-arm64.zip )"
        
RDEPEND="net-dns/c-ares
        media-video/ffmpeg
        x11-libs/gtk+:3
        dev-python/http-parser
        dev-libs/libevent
        dev-libs/libxslt
        x11-libs/libXScrnSaver
        sys-libs/zlib[minizip]
        dev-libs/nss
        dev-libs/re2
        app-arch/snappy
        deletion? ( kde? ( kde-plasma/kde-cli-tools )
                    !kde? ( app-misc/trash-cli )
                  )
        appindicator? ( dev-libs/libappindicator )
        xdg? ( x11-misc/xdg-utils )"
        
DEPEND="!dev-util/electron:8"
        
QA_PREBUILT="*"

S=${WORKDIR}

#src_prepare() {
#	find . -mindepth 1 -maxdepth 1 -type f ! -name "*.zip" ! -name "LICENSE*" -exec cp -r --no-preserve=ownership --preserve=mode -t "usr/lib/${_PN}8/." {} +
#	
#	default
#}

src_install() {
    declare ELECTRON_HOME=/usr/lib/${_PN}8

	dodir ${ELECTRON_HOME%/*}

	insinto ${ELECTRON_HOME}/locales
		doins -r locales/*
    
    insinto ${ELECTRON_HOME}/resources
		doins -r resources/*
    
    insinto ${ELECTRON_HOME}/swiftshader
		doins -r swiftshader/*
    
    insinto ${ELECTRON_HOME}
        doins *
    
    fperms u+s ${ELECTRON_HOME}/chrome-sandbox

	dosym "${ELECTRON_HOME}/${_PN}" "/usr/bin/${_PN}8" || die
	
	for _license in 'LICENSE' 'LICENSES.chromium.html'; do
		doins "$_license" "/usr/share/licenses/${PN}/$_license" || die
	done
}

#pkg_postinst() {
#	xdg_desktop_database_update
#	xdg_mimeinfo_database_update
#}

#pkg_postrm() {
#	xdg_desktop_database_update
#	xdg_mimeinfo_database_update
#}
