# memo_app
## About
シンプルなメモアプリです。メモの新規登録、編集、削除を行うことができます。
## Quick Start
以下をターミナル上で実行して任意の場所にリポジトリをクローンしてください。
```
git clone -b develop https://github.com/ham-cap/memo_app.git

```
## Gems
memo_appが動作するにはGemfileに書かれたGemのインストールが必要です。以下を実行してください。
```
bundle install
```

## データベースの設定
このアプリではPostgreSQLを使用します。
PostgreSQLをインストールし、任意のスーパーユーザーとしてログインのうえ、以下を実行してください。
```
CREATE ROLE memoapp WITH LOGIN;
CREATE DATABASE memodb;
```
ターミナルに戻り、memo_appディレクトリ内で以下を実行してください。
```
psql -U memoapp -d memodb -f to_set_up_local_db.sql;
```

## memo_appの起動
ローカルサーバー上で起動するため、以下を実行してください。
```
bundle exec ruby memo_app.rb 
```

## 以下のURLにアクセスしてください。
```
http://localhost:4567/
```
