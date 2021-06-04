# sonik Gentoo overlay

This is an overlay for ferdi and freetube.

## Adding the overlay

### Manual

If you want to manually add the overlay, see [examples/repos.conf/sonik-overlay.conf](https://gitlab.com/So2Nik/sonik-overlay/blob/master/examples/repos.conf/sonik-overlay.conf).

### eselect-repository

If you are using [eselect-repository](https://wiki.gentoo.org/wiki/Eselect/Repository), execute:

``` sh
eselect repository add sonik-overlay git https://gitlab.com/So2Nik/sonik-overlay
```

## How do I sync this?

Execute:

``` sh
emaint sync -r sonik-overlay
```

## It says the ebuild is masked, what do I do?

See [examples/package.accept_keywords/sonik-overlay](https://gitlab.com/So2Nik/sonik-overlay/blob/master/examples/package.accept_keywords/sonik-overlay).

### Instructions for ferdi

Enable [electron overlay](https://github.com/elprans/electron-overlay) and unmask packages if needed.

``` sh
eselect repository enable electron
emaint sync -r electron
flaggie app-eselect/eselect-electron::electron +~amd64
flaggie dev-util/electron:8::sonik-overlay +~amd64
```

If you want ferdi-9999, unmask electron:9 package.

``` sh
flaggie dev-util/electron:9::electron +~amd64
```

## Credits

[menelkir overlay](https://gitlab.com/menelkir/gentoo-overlay) for electron:8 ebuild.
[src_prepare-overlay](https://gitlab.com/src_prepare/src_prepare-overlay) for repository general structure.
AUR for various PKGBUILDS.
