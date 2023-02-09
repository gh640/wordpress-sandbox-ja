#!/usr/bin/bash
WP_URL="https://${CODESPACE_NAME}-80.githubpreview.dev"
WP_ADMIN_USER="admin"
WP_ADMIN_EMAIL="example@example.com"
WP_ADMIN_PASSWORD="password"

exec docker compose exec wordpress \
  wp --allow-root core install \
  --url="$WP_URL" \
  --title="WordPress サンドボックス" \
  --admin_user="$WP_ADMIN_USER" \
  --admin_email="$WP_ADMIN_EMAIL" \
  --admin_password="$WP_ADMIN_PASSWORD" \
  --skip-email
