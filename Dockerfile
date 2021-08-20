FROM ghcr.io/linuxserver/baseimage-ubuntu:focal
 
 # set version label
 ARG BUILD_DATE
 ARG VERSION
 ARG AIRSONIC_ADVANCED_RELEASE
 LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
 LABEL maintainer="chbmb"
 
 # environment settings
 ENV AIRSONIC_ADVANCED_HOME="/app/airsonic" \
 AIRSONIC_ADVANCED_SETTINGS="/config" \
 LANG="C.UTF-8"
 
 RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y \
    jq && \
  echo "**** install runtime packages ****" && \
  apt-get install -y \ 
     --no-install-recommends \
     ca-certificates \
     ffmpeg \
     flac \
     fontconfig \
     lame \
     openjdk-11-jre \
     ttf-dejavu && \
  echo "**** fix XXXsonic status page ****" && \
  find /etc -name "accessibility.properties" -exec rm -fv '{}' + && \
  find /usr -name "accessibility.properties" -exec rm -fv '{}' + && \
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
  apt-get -y purge \
    jq && \
  rm -rf \
     /tmp/* \
     /var/lib/apt/lists/* \
     /var/tmp/*
 
 # add local files
 COPY root/ /
 
 # ports and volumes
 EXPOSE 4040
 