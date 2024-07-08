## 概要

このシェルスクリプトは、Ubuntuサーバー上でWordPressを簡単にインストールおよび設定するためのスクリプトです。スクリプトの実行中に、いくつかの入力を求められるプロンプトが表示されます。また、HTTPSを有効にするオプションも提供されており、自動的に自己署名証明書を生成します。

## ファイル内容

- `install_wordpress.sh`: WordPressのインストールと設定を行うシェルスクリプト

## 使用方法

### 前提条件

- Ubuntuサーバーがセットアップされていること
- スクリプトを実行するための基本的なシェルアクセス権限があること

### 手順

1. スクリプトを実行可能にする

```bash
chmod +x install_wordpress.sh
```

2. スクリプトを実行する

```bash
sudo ./install_wordpress.sh
```

3. スクリプトの実行中に表示されるプロンプトに従い、必要な情報を入力します。

### 入力項目

- **WordPress Directory** (Default: `/srv/www`): WordPressをインストールするディレクトリ
- **Username of Database** (Default: `wordpress`): データベースのユーザー名
- **Password of Database** (空白の場合はランダムに生成されます): データベースのパスワード
- **Do you want to enable HTTPS connection?** (y/n): HTTPS接続を有効にするかどうか
- **HTTPS port** (Default: `443`): HTTPSのポート番号（HTTPSを有効にした場合のみ）
- **Do you also enable HTTP connection?** (y/n): HTTP接続も有効にするかどうか（HTTPSを有効にした場合のみ）
- **HTTP port** (Default: `80`): HTTPのポート番号

### インストール後の情報

インストールが完了すると、以下の情報が表示されます。

- インストールディレクトリ
- データベースのユーザー名
- データベースのパスワード
- WordPressのURL（HTTPまたはHTTPS）

また、インストール情報をテキストファイルとして保存するオプションも提供されます。

### 例

```bash
WordPress has been installed successfully!

---------------------------------
インストールディレクトリ: /srv/www/wordpress
データベースのユーザー名: wordpress
データベースのパスワード: randompassword123
WordPress URL: http://192.168.1.100:80
---------------------------------

インストール情報をテキストファイルとして保存しますか？(y/n): y
Installation information has been saved to wordpress_install_info.txt file. Please remove ASAP for security reasons.
```

## 注意事項

- このスクリプトは、デフォルト設定を前提としています。必要に応じて変更してください。
- セキュリティのため、保存されたインストール情報ファイルを迅速に削除してください。
- 実行中にMySQLのrootユーザーのパスワードや他の機密情報が含まれる可能性があるため、セキュリティに十分注意してください。
