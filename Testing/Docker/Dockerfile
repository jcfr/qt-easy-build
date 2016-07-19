FROM ubuntu
MAINTAINER fbudin69500 <francois.budin@kitware.com>

RUN apt-get update && apt-get install -y \
  cmake \
  git \
  make \
  gcc \
  g++ \
  libncurses5-dev \
  subversion \
  curl \
  libx11-dev \
  libxt-dev \
  libgl1-mesa-dev \
  libosmesa6-dev \
  libglu1-mesa-dev \
  libfontconfig-dev \
  libxrender-dev

RUN mkdir -p /usr/src/qt-easy-build-build
WORKDIR /usr/src/qt-easy-build-build

