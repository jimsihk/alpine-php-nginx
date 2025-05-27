#!/usr/bin/env sh
cat /etc/nginx/nginx.conf
curl --silent --fail http://app:8080 | grep '8.3'
