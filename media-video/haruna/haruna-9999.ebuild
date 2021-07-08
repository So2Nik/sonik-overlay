# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3 xdg

DESCRIPTION="Video player built with Qt/QML on top of libmpv."
HOMEPAGE="https://invent.kde.org/multimedia/haruna"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
SRC_URI=""
EGIT_REPO_URI="${HOMEPAGE}.git"

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

# src_configure() {
#     local mycmakeargs=(
#             -DCMAKE_BUILD_TYPE='None'
#             -DCMAKE_INSTALL_PREFIX='/usr'
#             -Wno-dev
#     )
# 
#     cmake_src_configure
# }
