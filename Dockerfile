FROM debian:buster-slim

ENV VER_SS=v1.8.23
ENV FILE_SS=shadowsocks.tar.xz
ENV VER_KCP=20210103
ENV FILE_KCP=kcptun.tar.gz
ENV DEP_PACKAGES='wget xz-utils'

# RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
# RUN sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# Config Debian OS
RUN apt-get update && \
    apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

# Install dep tools
RUN apt-get update && \
    apt-get install -y ${DEP_PACKAGES} && \
    apt-get clean

# Install & config privoxy
RUN apt-get update && \
    apt-get install -y privoxy && \
    apt-get clean
RUN sed -in '/^listen-address/d' /etc/privoxy/config && \
    echo "max-client-connections 2048" >> /etc/privoxy/config && \
    echo "listen-address  0.0.0.0:8118" >> /etc/privoxy/config && \
    echo "forward-socks5  /  127.0.0.1:1080 ." >> /etc/privoxy/config

WORKDIR /app

# Download & install ss-rust
RUN wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/${VER_SS}/shadowsocks-${VER_SS}.x86_64-unknown-linux-gnu.tar.xz \
  -O ${FILE_SS}
RUN tar xJvf ${FILE_SS} sslocal
RUN mv sslocal /usr/local/bin/
RUN rm ${FILE_SS}

# Download & install kcptun
RUN wget https://github.com/xtaci/kcptun/releases/download/v${VER_KCP}/kcptun-linux-amd64-${VER_KCP}.tar.gz \
  -O ${FILE_KCP}
RUN tar xzvf ${FILE_KCP} client_linux_amd64
RUN mv client_linux_amd64 /usr/local/bin/kcptun
RUN rm ${FILE_KCP}

# Remove dep tools
RUN apt-get update && \
    apt-get remove -y ${DEP_PACKAGES} && \
    apt-get clean

COPY ./run-apps.sh /app
CMD exec /app/run-apps.sh
