FROM php:8.1-apache

RUN apt-get update && \
  apt-get install -y \
    default-mysql-client \
    less \
    libonig-dev \
    libpng-dev \
    libzip-dev \
    vim \
    zlib1g-dev \
    && \
  rm -rf /var/lib/apt/lists/*

# タイムゾーンの設定
RUN rm /etc/localtime && \
  ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# PHP 拡張の設定
RUN docker-php-ext-install zip mysqli gd exif opcache && \
  pecl install apcu && \
  docker-php-ext-configure zip && \
  docker-php-ext-configure mysqli && \
  docker-php-ext-configure gd && \
  docker-php-ext-configure exif && \
  docker-php-ext-enable apcu

# `php.ini` を用意
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# WP-CLI をインストール
ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /opt/wp-cli/bin/wp
RUN chmod +x /opt/wp-cli/bin/wp
ENV PATH="$PATH:/opt/wp-cli/bin"

# WordPress の最新版をダウンロード
RUN wp core download \
  --locale=ja \
  --version=latest \
  --path=/var/www/html \
  --allow-root

ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_HOST

# `wp-config.php` を作成
COPY wp-config-extra.txt /tmp/
RUN cat /tmp/wp-config-extra.txt | \
  wp config create \
  --dbname="$MYSQL_DATABASE" \
  --dbuser="$MYSQL_USER" \
  --dbpass="$MYSQL_PASSWORD" \
  --dbhost="$MYSQL_HOST" \
  --dbcharset=utf8mb4 \
  --dbcollate=utf8mb4_unicode_ci \
  --extra-php \
  --skip-check \
  --allow-root

RUN chown -R www-data:www-data .
