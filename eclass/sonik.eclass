# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: sonik.eclass
# @MAINTAINER:
# Sonik <so2nik@protonmail.com>
# @AUTHOR:
# Sonik <so2nik@protonmail.com>
# @BLURB: Shared functions for my ebuilds.

#inherit eutils

# @ECLASS-VARIABLE: SONIK_LANGS
# @DEFAULT_UNSET
# @DESCRIPTION:
# List of language packs available for this package.

# @FUNCTION: _sonik_set_l10n_IUSE
# @USAGE:
# @DESCRIPTION:
# Adds localization IUSE flags according to values of SONIK_LANGS in the ebuild.
_sonik_set_l10n_IUSE() {
	[[ ${EAPI:-0} == 0 ]] && die "EAPI=${EAPI} is not supported"

	local lang
	for lang in ${SONIK_LANGS}; do
		# Default to enabled since we bundle them anyway.
		# USE-expansion will take care of disabling the langs the user has not
		# selected via L10N.
		IUSE+=" +l10n_${lang}"
	done
}

if [[ ${SONIK_LANGS} ]]; then
	_sonik_set_l10n_IUSE
fi

# @FUNCTION: sonik_remove_language_paks
# @USAGE:
# @DESCRIPTION:
# Removes pak files from the current directory for languages that the user has
# not selected via the L10N variable.
# Also performs QA checks to ensure SONIK_LANGS has been set correctly.
sonik_remove_language_paks() {
	local lang pak

	# Look for missing pak files.
	for lang in ${SONIK_LANGS}; do
		if [[ ! -e ${lang}.pak ]]; then
			eqawarn "L10N warning: no .pak file for ${lang} (${lang}.pak not found)"
		fi
	done

	# Bug 588198
#	rm -f fake-bidi.pak || die
#	rm -f fake-bidi.pak.info || die

	# Look for extra pak files.
	# Remove pak files that the user does not want.
	for pak in *.pak; do
		lang=${pak%.pak}

		if [[ ${lang} == en-US ]]; then
			continue
		fi

		if ! has ${lang} ${SONIK_LANGS}; then
			eqawarn "L10N warning: no ${lang} in LANGS"
			continue
		fi

		if ! use l10n_${lang}; then
			rm "${pak}" || die
#			rm -f "${pak}.info" || die
		fi
	done
} 
