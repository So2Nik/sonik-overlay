# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake xdg

DESCRIPTION="Video player built with Qt/QML on top of libmpv."
HOMEPAGE="https://invent.kde.org/multimedia/haruna"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
SRC_URI="https://invent.kde.org/multimedia/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz"

BDEPEND="kde-frameworks/extra-cmake-modules"

RDEPEND="
dev-qt/qtquickcontrols2
kde-frameworks/breeze-icons
kde-frameworks/kfilemetadata
kde-frameworks/kio
kde-frameworks/kirigami
media-video/mpv[libmpv]"

src_prepare() {
	cmake_src_prepare
	xdg_src_prepare
}
