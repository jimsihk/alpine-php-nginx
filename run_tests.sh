#!/usr/bin/env sh
curl --silent --fail http://app:8080 | grep '8.4'
curl --silent --show-error --fail --output /dev/null --write-out '%{http_code}' http://app:8080/pre-php-test | grep -x '204'
