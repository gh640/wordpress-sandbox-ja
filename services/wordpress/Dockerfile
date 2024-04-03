FROM php:8.2-apache

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
ARG PHP_INI_EXTRA=""
RUN cp "${PHP_INI_DIR}/${PHP_INI_FILE}" "${PHP_INI_DIR}/php.ini" && \
  echo "${PHP_INI_EXTRA}" >> "${PHP_INI_DIR}/php.ini"

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
  a2enmod expires headers rewrite

# WP-CLI をインストール
# See: https://github.com/moby/buildkit/pull/1492
ADD --chmod=755 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /opt/wp-cli/bin/wp
ENV PATH="${PATH}:/opt/wp-cli/bin"

# WP-CLI の設定ファイルを設置
# See: https://make.wordpress.org/cli/handbook/references/config/
COPY --chmod=755 ./wp-cli.yml /opt/wp-cli/
ENV WP_CLI_CONFIG_PATH="/opt/wp-cli/wp-cli.yml"

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

COPY --chown=www-data:www-data .htaccess-default .htaccess-extra ./
RUN cat .htaccess-extra .htaccess-default >> .htaccess && \
  rm .htaccess-extra .htaccess-default

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
