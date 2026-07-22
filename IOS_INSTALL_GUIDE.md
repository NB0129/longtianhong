# 「まちあて！」を iPhone 実機へ入れる手順

> Conditional readiness: この手順は v1 で IAP を採用する決定ではない。IAP 採否、価格、販売国は所有者判断待ちである。採用する場合に備えた export / integration 準備だけを扱う。

> iOSランキング方針（2026-07-22決定）: 7種類すべてのGame Centerランキングをv1に実装してからリリースする。v1.1への延期はしない。GDScript連携とnative plugin patch、および108項目のWindows deterministic contract testは実装済みだが、Mac / Xcode / App Store Connect / signed archive / iPhone実機 / TestFlightの確認が終わるまでリリース不可とする。

## 必要なもの

- Mac
- Xcode
- Godot 4.6 と対応する Export Templates
- Apple ID / Apple Developer Team
- iPhone と接続用ケーブル
- 使用する Godot 4.6.x の exact tag と互換性を実証した `InAppStore` plugin binary、または検証済み StoreKit 2 adapter
- `tools/ios_gamecenter/build_gamecenter_plugin.sh` からMac上で作る、使用中のGodot exact tag向けGame Center plugin binary

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

## 3A. Game Center plugin と契約テストを確認する

リポジトリルートで、まずWindowsの再現可能なcontract testを実行する。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ios_gamecenter\run_contract_tests.ps1 -GodotExe 'E:\FileHistory\狼天紅\work\Godot_v4.6.2-stable_win64_console.exe'
```

期待値は `PASS: 108 deterministic iOS Game Center assertions`。これはGDScriptとnative plugin間のAPI/state machineを検証するもので、iPhone上でApple Game Centerが動くことの証明ではない。

次にMacで `tools/ios_gamecenter/build_gamecenter_plugin.sh` を実行し、生成されたdebug/release XCFramework、`.gdip`、provenance、hashを確認する。GodotのiOS export presetで`GameCenter` pluginが検出・有効化でき、App Store Connectの7 IDとの対応まで検証できるまでは、`entitlements/game_center=false`を維持する。

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
- Game Center entitlement（現時点では `false` を維持。plugin build/load、7 ID、App Store Connect、signing設定を検証した後に限りv1用presetで有効化し、signed archiveで再確認する）

## 5. Xcode プロジェクトとして書き出す

Export 画面で `Export Project` を押し、`ios_export/machiate.zip` を作る。zip を展開し、中の `.xcodeproj` を Xcode で開く。

## 6. Signing を設定する

Xcode で `Signing & Capabilities` を開く。

- `Automatically manage signing` を必要に応じて有効にする
- `Team` に対象の Apple Developer Team を選ぶ
- Bundle Identifier が `com.nb0129.machiate` であることを確認する
- IAP 採用決定後に限り、App Store Connect 側の商品 `support_pack` とアプリの契約・税務・銀行情報を確認する
- Game Center pluginとApp Store Connectの7 leaderboard設定を検証した後、v1 targetにGame Center capabilityを追加し、provisioning profileとentitlementへ正しく反映されたことを確認する

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
- Game Center認証の成功・キャンセル・制限状態
- 7ランキングすべてへのscore送信、offline保留、再起動/復帰後のretry
- 個別ランキングと全体ランキングの表示・閉じる操作
- 2アカウントで未送信scoreが別アカウントへ送信・消去されないこと
- signed archiveのGame Center entitlementとplugin/framework linkage
- physical iPhoneとTestFlightで同じ一連の動作

Apple は restore をユーザーの明示操作に対応させるよう案内しているため、起動・復帰時に `restore_purchases()` を呼ばない。現行 adapter はその場合に端末キャッシュを維持する。relaunch、返金、revocation を本番品質で再検証するには、StoreKit 2 `currentEntitlements` または server-side verification を追加することが P0 release gate である。

- Apple: [Restoring purchased products](https://developer.apple.com/documentation/storekit/restoring-purchased-products)
- Apple: [AppStore.sync()](https://developer.apple.com/documentation/storekit/appstore/sync())

Windows headless contract suiteの108 assertionsはAPI/state machineだけを検証する。Mac / Xcode export、Game Center plugin binaryのbuild/load、App Store Connectの7 leaderboard、Apple sandbox、StoreKit 2またはserver verification、署名・signed archive、physical iPhone、TestFlight、exported iconの目視確認は未完了のrelease gateである。7種類のiOSランキングはv1必須なので、これらをv1.1へ先送りしてリリースしない。
