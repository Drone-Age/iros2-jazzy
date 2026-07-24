# syntax=docker/dockerfile:1.7
FROM debian:trixie-slim AS environment

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=jazzy

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=${ROS_DISTRO}

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      dpkg-dev \
      fakeroot \
      git \
      locales \
      ninja-build \
      python3-colcon-common-extensions \
      python3-flake8 \
      python3-pip \
      python3-pytest \
      python3-rosdep2 \
      python3-setuptools \
      python3-vcstool \
      python3-yaml \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY scripts/container/ /usr/local/lib/iros2/
RUN chmod +x /usr/local/lib/iros2/*.sh

FROM environment AS source

ARG ROS2_REPOS_URL=https://raw.githubusercontent.com/ros2/ros2/jazzy/ros2.repos
RUN mkdir -p /work/src \
    && curl -fsSL "${ROS2_REPOS_URL}" -o /work/ros2.repos \
    && vcs import --input /work/ros2.repos /work/src

FROM source AS dependencies

RUN rosdep init \
    && rosdep update \
    && /usr/local/lib/iros2/install-dependencies.sh

FROM dependencies AS build

ARG IROS2_VERSION=0.1.0
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown
ENV IROS2_VERSION=${IROS2_VERSION} \
    BUILD_DATE=${BUILD_DATE} \
    VCS_REF=${VCS_REF}

RUN /usr/local/lib/iros2/build-ros.sh

FROM build AS package

COPY packaging/ /work/packaging/
RUN /usr/local/lib/iros2/build-deb.sh

FROM scratch AS artifact

COPY --from=package /out/ /
