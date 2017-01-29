# +-----------------------------------+
# | Official Pterodactyl Docker Image |
# |         Minecraft: Spigot         |
# +-----------------------------------+
# |       https://pterodactyl.io      |
# +-----------------------------------+
FROM openjdk:8-jdk-alpine

MAINTAINER Pterodactyl Software, <support@pterodactyl.io>

RUN app update \
    && apk add curl git tar \
    && adduser --disabled-password --home /home/container --gecos "" container \

USER container
ENV HOME=/home/container USER=container

WORKDIR /home/container

COPY entry.sh /entry.sh

CMD ["/bin/bash", "/entry.sh"]
