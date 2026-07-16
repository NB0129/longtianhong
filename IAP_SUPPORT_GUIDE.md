# 開発支援IAP 実装メモ

## 現在の状態

- Godot側のUIは本番用の入口に整理済み。
- `SupportPurchase.gd` をAutoLoadに追加済み。
- 開発支援バーを押すと「購入する」「購入を復元」が表示される。
- Windows / debug buildでは動作確認用に「購入する」で支援済み状態になる。
- release buildでネイティブStoreKitブリッジがない場合は、購入は有効化しない。

## App Store Connectで作る商品

- 種別: Non-Consumable
- Product ID: `support_pack`
- 表示名: `開発支援`
- 説明: `開発支援のお礼にMusicroomを開放します`
- 価格: 500円相当

## Godot側の入口

`SupportPurchase.gd`

- `SUPPORT_PRODUCT_ID := "support_pack"`
- 支援済みキャッシュ: `SaveData.is_supporter`
- Musicroom開放判定: `SupportPurchase.is_supporter()`

`SaveData.is_supporter` は購入結果のキャッシュ。最終的な正はAppleの購入履歴にする。

## iOS側で後から必要なブリッジ

Godotから `Engine.has_singleton("LongtianhongStoreKit")` を見ている。
iOS側に以下のメソッドを持つシングルトンを用意すれば接続できる。

- `purchase_support(product_id: String)`
- `restore_support(product_id: String)`
- `refresh_entitlements(product_id: String)`

iOS側の処理完了後、Godot側に以下を呼び返す。

- 購入完了:
  `SupportPurchase.complete_native_purchase(success, message, owns_product)`
- 復元完了:
  `SupportPurchase.complete_native_restore(success, message, owns_product)`
- 起動時/復帰時の購入状態確認:
  `SupportPurchase.complete_native_entitlement_check(owns_product)`

## 確認すること

- 未購入時: EXメニューの最下段が開発支援バー
- 購入後: Musicroomバーに差し替わる
- F3: デバッグ用に購入前へ戻る
- 復元成功時: Musicroomバーに差し替わる
- 本番ではAppleの購入履歴確認後にだけ `is_supporter` をtrueにする
