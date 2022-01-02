FROM ghcr.io/linuxserver/baseimage-alpine:3.15

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
  echo "**** install build packages ****" && \
  apk add -U --upgrade --no-cache \
    jq && \
  echo "**** install runtime packages ****" && \
  apk add -U --upgrade --no-cache \
    ca-certificates \
    curl \
    ffmpeg \
    flac \
    fontconfig \
    lame \
    openjdk11-jre-headless \
    ttf-dejavu && \
  echo "**** install airsonic advanced ****" && \
  if [ -z ${AIRSONIC_ADVANCED_RELEASE+x} ]; then \
    AIRSONIC_ADVANCED_RELEASE=$(curl -sX GET "https://api.github.com/repos/airsonic-advanced/airsonic-advanced/releases" \
    | jq -r 'first(.[] | select(.prerelease == true)) | .tag_name'); \
  fi && \
  mkdir -p \
    ${AIRSONIC_ADVANCED_HOME} && \
  curl -o \
  ${AIRSONIC_ADVANCED_HOME}/airsonic.war -L \
    "https://github.com/airsonic-advanced/airsonic-advanced/releases/download/${AIRSONIC_ADVANCED_RELEASE}/airsonic.war" && \
  echo "**** cleanup ****" && \
  apk del \
    jq && \
  rm -rf \
    /tmp/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 4040
