# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

_PN="${PN/-bin/}"

SONIK_LANGS="am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW"

inherit desktop sonik

DESCRIPTION="Build cross platform desktop apps with web technologies - version 8 - binary version"
HOMEPAGE="https://${_PN}js.org"

IUSE="appindicator deletion kde xdg"

LICENSE="MIT"
SLOT="9"
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
        
DEPEND="!dev-util/electron:${SLOT}"
        
QA_PREBUILT="*"

S=${WORKDIR}

src_install() {
    declare ELECTRON_HOME=/usr/lib/${_PN}${SLOT}

    pushd locales > /dev/null || die
    sonik_remove_language_paks
    popd
    
	dodir ${ELECTRON_HOME%/*}

	insinto ${ELECTRON_HOME}
		doins -r *
    
    fperms u+s ${ELECTRON_HOME}/chrome-sandbox

	dosym "${ELECTRON_HOME}/${_PN}" "/usr/bin/${_PN}${SLOT}" || die
	
	for _license in 'LICENSE' 'LICENSES.chromium.html'; do
		insinto "/usr/share/licenses/${PN}"
		doins "$_license" || die
	done
}
