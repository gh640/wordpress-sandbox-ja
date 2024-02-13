FROM php:8.1-apache

RUN apt-get update && \
  apt-get install -y \
    default-mysql-client \
    libfreetype6-dev \
    # For gmp PHP extension.
    libgmp-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    zlib1g-dev \
    && \
  rm -rf /var/lib/apt/lists/*

# タイムゾーンの設定
ENV TZ "Asia/Tokyo"
RUN rm /etc/localtime && \
  ln -s "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata

# PHP 拡張の設定
RUN docker-php-ext-configure exif && \
  # デフォルトの PNG に加えて FreeType JPEG WEBP をサポート
  docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
  docker-php-ext-configure mysqli && \
  docker-php-ext-configure opcache && \
  docker-php-ext-configure zip && \
  docker-php-ext-install -j"$(nproc)" \
    exif \
    gd \
    # GMP is optional.
    gmp \
    mysqli \
    opcache \
    zip && \
  pecl install apcu && \
  docker-php-ext-enable apcu && \
  a2enmod headers

ARG PHP_INI_FILE="php.ini-development"

# `php.ini` を用意
RUN cp "${PHP_INI_DIR}/${PHP_INI_FILE}" "${PHP_INI_DIR}/php.ini"

# WP-CLI をインストール
ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /opt/wp-cli/bin/wp
RUN chmod +rx /opt/wp-cli/bin/wp
ENV PATH="${PATH}:/opt/wp-cli/bin"

# `/var/www/html` のひとつ上の `/var/www` を使うことがあるのでそこから所有者を変更
RUN chown -R www-data:www-data /var/www

USER www-data

# WordPress の最新版をダウンロード
RUN wp core download \
  --locale=ja \
  --version=latest \
  --path=/var/www/html

ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_HOST

# `wp-config.php` を作成
COPY wp-config-extra.txt /tmp/
RUN wp config create \
  --dbname="${MYSQL_DATABASE}" \
  --dbuser="${MYSQL_USER}" \
  --dbpass="${MYSQL_PASSWORD}" \
  --dbhost="${MYSQL_HOST}" \
  --dbcharset=utf8mb4 \
  --dbcollate=utf8mb4_unicode_ci \
  --skip-check \
  --extra-php \
  < /tmp/wp-config-extra.txt
