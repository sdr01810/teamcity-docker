FROM openjdk:8-jre

STOPSIGNAL SIGTERM

#^
#^-- specified by the base image
#
#v-- specified by the current image
#v

ENV teamcity_docker_image_user_name=root
ENV teamcity_docker_image_group_name=root

ENV teamcity_docker_image_home=/opt/teamcity

ENV teamcity_docker_image_data_root=/var/local/workspaces/teamcity/data
ENV teamcity_docker_image_logs_root=/var/local/workspaces/teamcity/logs

ENV teamcity_docker_image_setup_root=/var/local/workspaces/teamcity/setup

VOLUME [ "$teamcity_docker_image_data_root" ]
VOLUME [ "$teamcity_docker_image_logs_root" ]

##

USER    root
WORKDIR "${teamcity_docker_image_setup_root}"

COPY packages.needed.0*.txt ./
RUN  egrep -v -h '^\s*#' packages.needed.0*.txt > packages.needed.filtered.txt

RUN apt-get update && apt-get install -y apt-utils && \
	apt-get install -y $(cat packages.needed.filtered.txt) && \
	rm -rf /var/lib/apt/lists/* ;

##

USER    root
WORKDIR "${teamcity_docker_image_setup_root}"

ARG teamcity_dist_version=2017.2.2
ARG teamcity_dist_sha256=cd735330e800473c5f1a5df8c6d55238d9931464cf14ead8cb8c4e8edfa38238
ARG teamcity_dist_url=https://download-cf.jetbrains.com/teamcity/TeamCity-${teamcity_dist_version}.tar.gz

COPY download-and-unpack.sh .
RUN  chmod a+rx download-and-unpack.sh

RUN ./download-and-unpack.sh \
	"${teamcity_dist_url}" "${teamcity_dist_sha256}" "${teamcity_docker_image_home}"

##

USER    root
WORKDIR "${teamcity_docker_image_setup_root}"

COPY start.sh .
RUN  chmod a+rx start.sh

ENTRYPOINT ["./start.sh"]

##

