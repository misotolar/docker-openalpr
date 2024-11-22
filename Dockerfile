FROM ubuntu:noble-20241015

LABEL maintainer="michal@sotolar.com"

ENV OPENALPR_VERSION=2.3.0
ARG VERSION=736ab0e608cf9b20d92f36a873bb1152240daa98
ARG SHA256=2157aef52e5782cbb4117669f3ffdc125281f71c773b61d50f2133a2a3cb66fe
ADD https://github.com/openalpr/openalpr/archive/$VERSION.tar.gz /tmp/openalpr.tar.gz

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

COPY resources/patches/0001-tesseract5-cleanup.patch /build/patches/0001-tesseract5-cleanup.patch

WORKDIR /build/openalpr

RUN set -ex; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        clinfo \
        intel-opencl-icd \
        libcurl3t64-gnutls \
        liblog4cplus-2.0.5t64 \
        libopencv-core406t64 \
        libopencv-features2d406t64 \
        libopencv-flann406t64 \
        libopencv-highgui406t64 \
        libopencv-imgproc406t64 \
        libopencv-objdetect406t64 \
        libopencv-video406t64 \
        libopencv-videoio406t64 \
        libtesseract5 \
    ; \
    apt-get install --no-install-recommends -y \
        build-essential \
        cmake \
        libcurl4-gnutls-dev \
        liblog4cplus-dev \
        libopencv-dev \
        libtesseract-dev \
    ; \
    echo "$SHA256 */tmp/openalpr.tar.gz" | sha256sum -c -; \
    tar xf /tmp/openalpr.tar.gz --strip-components=1; \
    cat /build/patches/*.patch | patch -p1; \
    mkdir -p /build/openalpr/src/build; \
    cd /build/openalpr/src/build; \
    cmake \
        -DWITH_TESTS=OFF \
        -DWITH_DAEMON=OFF \
        -DWITH_BINDING_GO=OFF \
        -DWITH_BINDING_JAVA=OFF \
        -DWITH_BINDING_PYTHON=OFF \
        -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc \
        .. \
    ; \
    make -j $(nproc); \
    make -j $(nproc) install; \
    apt-get remove --purge -y \
        build-essential \
        cmake \
        libcurl4-gnutls-dev \
        liblog4cplus-dev \
        libopencv-dev \
        libtesseract-dev \
    ; \
    apt-get autoremove --purge -y; \
    rm -rf \
        /build/* \
        /usr/src/* \
        /usr/share/doc/* \
        /usr/share/icons/* \
        /usr/share/man/* \
        /var/cache/debconf/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY resources/runtime_data/postprocess/eu.patterns /usr/share/openalpr/runtime_data/postprocess/eu.patterns
