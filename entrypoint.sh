#!/bin/bash
set -eu

# setup logdir
mkdir -p ${NGINX_LOG_DIR}
chmod -R 0755 ${NGINX_LOG_DIR}
chown -R ${NGINX_USER}:root ${NGINX_LOG_DIR}


# setup cache/tmp dir
mkdir -p ${NGINX_TMP_DIR}
chmod -R 0755 ${NGINX_TMP_DIR}
chown -R ${NGINX_USER}:root ${NGINX_TMP_DIR} 

exec nginx -c /etc/nginx/nginx.conf -g "daemon off;"

