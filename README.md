# WordPress サンドボックス

最新の WordPress を気軽に試すための Docker / Docker Compose 設定です。

## 動作確認時の環境

- Docker 20.10.7
- Docker Compose 2.0.0-beta.6

## 内容物

- Apache 2.4
- PHP 7.4
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

コンテナを起動するとポート `8000` で WordPress が起動するのでブラウザからインストール操作を行います。

- データベース名: `wp`
- ユーザー名: `wp`
- パスワード: `wp`
- データベースのホスト名: `db`
- テーブル接頭辞: `wp_` （他のものでも OK ）

#### GitHub Codespaces を使う場合

GitHub Codespaces でプレビューを利用する場合は URL が異なるのでプラスアルファの手間が必要です。

`home` と `siteurl` を `localhost` から実際の URL に変更します。

```bash
docker compose exec wordpress bash
```

```bash
wp --allow-root option update home 'https://xxx.githubpreview.dev'
wp --allow-root option update siteurl 'https://xxx.githubpreview.dev'
```

※ `xxx.githubpreview.dev` の部分は実際に発行された URL にします

リバースプロキシ関連の処理を `wp-config.php` に追加します。

```bash
docker compose exec wordpress vim wp-config.php
```

```php
if (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
  $_SERVER['HTTPS'] = 'on';
}
```

### 停止

```bash
docker compose down
```

### MariaDB ボリュームの削除

```bash
docker volume rm wordpress-sandbox-ja_db_data
```

### WP-CLI

コンテナに WP-CLI がインストールされています。

```bash
docker compose exec wordpress wp --allow-root
```

実行ユーザーが `root` のままなので `--allow-root` オプションを付ける必要があります。
