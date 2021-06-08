
EAPI=7

inherit meson git-r3

DESCRIPTION="Share files across the LAN"
KEYWORDS=""
HOMEPAGE="https://github.com/linuxmint/$PN"
LICENSE="GPL-3"

IUSE="system-zeroconf"

RDEPEND="x11-libs/gtk+:3
        net-misc/networkmanager
        dev-python/cryptography
        dev-python/pygobject
        dev-python/grpcio
        dev-python/netaddr
        dev-python/netifaces
        dev-python/protobuf-python
        dev-python/pynacl
        dev-python/setproctitle
        system-zeroconf? (dev-python/zeroconf)
        dev-python/xapp
        x11-apps/xapps
        polkit? (sys-auth/polkit)
        "
BDEPEND="dev-util/meson
        dev-libs/gobject-introspection"
#optdepends=('polkit: Open a firewall port'
#            'ufw: Configure firewall rules')
            
EGIT_REPO_URI="$HOMEPAGE.git"

src_prepare() {
    git describe --long --tags | sed 's/\([^-]*-g\)/r\1/;s/-/./g'
	
	# Fix hard-coded libexec dir
	sed -i 's/libexec/lib/g' "bin/${PN}.in" "data/org.x.${PN}.policy.in.in"
	sed -i 's/libexecdir="@libexecdir@"/libexecdir="@libdir@"/g' src/config.py.in
}

src_configure() {
    local emesonargs=(
            $(meson_use !system-zeroconf bundle-zeroconf)
    )
    meson_src_configure
}

#build() {
#	arch-meson  "${PN}" build -Dbundle-zeroconf=false
#	meson compile -C build
#}

#package() {
#	DESTDIR="$pkgdir" meson install -C build
#} 
