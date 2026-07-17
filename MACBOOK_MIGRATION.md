# MacBook移行手順

このリポジトリの`main`は、MacBookへ移すための現在のクリーン版です。

## Macで最初に行うこと

1. Gitをインストールする。
2. Godot **4.6.2 stable**をインストールする。
3. ターミナルで次を実行する。

```sh
git clone https://github.com/NB0129/longtianhong.git machiate
cd machiate
git status
```

`git status`が`working tree clean`なら、正しく取得できています。

4. Godotで`project.godot`を開く。

## iPhone版の作業を始める時

- XcodeをApp Storeからインストールする。
- Apple Developer Programへのログイン、署名、証明書はMac側で設定する。
- Mac固有の署名ファイルや設定はGitへ入れない。

## Gitへ入れないもの

次はPC固有または自動生成物なので、Git管理しません。

- `.godot/`
- `android/build/`の自動生成物
- `keystore/`
- `android/build/local.properties`
- `assets/language/generated_sheets/`
- `tools/`のプレビュー画像

## 日常の更新

Macで変更したら、次の順番でGitHubへ保存します。

```sh
git status
git add -A
git commit -m "変更内容"
git push origin main
```

Windows側へ戻す時は、同じリポジトリで`git pull origin main`を実行します。

## 注意

古い`master`は過去の履歴として残しています。新しい開発・Mac移行では使わず、必ず`main`を使ってください。
