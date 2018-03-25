#!/usr/bin/env bash
## Download and unpack a package distribution tarball.
## By Stephen D. Rogers <inbox.c7r@steve-rogers.com>, 2018-01.
##
## Arguments:
##
##     package_dist_url package_dist_sha256 package_home
##

set -e

umask 0002

function xx() {
	echo 1>&2 "+" "$@"
	"$@"
}

function unpack_tarball() { # tarball_fpn
	local tarball_fpn="${1:?}"

	case "${tarball_fpn:?}" in
	*.tar.bz2|*.tbz2)
		xx tar xjf "${tarball_fpn:?}"
		;;
	*.tar.bz|*.tbz)
		xx tar xjf "${tarball_fpn:?}"
		;;
	*.tar.gz|*.tgz)
		xx tar xzf "${tarball_fpn:?}"
		;;
	*.tar.xz|*.txz)
		xx tar xJf "${tarball_fpn:?}"
		;;
	*)
		echo 1>&2 "Unrecognized format for tarball: ${tarball_fpn:?}" ; false
		;;
	esac
}

##

package_dist_url="${1:?}" ; shift

package_dist_sha256="${1:?}" ; shift

package_home="${1:?}" ; shift

##

package_dist_fbn="`basename "${package_dist_url}"`"
package_dist_dbn="${package_dist_fbn%.tar.*}"

for d1 in "/var/local/downloads" ; do
for b1 in "${package_dist_fbn}" ; do
(
	xx :

	xx mkdir -p "${d1}"

	xx curl --output "${d1}/${b1}" "${package_dist_url}"

	echo "${package_dist_sha256}  ${d1}/${b1}" | xx shasum -a 256 -c -

	for d2 in "`dirname "${package_home}"`" ; do
	for b2 in "`basename "${package_home}"`" ; do
	(
		xx :

		xx mkdir -p "${d2}" && xx cd "${d2}"

		xx unpack_tarball "${d1}/${b1}"
		xx rm -f "${d1}/${b1}"

		for b3 in "${package_dist_dbn%-*}"* ; do
			if [ "${b3}" != "${b2}" ] ; then
				xx :
				xx mkdir -p "${b2}"

				find -H "${b3}" -maxdepth 1 | egrep / |
				while read -r x4 ; do
					xx mv "${x4}" "${b2}"/.
				done

				xx rmdir "${b3}"
			fi
			break
		done
	)
	done;done
)
done;done

