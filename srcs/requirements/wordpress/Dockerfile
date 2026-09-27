FROM debian:bookworm

# Install PHP-FPM, PHP extensions WordPress needs, and tools to fetch wp-cli
RUN apt-get update && apt-get install -y php-fpm \
    php-mysqli \
    php-gd \
    php-curl \
    php-xml \
    php-mbstring \
    php-zip \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download wp-cli — the tool we'll use to install/configure WordPress via script
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy our config and entrypoint script in
COPY conf/wordpress.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["wp_setup.sh"]