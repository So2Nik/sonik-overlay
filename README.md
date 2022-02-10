# sonik Gentoo overlay

This is an unofficial gentoo overlay for ferdi, freetube and haruna video player.

# About

**WARNING: Do not expect high quality ebuilds!** While I do the best I can, I am still learning.

## Why create this overlay?

To install packages not in gentoo or any other overlays, and to have fun.

## Adding the overlay

### Manual

If you want to manually add the overlay, see [examples/repos.conf/sonik-overlay.conf](examples/repos.conf/sonik-overlay.conf).

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

See [examples/package.accept_keywords/sonik-overlay](examples/package.accept_keywords/sonik-overlay).

## Credits

[src_prepare-overlay](https://gitlab.com/src_prepare/src_prepare-overlay) for repository general structure.
[Emilien Mottet](https://github.com/EmilienMottet) for improved ferdi-bin ebuild.
AUR for various PKGBUILDS of which the ebuilds are based off of.

# Submitting an Issue

### Ebuild error

[Our issue tracker is located in the **GitLab** repository.](https://gitlab.com/So2Nik/sonik-overlay/-/issues) If an ebuild appears to produce an error, please report it in the GitLab repository.
