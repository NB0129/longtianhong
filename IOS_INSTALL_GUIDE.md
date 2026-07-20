# 「まちあて！」を iPhone 実機へ入れる手順

> Conditional readiness: この手順は v1 で IAP を採用する決定ではない。IAP 採否、価格、販売国は所有者判断待ちである。採用する場合に備えた export / integration 準備だけを扱う。

## 必要なもの

- Mac
- Xcode
- Godot 4.6 と対応する Export Templates
- Apple ID / Apple Developer Team
- iPhone と接続用ケーブル
- 使用する Godot 4.6.x の exact tag と互換性を実証した `InAppStore` plugin binary、または検証済み StoreKit 2 adapter

このリポジトリには iOS 課金 plugin binary を同梱しない。取得、build、バージョン適合確認、導入は Mac 上で別途行う。

## 1. Mac にプロジェクトを移す

`machiate-clean-baseline` フォルダごと Mac にコピーし、Godot 4.6 で `project.godot` を開く。

## 2. Export Templates を入れる

`Editor > Manage Export Templates` を開き、使用する Godot 4.6 と同じバージョンのテンプレートをインストールする。

## 3. InAppStore plugin を有効化する

Godot の公式 iOS plugin 手順に従い、Mac 上で `InAppStore` plugin をプロジェクトへ導入して iOS export preset で有効化する。Godot 実行時に `Engine.has_singleton("InAppStore")` が true になることを確認する。

- Godot 4.6: [Plugins for iOS](https://docs.godotengine.org/en/4.6/tutorials/platform/ios/plugins_for_ios.html)
- 公式 plugin repository: [InAppStore README (raw)](https://raw.githubusercontent.com/godotengine/godot-ios-plugins/master/plugins/inappstore/README.md)
- legacy prebuilt の公開状況: [godot-ios-plugins releases](https://github.com/godot-sdk-integrations/godot-ios-plugins/releases)

Godot 4.6 の上記ドキュメントには「この版向けに未更新の可能性がある」という注意書きがある。legacy repository の公開済み prebuilt release は Godot 3.5 までしか互換性を証明しないため、その binary を Godot 4.6 へ流用しない。採用する場合は使用中の exact Godot 4.6.x tag に合わせて source build するか、別の StoreKit 2 adapter を選び、Mac export・singleton load・sandbox 実機試験で互換性を実証する。

## 4. iOS Export Preset を確認する

`Project > Export... > iOS` で次を確認する。

- Bundle Identifier: `com.nb0129.machiate`
- Version: `1.0.0`
- Build: `2`
- Export path: `ios_export/machiate.zip`
- Base icon: `res://assets/app_icon/machiate_launcher_432.png`

Version / Build は Android と揃えているが、App Store Connect に同じ build 番号が存在しないことを組織化完了後に確認する。

Base icon は既存の 432×432 RGB / 不透明 PNG を指定している。可能なら native 1024×1024 master を用意する。現素材を使う場合は、Godot exporter が生成する App Store 用 1024×1024 icon の輪郭、余白、色、アルファを Mac / Xcode の asset catalog で目視確認する。dark / tinted icon は未指定のままにする。

次の値は環境固有または別機能なので、この準備パッチでは変更していない。

- App Store Team ID
- code-sign identity
- provisioning profile
- Game Center entitlement（v1 は `false` を維持。専用 adapter / iOS ID / 実機検証なしに有効化しない）

## 5. Xcode プロジェクトとして書き出す

Export 画面で `Export Project` を押し、`ios_export/machiate.zip` を作る。zip を展開し、中の `.xcodeproj` を Xcode で開く。

## 6. Signing を設定する

Xcode で `Signing & Capabilities` を開く。

- `Automatically manage signing` を必要に応じて有効にする
- `Team` に対象の Apple Developer Team を選ぶ
- Bundle Identifier が `com.nb0129.machiate` であることを確認する
- IAP 採用決定後に限り、App Store Connect 側の商品 `support_pack` とアプリの契約・税務・銀行情報を確認する

Team ID、sign identity、profile は所有者の環境で決める。空欄をこの手順だけで推測して埋めない。

## 7. 実機と sandbox で確認する

iPhone を Mac に接続し、Xcode の実行先に選んで build / install する。その後、sandbox tester または StoreKit Configuration を使って次を確認する。

- 商品情報とローカライズ価格が表示される
- `support_pack` の購入成功、キャンセル、エラー
- 購入済み端末での復元
- 購入履歴 0 件の復元完了
- relaunch / resume で自動 restore や資格情報 prompt が発生しないこと
- offline、返金、revocation 時の失敗安全性
- exported 1024×1024 icon の見た目

Apple は restore をユーザーの明示操作に対応させるよう案内しているため、起動・復帰時に `restore_purchases()` を呼ばない。現行 adapter はその場合に端末キャッシュを維持する。relaunch、返金、revocation を本番品質で再検証するには、StoreKit 2 `currentEntitlements` または server-side verification を追加することが P0 release gate である。

- Apple: [Restoring purchased products](https://developer.apple.com/documentation/storekit/restoring-purchased-products)
- Apple: [AppStore.sync()](https://developer.apple.com/documentation/storekit/appstore/sync())

Windows headless mock は API/state machine だけを検証する。Mac / Xcode export、plugin binary のロード、Apple sandbox、StoreKit 2 または server verification、署名、実機、exported icon の目視確認は未完了の release gate である。
