# Longtianhong を iPhone 実機に入れる手順

## 必要なもの

- Mac
- Xcode
- Godot 4.6
- Godot の Export Templates
- Apple ID
- iPhone と接続用ケーブル

## 1. Mac にプロジェクトを移す

`longtianhong` フォルダごと Mac にコピーする。

## 2. Godot で開く

Mac の Godot 4.6 で `project.godot` を開く。

## 3. Export Templates を入れる

Godot のメニューから以下を開く。

`Editor > Manage Export Templates`

未インストールなら、Godot 4.6 用のテンプレートをインストールする。

## 4. iOS Export Preset を確認する

`Project > Export...` を開く。

`iOS` プリセットが追加済みのはず。

以下を確認する。

- `Application > Bundle Identifier`
  - `com.nb0129.longtianhong`
- `Application > App Store Team ID`
  - 自分のApple Developer Team IDを入力する

Team ID はAppleアカウント固有。XcodeのSigning画面やApple Developerサイトで確認する。

## 5. Xcodeプロジェクトとして書き出す

Export画面で `Export Project` を押す。

出力先は例として以下。

`ios_export/Longtianhong.zip`

GodotのiOS出力はXcodeプロジェクトのzipになる。

## 6. Xcodeで開く

zipを展開し、中の `.xcodeproj` をXcodeで開く。

## 7. Signingを設定する

Xcodeでプロジェクトを選び、`Signing & Capabilities` を開く。

- `Automatically manage signing` をオン
- `Team` に自分のApple IDまたはDeveloper Teamを選ぶ
- Bundle Identifierが他のアプリと重複していたら変更する

無料Apple IDでも実機テストは可能だが、証明書の有効期限や機能に制限がある。

## 8. iPhoneへ入れる

iPhoneをMacに接続する。

Xcode上部の実行先に自分のiPhoneを選ぶ。

再生ボタンを押してビルド・インストールする。

## よくある詰まりどころ

- Godot側でTeam IDが空だとiOS exportでエラーになる。
- Team IDは名前ではなく、10文字程度のIDを入れる。
- Xcodeの初回起動時は追加コンポーネントや利用規約の同意が必要。
- `xcode-select` がCommand Line Tools側を向いていると失敗することがある。
- iOSシミュレータ向けのGodot exportは現時点で未対応。実機を使う。
