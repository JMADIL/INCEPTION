#!/bin/sh
set -eu

if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=MA/ST=KH/O=42/CN=${DOMAIN_NAME:-ajamoun.42.fr}"
fi

exec "$@"