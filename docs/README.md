# WordPress サンドボックス

最新の WordPress を気軽に試すための Docker / Docker Compose 設定です。

## 動作確認時の環境

```bash
docker --version
Docker version 25.0.3, build 4debf41
```

```bash
docker compose version
Docker Compose version v2.24.6-desktop.1
```

## 内容物

- Apache 2.4
- PHP 8.2
- WordPress 日本語版 最新
- WP-CLI 最新

## 使い方

### 起動

```bash
# WordPress イメージをビルド
docker compose build

# MariaDB イメージのダウンロード
docker compose pull

# コンテナ起動
docker compose up -d
```

Docker volume に置いている `wp-content/uploads` の所有者が最初は `root` になってしまっているので、 `www-data` に変更する必要があります。

```bash
docker compose exec -u root wordpress chown -R www-data wp-content/uploads
```

コンテナを起動すると `localhost` のポート `80` で WordPress が起動するのでブラウザまたはターミナルでインストール操作を行います。

ブラウザからインストールする場合のイメージ:

![ブラウザからインストール](./assets/screenrecording-setup.gif)

ターミナルからインストールする場合のイメージ:

```bash
WP_URL="http://localhost"
WP_ADMIN_USER="admin"
WP_ADMIN_EMAIL="example@example.com"
WP_ADMIN_PASSWORD="password"

docker compose exec wordpress \
  wp --allow-root core install \
  --url="$WP_URL" \
  --title="WordPress サンドボックス" \
  --admin_user="$WP_ADMIN_USER" \
  --admin_email="$WP_ADMIN_EMAIL" \
  --admin_password="$WP_ADMIN_PASSWORD" \
  --skip-email
```

#### GitHub Codespaces を使う場合

GitHub Codespaces でプレビューを利用する場合は、 URL が `localhost` ではないので以下の対応が必要です。

##### GitHub Codespaces で必要な対応 1

`compose.yaml` ファイルの build args の `WP_CONFIG_EXTRA` のコメントアウトされた行を安コメントします。

```yaml
WP_CONFIG_EXTRA: "wp-config-extra-github-codespaces.txt"
```

##### GitHub Codespaces で必要な対応 2

WordPress のインストール手続きをブラウザではなくターミナルから行います。

イメージ:

```bash
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
```

`wp` は `wordpress` イメージにインストールされた WP-CLI です。

このコマンドはリポジトリ内の `codespaces/install-wordpress-on-docker.sh` に記述してあるので、上のコマンドの代わりにスクリプトを実行しても OK です。

```bash
./codespaces/install-wordpress-on-docker.sh
```

コンテナ起動直後に実行すると、 MySQL のプロセスが起動しきっておらずデータベース接続エラーが起こることがあります。
その場合は少し（数秒）待ってから再度コマンドを実行します。

ポートの公開設定（ Visibility ）が private だとブラウザでアクセスしたときに CSS などが正しく読み込まれないので、ポートの公開設定を public に変更します。

![ポートの公開設定を Public に変更](./assets/screenshot-github-codespaces-port.png)

管理画面にログインできます。

![ログイン](./assets/screenshot-login.png)

### 停止

触り終わったらコンテナを停止します。

```bash
docker compose down
```

### MariaDB ボリュームの削除

```bash
docker volume rm wordpress-sandbox-ja_db_data
```

もしくはコンテナ停止時にオプション `--volumes` をつけることでも削除できます。

```bash
docker compose down --volumes
```

### WP-CLI

コンテナに WP-CLI がインストールされています。

```bash
docker compose exec wordpress wp
```

## 関連情報

### ブログ記事

かんたんな説明記事を書きました。

- [GitHub Codespaces で WordPress を動かす方法
 | gotohayato.com](https://gotohayato.com/content/543/)

### 他プロジェクト

#### `wp-env`

WordPress コミュニティが `wp-env` という Node.js ベースの CLI ツールを提供しています。
`wp-env` はプラグインやテーマの開発・テストに有用な Docker ベースの環境をかんたんに立ち上げられる、 Docker / Docker Compose のラッパーです。

- [@wordpress/env | Block Editor Handbook | WordPress Developer Resources](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/)
- [@wordpress/env - npm](https://www.npmjs.com/package/@wordpress/env)

#### `wordpress` イメージ

Docker 公式の WordPress イメージです。

- [Docker](https://hub.docker.com/_/wordpress)
- [GitHub - docker-library/wordpress: Docker Official Image packaging for WordPress](https://github.com/docker-library/wordpress)
