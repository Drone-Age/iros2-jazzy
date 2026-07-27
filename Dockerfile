# syntax=docker/dockerfile:1.7
FROM debian:trixie-slim AS environment

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=jazzy

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=${ROS_DISTRO} \
    PATH=/opt/iros2_0-build-venv/bin:${PATH}

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
      python3-colcon-cmake \
      python3-colcon-bash \
      python3-colcon-core \
      python3-colcon-output \
      python3-colcon-package-information \
      python3-colcon-package-selection \
      python3-colcon-python-setup-py \
      python3-colcon-recursive-crawl \
      python3-colcon-ros \
      python3-colcon-test-result \
      python3-flake8 \
      python3-pip \
      python3-pytest \
      python3-rosdep2 \
      python3-setuptools \
      python3-venv \
      python3-yaml \
    && python3 -m venv --system-site-packages /opt/iros2_0-build-venv \
    && rm -rf /var/lib/apt/lists/*

COPY requirements-build.txt /tmp/requirements-build.txt
RUN /opt/iros2_0-build-venv/bin/pip install \
      --no-cache-dir \
      -r /tmp/requirements-build.txt

RUN apt-get update \
    && apt-get install -y --no-install-recommends colcon \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

FROM environment AS source

ARG ROS2_REPOS_URL=https://raw.githubusercontent.com/ros2/ros2/jazzy/ros2.repos
RUN mkdir -p /work/src \
    && curl -fsSL "${ROS2_REPOS_URL}" -o /work/ros2.repos \
    && vcs import --input /work/ros2.repos /work/src \
    && git clone --branch jazzy --depth 1 \
      https://github.com/ros2/variants.git /work/src/ros2/variants

FROM source AS dependencies

COPY scripts/container/install-dependencies.sh /usr/local/lib/iros2_0/
RUN chmod +x /usr/local/lib/iros2_0/install-dependencies.sh
RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
      rosdep init; \
    fi \
    && rosdep update \
    && apt-get update \
    && /usr/local/lib/iros2_0/install-dependencies.sh

FROM dependencies AS build

ARG TARGETARCH
COPY scripts/container/build-ros.sh /usr/local/lib/iros2_0/
RUN chmod +x /usr/local/lib/iros2_0/build-ros.sh
RUN --mount=type=cache,id=iros2_0-jazzy-${TARGETARCH}-build,target=/work/build,sharing=locked \
    --mount=type=cache,id=iros2_0-jazzy-${TARGETARCH}-log,target=/work/log,sharing=locked \
    /usr/local/lib/iros2_0/build-ros.sh

FROM build AS package

ARG TARGETARCH
ARG IROS2_VERSION=0.1.0
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown
ENV IROS2_ARCH=${TARGETARCH} \
    IROS2_VERSION=${IROS2_VERSION} \
    BUILD_DATE=${BUILD_DATE} \
    VCS_REF=${VCS_REF}

COPY packaging/ /work/packaging/
COPY scripts/container/build-deb.sh /usr/local/lib/iros2_0/
RUN chmod +x /usr/local/lib/iros2_0/build-deb.sh
RUN /usr/local/lib/iros2_0/build-deb.sh

FROM scratch AS artifact

COPY --from=package /out/ /

FROM debian:trixie-slim AS runtime

COPY --from=package /tmp/iros2-0-runtime.deb /tmp/iros2-0.deb
RUN apt-get update \
    && apt-get install -y --no-install-recommends /tmp/iros2-0.deb \
    && rm -f /tmp/iros2-0.deb \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/lib/iros2-0/docker-entrypoint.sh"]
CMD ["ros2", "--help"]
