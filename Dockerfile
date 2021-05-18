FROM php:5.6-apache

ENV MYSQL_ROOT_USER=""
ENV MYSQL_ROOT_PASSWORD=""
ENV MYSQL_HOST=""
ENV MYSQL_PORT=""
ENV YKVAL_VERIFIER_DB_PASSWORD=""

ENV TZ=Europe/Prague
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    software-properties-common \
    mysql-client \
    ntp

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# pecl/mcrypt requires PHP (version >= 7.2.0, version <= 8.0.0, excluded versions: 8.0.0)
# RUN apt-get install -y libmcrypt-dev
# RUN pecl install mcrypt-1.0.3 && docker-php-ext-enable mcrypt

# Install extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Enable RewriteEngine on
# RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
RUN a2enmod rewrite
RUN ln -s /usr/local/bin/php /usr/bin/php

RUN mkdir /yubico
COPY ./yubikey-val /yubico/yubikey-val

# ykval install
RUN cd /yubico/yubikey-val && /usr/bin/make install && /usr/bin/make symlink
# ykval config files
# COPY conf/ykval-config-db.php /etc/yubico/val/config-db.php
COPY conf/ykval-config.php /etc/yubico/val/ykval-config.php
# ykval queue config
COPY ./conf/ykval-queue /etc/default/ykval-queue

# apache config for web
COPY apache/.htaccess /var/www/wsapi/2.0/.htaccess
COPY apache/.htaccess /var/www/wsapi/.htaccess

# apache host configs
COPY ./apache/ykval.conf /etc/apache2/conf-enabled/ykval.conf
COPY ./apache/security.conf /etc/apache2/conf-enabled/security.conf

# php configs
COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./php/harden.ini /usr/local/etc/php/conf.d/harden.ini
RUN echo "date.timezone=$TZ" > /usr/local/etc/php/conf.d/timezone.ini

RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www
RUN chmod -R 755 /usr/share/yubikey-val

COPY scripts/init_db.sh /root/init_db.sh

