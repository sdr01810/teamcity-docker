docker_build_args_extra  = # --no-cache

docker_hub_user          = $(or ${DOCKER_HUB_USER},UNNOWN_DOCKER_HUB_USER)
#^-- override this on the make(1) command line or in the environment

container_name           = teamcity-server

image_tag                = ${docker_hub_user}/${container_name}

##

all :: build push

build ::
	docker build ${docker_build_args_extra} --tag "${image_tag}" .

push ::
	docker push "${image_tag}"

run ::
	docker run "${image_tag}"

