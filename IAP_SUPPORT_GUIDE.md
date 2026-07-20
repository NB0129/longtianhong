# 開発支援 IAP 実装メモ

> Conditional readiness: v1 で IAP を採用するか、価格、販売国は所有者判断待ち。このパッチは採用決定ではなく、採用時に必要な安全な接続経路を staging する。

## 商品

- 種別: Non-Consumable
- Product ID: `support_pack`
- 日本語表示名候補: `開発支援パック`
- 英語表示名候補: `Support Pack`
- 日本語説明候補: `Music Roomでゲーム内BGM全21曲を聴けるようになります。`
- 英語説明候補: `Unlock the Music Room and listen to all 21 in-game BGM tracks.`
- 価格: 未決定
- 販売国: 未決定

これは非消費型デジタル商品で、固定特典はゲーム内 Music Room の解放である。寄付・投資・将来作品への対価として販売せず、購入画面でもデジタル特典を正面に表示する。

`SaveData.is_supporter` は端末キャッシュであり、最終的な正は App Store の購入履歴である。

## 購入 backend

`SupportPurchase.gd` は backend を次の順で選ぶ。

1. 既存 Android billing bridge（singleton 名と contract は互換性のためコード内で維持）
2. Godot iOS plugin singleton: `InAppStore`
3. backend がない release build: fail closed。購入権を付与しない

Android bridge の既存メソッド、signal、状態機械は変更しない。iOS は独自 bridge を新設せず、Godot の documented `InAppStore` API に合わせる。

この `InAppStore` 経路は fallback / integration readiness であり、本番 IAP 完了を意味しない。plugin binary の Godot 4.6 適合、Apple sandbox、relaunch、refund / revocation を Mac で通すまでは fail closed の release gate を維持する。

## InAppStore API

起動時に `Engine.has_singleton("InAppStore")` / `Engine.get_singleton("InAppStore")` で取得し、必要なメソッドがすべて存在する場合だけ有効にする。

- `request_product_info({"product_ids": ["support_pack"]})`
- `purchase({"product_id": "support_pack"})`
- `restore_purchases()`
- `set_auto_finish_transaction(true)`
- `get_pending_event_count()`
- `pop_pending_event()`

非同期メソッドが返す `Error` は開始受付だけを示す。`OK` の場合も完了ではないため、毎 frame event queue を poll して terminal event まで待つ。成功 transaction は auto-finish を有効にしてから購入を開始する。

`restore_purchases()` は、ユーザーが「購入を復元」を押した場合だけ呼ぶ。起動・復帰時の `refresh_entitlements()` は資格情報 prompt を誘発し得る自動 restore を行わず、現在の端末キャッシュを維持して `state_changed` のみ通知する。

## Event の扱い

- `type=product_info`, `result=ok`: `ids` から `support_pack` の index を探し、同じ index の `localized_prices` を優先、なければ `prices` を表示する。商品または価格がなければ購入を有効にしない
- `type=purchase`, `result=progress`: terminal ではないため待つ
- `type=purchase`, `result=ok`: `product_id` が `support_pack` と一致した場合だけ所有を付与する
- `type=restore`, `result=ok`: 一致する item ごとに購入済みを記録する。一致しない Product ID は無視する
- `type=completed`、または restore の `result=completed`: restore の terminal。item が 1 件もなければ「購入履歴 0 件」として未所有を確定する
- `result=error` / `unhandled`、または generic `type=error`: 対応中の処理を失敗で終了し、未完了のまま busy に残さない

購入済み item は受信時に verified ownership として反映する。0 件の完了で false にできるのは、query 開始後に新しい所有結果が入っていない場合だけである。購入成功や別の新しい query で ownership revision が進んだ場合、遅い 0 件 restore は新しい true を取り消さない。restore error はキャッシュを false にしない。

event API には request ID がないため、明示 restore は 1 件だけ進行させる。同一 frame に複数 event がある場合は queue を順に drain し、terminal 後の余剰 event は新しい処理に転用しない。

## 自動 entitlement 再検証の P0 gate

Apple は restore をユーザーの明示操作に対応させるよう案内しており、従来の `SKPaymentQueue.restoreCompletedTransactions()` は deprecated である。現在の documented `InAppStore` plugin API だけでは StoreKit 2 の current entitlements を取得できない。そのため、次のどちらかを実装・実機検証するまでは、relaunch、返金、revocation を正しく反映できる本番 IAP とみなさない。

- StoreKit 2 `Transaction.currentEntitlements` を公開する更新済み iOS adapter
- App Store server-side verification と entitlement 同期

`AppStore.sync()` はユーザーが明示的に account data を同期するための手段であり、自動起動処理の代替として呼ばない。

Godot SDK Integrations の [godot-storekit2](https://github.com/godot-sdk-integrations/godot-storekit2) は product の `is_purchased` と refund 等の transaction state を扱える候補だが、README 自身が API unstable / ongoing development としている。最新 release v0.2 の Godot 4.6 適合はこの環境では未証明なので、採用または独自 bridge 化は Mac 試験必須の P0 のままとする。binary はこの staging に download / vendor しない。

## 公式資料

- [Godot 4.6: Plugins for iOS](https://docs.godotengine.org/en/4.6/tutorials/platform/ios/plugins_for_ios.html)
- [godot-ios-plugins: InAppStore README (raw)](https://raw.githubusercontent.com/godotengine/godot-ios-plugins/master/plugins/inappstore/README.md)
- [Apple: Restoring purchased products](https://developer.apple.com/documentation/storekit/restoring-purchased-products)
- [Apple: SKPaymentQueue.restoreCompletedTransactions()](https://developer.apple.com/documentation/storekit/skpaymentqueue/restorecompletedtransactions())
- [Apple: AppStore.sync()](https://developer.apple.com/documentation/storekit/appstore/sync())
- [Godot SDK Integrations: godot-storekit2](https://github.com/godot-sdk-integrations/godot-storekit2)

Godot 4.6 のページには内容が当該版向けに未更新の可能性があるという注意がある。実際に採用する plugin binary の互換性は Mac export で確認する。

## 検証境界

workspace の headless mock test では以下を検証する。

- product info の request / success / error
- purchase の progress / success / error / Product ID mismatch
- restore item + completed、0 件 completed、error
- 0 件 restore による stale cache の解消
- 進行中 restore より新しい purchase が true を維持すること
- 起動・復帰時の entitlement refresh が restore request を発生させないこと
- auto-finish の設定

次は未完了で、release gate のまま残す。

- Mac / Xcode export
- Godot 4.6 と採用 plugin binary の適合・singleton load
- App Store Connect の商品状態、契約、価格
- StoreKit Configuration / Apple sandbox / TestFlight
- StoreKit 2 current entitlements または server-side verification
- signing、provisioning、実機、返金・revocation

この準備では plugin の download / vendoring、Team ID、sign identity、profile、Game Center を変更しない。
