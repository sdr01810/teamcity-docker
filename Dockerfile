FROM jetbrains/teamcity-server:2017.2.1

STOPSIGNAL SIGTERM

ENV teamcity_docker_image_user_name=root
ENV teamcity_docker_image_group_name=root

ENV teamcity_docker_image_home=${TEAMCITY_DIST}

ENV teamcity_docker_image_data_root=${TEAMCITY_DATA_PATH}
ENV teamcity_docker_image_logs_root=${TEAMCITY_LOGS}

ENV teamcity_docker_image_base_entrypoint="/run-services.sh"

#^
#^-- specified by the base image
#
#v-- specified by the current image
#v

ENV teamcity_docker_image_setup_root=/var/local/workspaces/teamcity-server/setup

VOLUME [ "$teamcity_docker_image_data_root" ]
VOLUME [ "$teamcity_docker_image_logs_root" ]

##

USER    root
WORKDIR "${teamcity_docker_image_setup_root}"

COPY packages.needed.01.txt .
RUN  egrep -v '^\s*#' packages.needed.01.txt > packages.needed.01.filtered.txt

RUN apt-get update && apt-get install -y apt-utils && \
	apt-get install -y $(cat packages.needed.01.filtered.txt) && \
	rm -rf /var/lib/apt/lists/* ;

##

USER    root
WORKDIR "${teamcity_docker_image_setup_root}"

COPY start.sh .

ENTRYPOINT ["sh", "start.sh"]

##

