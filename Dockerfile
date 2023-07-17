FROM ubuntu:22.04

RUN apt-get update
RUN apt-get -y install curl debhelper devscripts equivs

RUN useradd --system build --home-dir /home/build
COPY --chown=build debian/control /home/build/keepassxc/debian/control

USER root
WORKDIR /home/build/keepassxc
RUN yes | mk-build-deps -i
RUN mv keepassxc-build-deps_* /home/build/

ARG UPSTREAM_VER
ARG DEB_VER

USER build
RUN curl -fsSLo /home/build/keepassxc_$UPSTREAM_VER.orig.tar.xz \
    https://github.com/keepassxreboot/keepassxc/releases/download/$UPSTREAM_VER/keepassxc-$UPSTREAM_VER-src.tar.xz
WORKDIR /home/build/keepassxc
RUN tar xf /home/build/keepassxc_$UPSTREAM_VER.orig.tar.xz --strip-component=1
COPY --chown=build debian/ /home/build/keepassxc/debian/
RUN dpkg-buildpackage -us -uc
RUN lintian /home/build/keepassxc_${DEB_VER}_$(dpkg --print-architecture).deb

USER root
