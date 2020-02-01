#
# Dockerfile for base-ladder
#

FROM alpine
LABEL maintainer="nobody<nobody@nobody.com>"

EXPOSE 8118 1080

ENV ARCH=amd64
ENV SSVER=v3.3.4
ENV KCPVER=20200103


COPY . /tmp/repo
RUN set -ex \
     # Build environment setup
     && apk add --no-cache --virtual .build-deps \
          autoconf \
          automake \
          build-base \
          c-ares-dev \
          libev-dev \
          libtool \
          libsodium-dev \
          linux-headers \
          mbedtls-dev \
          pcre-dev \
          openssl \
          git \
     # Build & install shadowsocks-libev
     && git clone https://github.com/shadowsocks/shadowsocks-libev.git /tmp/repo/shadowsocks-libev \
     && cd /tmp/repo/shadowsocks-libev \
     && git checkout ${SSVER} \
     && git submodule update --init --recursive \
     && ./autogen.sh \
     && ./configure --prefix=/usr --disable-documentation \
     && make install \
     # Runtime dependencies setup
     && apk del .build-deps \
     && apk add --no-cache \
          haveged \
          $(scanelf --needed --nobanner /usr/bin/ss-* \
          | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
          | sort -u) \
     # Install kcptun
     && cd /tmp/repo/ \
     && wget -Y off https://github.com/xtaci/kcptun/releases/download/v${KCPVER}/kcptun-linux-${ARCH}-${KCPVER}.tar.gz \
     && tar xf kcptun-linux-${ARCH}-${KCPVER}.tar.gz \
     && mv client_linux_${ARCH} /usr/sbin/kcptun \
     && rm -rf /tmp/repo \
     # install privoxy
     && apk add --no-cache privoxy \
     && sed -in '/^listen-address/d' /etc/privoxy/config \
     && echo "max-client-connections 2048" >> /etc/privoxy/config \
     && echo "listen-address  0.0.0.0:8118" >> /etc/privoxy/config \
     && echo "forward-socks5  /  127.0.0.1:1080 ." >> /etc/privoxy/config

WORKDIR /app

COPY ./run-apps.sh /app

CMD exec /app/run-apps.sh
