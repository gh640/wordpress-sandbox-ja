FROM php:8.1-apache

RUN apt-get update && \
  apt-get install -y \
    default-mysql-client \
    libmagickwand-dev \
    libfreetype6-dev \
    # For gmp PHP extension.
    libgmp-dev \
    # For intl PHP extension.
    libicu-dev \
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

# `php.ini` を用意
ARG PHP_INI_FILE="php.ini-development"
RUN cp "${PHP_INI_DIR}/${PHP_INI_FILE}" "${PHP_INI_DIR}/php.ini"

# PHP 拡張の設定
RUN docker-php-ext-configure exif && \
  # デフォルトの PNG に加えて FreeType JPEG WEBP をサポート
  docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
  docker-php-ext-configure intl && \
  docker-php-ext-configure mysqli && \
  docker-php-ext-configure opcache && \
  docker-php-ext-configure zip && \
  docker-php-ext-install -j"$(nproc)" \
    exif \
    gd \
    # GMP is optional.
    gmp \
    intl \
    mysqli \
    opcache \
    zip && \
  pecl install apcu imagick && \
  docker-php-ext-enable apcu imagick && \
  a2enmod headers rewrite

# WP-CLI をインストール
ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /opt/wp-cli/bin/wp
RUN chmod +rx /opt/wp-cli/bin/wp
ENV PATH="${PATH}:/opt/wp-cli/bin"

# `/var/www/html` のひとつ上の `/var/www` を使うことがあるのでそこから所有者を変更
RUN chown -R www-data:www-data /var/www

USER www-data

# WordPress をダウンロード
ARG WORDPRESS_VERSION="latest"
ARG WORDPRESS_LOCALE="en_US"
RUN wp core download \
  --locale="${WORDPRESS_LOCALE}" \
  --version="${WORDPRESS_VERSION}" \
  --path=/var/www/html

COPY --chown=www-data:www-data .htaccess ./

# `wp-config.php` を作成
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_HOST
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
