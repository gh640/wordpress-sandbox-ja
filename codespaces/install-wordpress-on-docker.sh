#!/usr/bin/bash
WP_URL="https://${CODESPACE_NAME}-80.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
WP_ADMIN_USER="admin"
WP_ADMIN_EMAIL="example@example.com"
WP_ADMIN_PASSWORD="password"

docker compose exec -u www-data wordpress \
  wp core install \
  --url="$WP_URL" \
  --title="WordPress サンドボックス" \
  --admin_user="$WP_ADMIN_USER" \
  --admin_email="$WP_ADMIN_EMAIL" \
  --admin_password="$WP_ADMIN_PASSWORD" \
  --skip-email
