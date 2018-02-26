#!/usr/bin/env bash
## Entry point for the TeamCity container.
##

set -e

umask 0002

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

xx :
xx cd "${teamcity_docker_image_home}"

xx :
xx mkdir -p "${teamcity_docker_image_data_root}"
xx mkdir -p "${teamcity_docker_image_logs_root}"

xx ln -snf "${teamcity_docker_image_data_root}" data
xx ln -snf "${teamcity_docker_image_logs_root}" logs

export TEAMCITY_DATA_PATH="${teamcity_docker_image_home}/data"

##

echo
echo "Environment variables:"
xx :
printenv_sorted

##

xx :
xx cd "${teamcity_docker_image_home}"

if [ $# -gt 0 ] ; then
	echo
	echo "Running command..."
	xx :
	xx exec "$@"
else
if [ -t 0 ] ; then
	echo
	echo "Launching shell..."
	xx :
	xx exec bash -l
else
	echo
	echo "Launching TeamCity..."
	xx :
	xx exec bin/teamcity-server.sh run
fi;fi

##

