#!/bin/sh
set -eux

CMD=$(basename $0)
if [ $# -ne 1 ]; then
	echo "Usage: ${CMD} build_config_name" 1>&2
	exit 1
fi

CONFIG_NAME=$1

cd $(dirname $0)/../

cp "build_config/${CONFIG_NAME}/modules" modules

docker build -t daisaru11/nginx:${CONFIG_NAME} .

rm modules
