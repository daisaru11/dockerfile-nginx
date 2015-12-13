#!/bin/bash
set -eux


download_and_extract() {
    url=${1}
    destdir=${2}
    tarballdir=${3}

    tarball=${tarballdir}/$(basename ${url})

    if [ ! -f ${tarball} ]; then
        echo "Downloading ${url}..."
		mkdir -p $(dirname ${tarball})
        wget ${url} -O ${tarball}
    fi

    echo "Extracting ${tarball}..."
    mkdir -p ${destdir}
    tar -zxf ${tarball} --strip-components 1 -C ${destdir}
    rm -rf ${tarball}
}


echo 'Start installing...'

apt-get update
apt-get install -y wget build-essential libpcre3-dev libssl-dev


###
# Download
NGINX_DOWNLOAD_URL="http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
MODULE_LIST=$(cat "${NGINX_SRC_DIR}/modules")

TARBALL_TMP_DIR=${NGINX_SRC_DIR}/tmp

download_and_extract ${NGINX_DOWNLOAD_URL} ${NGINX_SRC_DIR}/nginx-${NGINX_VERSION} ${TARBALL_TMP_DIR}/nginx

i=0
for $module_url in ${MODULE_LIST}
do
	i=$(expr $i + 1)
	module_id=modules_${i}
	download_and_extract ${module_url} ${NGINX_SRC_DIR}/${module_id} ${TARBALL_TMP_DIR}/${module_id}
done

cd ${NGINX_SRC_DIR}/nginx-${NGINX_VERSION}

###
# Configure
configure_options="\
  --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --sbin-path=/usr/sbin \
  --http-log-path=${NGINX_LOG_DIR}/access.log --error-log-path=${NGINX_LOG_DIR}/error.log \
  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid \
  --with-http_ssl_module \
  --with-http_realip_module \
"
i=0
for $module_url in ${MODULE_LIST}
do
	i=$(expr $i + 1)
	module_id=modules_${i}
	configure_options="${configure_options} --add-module=${NGINX_SRC_DIR}/${module_id}"
done

./configure ${configure_options}

###
# Install
make && make install


###
# Clean up
rm -rf ${NGINX_SRC_DIR}/nginx-${NGINX_VERSION}
i=0
for $module_url in ${MODULE_LIST}
do
	i=$(expr $i + 1)
	module_id=modules_${i}
	rm -rf ${NGINX_SRC_DIR}/${module_id}
done
rm -rf ${TARBALL_TMP_DIR}

apt-get purge -y --auto-remove wget build-essential libpcre3-dev libssl-dev
rm -rf /var/lib/apt/lists/*

