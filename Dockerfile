FROM debian:jessie
MAINTAINER daisaru11 <daisaru11@gmail.com>

ENV NGINX_VERSION=1.9.3 \
    NGINX_USER=nginx \
    NGINX_SRC_DIR=/usr/local/src \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TMP_DIR=/var/cache/nginx/tmp \
    NGINX_CACHE_DIR=/var/cache/nginx/cache


RUN apt-get update \
  && apt-get install -y libssl1.0.0 libpcre3 \
  && rm -rf /var/lib/apt/lists/*

COPY modules ${NGINX_SRC_DIR}/modules
COPY install.sh ${NGINX_SRC_DIR}/install.sh
RUN chmod 755 ${NGINX_SRC_DIR}/install.sh
RUN ${NGINX_SRC_DIR}/install.sh

RUN useradd nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh 

CMD /usr/sbin/entrypoint.sh

