#!/bin/sh
docker run --name nginx \
  --publish 80:80 \
  daisaru11/nginx:0.1
