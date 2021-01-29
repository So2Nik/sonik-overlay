# sonik Gentoo overlay

This is the overlay for river wayland window manager.

## Adding the overlay

### Manual

If you want to manually add the overlay, see [examples/repos.conf/sonik-overlay.conf](https://github.com/So2Nik/sonik-overlay/blob/master/examples/repos.conf/sonik-overlay.conf).

### eselect-repository

If you are using [eselect-repository](https://wiki.gentoo.org/wiki/Eselect/Repository), execute:

``` sh
eselect repository add sonik-overlay git https://github.com/So2Nik/sonik-overlay
```

## How do I sync this?

Execute:

``` sh
emaint sync -r sonik-overlay
```

## It says the ebuild is masked, what do I do?

See [examples/package.accept_keywords/sonik-overlay](https://github.com/So2Nik/sonik-overlay/blob/master/examples/package.accept_keywords/sonik-overlay).

### Instructions for ferdi

Enable [electron overlay](https://github.com/elprans/electron-overlay) and unmask packages if needed.

``` sh
eselect repository enable electron
emaint sync -r electron
flaggie app-eselect/eselect-electron::electron +~amd64
flaggie dev-util/electron:8::sonik-overlay +~amd64
```

## Credits

[menelkir overlay](https://gitlab.com/menelkir/gentoo-overlay) for electron:8 ebuild.
[src_prepare-overlay](https://gitlab.com/src_prepare/src_prepare-overlay) for repository general structure.
AUR for various PKGBUILDS.
