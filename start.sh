#!/usr/bin/env bash
## Entry point for the TeamCity server container.
##

set -e

xx() {
	echo "+" "$@"
	"$@"
}

xx_eval() {
	eval "xx" "$@"
}

printenv_sorted() {
	xx printenv | xx env LC_ALL=C sort
}

##

if command -v git >/dev/null ; then
	git config --global user.email root@localhost
	git config --global user.name "Administrator"
fi

##

echo
echo "Environment variables:"
xx :
printenv_sorted

##

xx :
xx cd "${teamcity_docker_image_home}"

case x"${-}"x in
*i*)
	echo
	echo "Launching a shell..."
	xx :
	xx_eval "exec bash -l"
	;;
*)
	echo
	echo "Launching TeamCity server..."
	xx :
	xx_eval "exec ${teamcity_docker_image_base_entrypoint:?}"
	;;
esac

##

