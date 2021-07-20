# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_PN="${PN/-bin/}"

SONIK_LANGS="
am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
sv sw ta te th tr uk vi zh-CN zh-TW"

inherit desktop sonik xdg-utils

DESCRIPTION="An open source desktop YouTube player built with privacy in mind."
HOMEPAGE="https://github.com/FreeTubeApp/FreeTube"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
SRC_URI="
amd64? ( https://github.com/FreeTubeApp/FreeTube/releases/download/v${PV}-beta/freetube_${PV}_amd64.deb -> ${P}-amd64.deb )
arm64? ( https://github.com/FreeTubeApp/FreeTube/releases/download/v${PV}-beta/freetube_${PV}_arm64.deb -> ${P}-arm64.deb )"

QA_PREBUILT="
opt/FreeTube/swiftshader/libEGL.so
opt/FreeTube/swiftshader/libGLESv2.so
opt/FreeTube/chrome-sandbox
opt/FreeTube/freetube
opt/FreeTube/libEGL.so
opt/FreeTube/libGLESv2.so
opt/FreeTube/libffmpeg.so
opt/FreeTube/libvk_swiftshader.so
opt/FreeTube/libvulkan.so"

S=${WORKDIR}

src_prepare() {
	bsdtar -x -f data.tar.xz
    rm data.tar.xz control.tar.gz debian-binary
    pushd usr/share/doc/${_PN} > /dev/null
    gzip -d changelog.gz
    popd

	default
}

src_install() {
	declare FREETUBE_HOME=/opt/FreeTube

    pushd opt/FreeTube/locales > /dev/null || die
    sonik_remove_language_paks
    popd

	dodir ${FREETUBE_HOME%/*}

	insinto ${FREETUBE_HOME}
    doins -r opt/FreeTube/*

	exeinto ${FREETUBE_HOME}
    exeopts -m4755
    doexe opt/FreeTube/chrome-sandbox

	exeinto ${FREETUBE_HOME}
    exeopts -m0755
    doexe opt/FreeTube/${_PN}

	dosym ${FREETUBE_HOME}/${_PN} /usr/bin/${PN} || die

	dodoc usr/share/doc/${_PN}/changelog

    insinto /usr/share/icons/hicolor/scalable/apps
    doins usr/share/icons/hicolor/scalable/apps/${_PN}.svg

    domenu "usr/share/applications/${_PN}.desktop"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
