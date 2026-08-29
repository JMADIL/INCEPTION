FROM debian:bookworm

RUN apt-get update \
	&& apt-get install -y --no-install-recommends nginx openssl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY tools/nginx_setup.sh /usr/local/bin/nginx_setup.sh

RUN chmod +x /usr/local/bin/nginx_setup.sh \
	&& mkdir -p /etc/nginx/ssl /var/www/wordpress \
	&& rm -f /etc/nginx/sites-enabled/default

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx_setup.sh"]
CMD ["nginx", "-g", "daemon off;"]