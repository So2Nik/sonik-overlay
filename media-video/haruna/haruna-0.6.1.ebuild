# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Video player built with Qt/QML on top of libmpv."
HOMEPAGE="https://github.com/g-fb/haruna"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tar.gz"

BDEPEND="kde-frameworks/extra-cmake-modules"

RDEPEND="dev-qt/qtquickcontrols2
    kde-frameworks/breeze-icons
    kde-frameworks/kfilemetadata
    kde-frameworks/kio
    kde-frameworks/kirigami
    media-video/mpv[libmpv]
"

src_configure() {
    local mycmakeargs=(
            -DCMAKE_BUILD_TYPE='None'
            -DCMAKE_INSTALL_PREFIX='/usr'
            -Wno-dev
    )
    
    cmake_src_configure
}
