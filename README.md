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

Enable [menelkir overlay](https://gitlab.com/menelkir/gentoo-overlay) and unmask electron packages if needed.
