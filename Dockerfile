# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
ARG AIRSONIC_ADVANCED_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV AIRSONIC_ADVANCED_HOME="/app/airsonic" \
AIRSONIC_ADVANCED_SETTINGS="/config" \
LANG="C.UTF-8"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ffmpeg \
    flac \
    fontconfig \
    lame \
    openjdk11-jre \
    ttf-dejavu \
    vorbis-tools && \
  echo "**** install airsonic advanced ****" && \
  if [ -z ${AIRSONIC_ADVANCED_RELEASE+x} ]; then \
    AIRSONIC_ADVANCED_RELEASE=$(curl -sX GET "https://api.github.com/repos/airsonic-advanced/airsonic-advanced/releases" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p \
    ${AIRSONIC_ADVANCED_HOME} && \
  curl -o \
  ${AIRSONIC_ADVANCED_HOME}/airsonic.war -L \
    "https://github.com/airsonic-advanced/airsonic-advanced/releases/download/${AIRSONIC_ADVANCED_RELEASE}/airsonic.war" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 4040
