# sonik Gentoo overlay

This is an unofficial overlay for ferdi, freetube and haruna video player among a few other things.

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

## Credits

[src_prepare-overlay](https://gitlab.com/src_prepare/src_prepare-overlay) for repository general structure.
AUR for various PKGBUILDS of which the ebuilds are based off of.
