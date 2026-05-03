#!/bin/sh

set -eu

shutdown() {
  _status="${1:-0}"
  echo "shutting down container"

  if [ -n "${NGINX_PID:-}" ]; then
    kill "$NGINX_PID" 2>/dev/null || true
  fi

  if [ -n "${PHP_FPM_PID:-}" ]; then
    kill "$PHP_FPM_PID" 2>/dev/null || true
  fi

  wait "${NGINX_PID:-}" 2>/dev/null || true
  wait "${PHP_FPM_PID:-}" 2>/dev/null || true
  exit "$_status"
}

render_template() {
  _config_file="$1"

  php -n /dev/stdin "$_config_file" <<'PHP'
<?php
$file = $argv[1];
$contents = file_get_contents($file);

if ($contents === false) {
    fwrite(STDERR, "Failed to read $file\n");
    exit(1);
}

$environment = getenv();
$names = array_keys($environment);
usort($names, static fn($left, $right) => strlen($right) <=> strlen($left));

if ($names !== []) {
    $escapedNames = array_map(static fn($name) => preg_quote($name, '/'), $names);
    $pattern = '/\$\{(' . implode('|', $escapedNames) . ')(?::-([^}]*))?\}|\$(' . implode('|', $escapedNames) . ')\b/';
    $contents = preg_replace_callback(
        $pattern,
        static function (array $matches) use ($environment): string {
            $name = $matches[1] !== '' ? $matches[1] : $matches[3];
            $value = $environment[$name] ?? '';

            if ($matches[1] !== '' && array_key_exists(2, $matches) && $matches[2] !== '' && $value === '') {
                return $matches[2];
            }

            return $value;
        },
        $contents
    );
}

if (file_put_contents($file, $contents) === false) {
    fwrite(STDERR, "Failed to write $file\n");
    exit(1);
}
PHP
}

for _configini in $envsubst_config_list; do
  if [ -f "$_configini" ]; then
    echo "Setting up $_configini..."
    render_template "$_configini"
  fi
done

echo "Starting startup scripts in /docker-entrypoint-init.d ..."
find /docker-entrypoint-init.d/ -type f -perm -111 | sort | while read -r script; do
  echo >&2 "*** Running: $script"
  "$script"
done
echo "Finished startup scripts in /docker-entrypoint-init.d"

if [ $# -gt 0 ]; then
  exec "$@"
fi

trap 'shutdown 0' SIGTERM SIGHUP SIGQUIT SIGINT

php-fpm -F &
PHP_FPM_PID=$!

nginx -g 'daemon off;' &
NGINX_PID=$!

while kill -0 "$PHP_FPM_PID" 2>/dev/null && kill -0 "$NGINX_PID" 2>/dev/null; do
  sleep 1
done

status=0
wait "$PHP_FPM_PID" || status=$?
wait "$NGINX_PID" || [ "$status" -ne 0 ] || status=$?

shutdown "$status"
