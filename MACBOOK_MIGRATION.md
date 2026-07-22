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
- v1公開に使う個人Apple Developer Program membershipへログインし、Team ID、署名、証明書、provisioning profileをMac側で設定する。
- App Store Connectで表示される個人の法的seller/developer名を確認する。`IOS_INSTALL_GUIDE.md`記載のEU 27か国をv1 availabilityからすべて除外し、保存後の一覧を証跡化する。
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
