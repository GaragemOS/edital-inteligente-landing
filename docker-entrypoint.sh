#!/bin/sh
set -e

: "${PORT:=8080}"
export PORT

envsubst '${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

echo "[entrypoint] nginx listening on ${PORT}"

exec "$@"
