# Android実機・Google Play公開手順

## 現在の基準

- package: `com.nb0129.machiate`
- release AAB export: `build/machiate-release.aab`
- ADB: `C:\Users\langt\AppData\Local\Android\Sdk\platform-tools\adb.exe`
- 過去の`longtianhong`名や古いdebug APKを現行release証拠として使わない。実機試験前に現在のHEADから新しいdebug APKをexportする。
- Android v1のbuild基準はAGP 8.9.2、Gradle 8.11.1、compile/target SDK 36、Build Tools 36.1.0、Java 17、arm64-v8aである。
- Godot 4.6.2の従来の戻る通知をAndroid 16でも維持するため、Applicationで`android:enableOnBackInvokedCallback="false"`を明示する。Godot 4.6.3以降のAndroid templateへ移行して戻る操作を再試験するまでは外さない。
- 提出候補AABごとにBundletool validation、merged Manifestのpackage/version/target SDK、16KB zip alignment、全arm64 native libraryのPT_LOAD alignmentを確認する。

## Android IAP release gate（2026-08-09決定）

- Android v1から、Music Roomとゲーム内BGM全21曲を解放する非消費型商品`support_pack`を正式採用する。
- Google Playでは「1回限りのアイテム」/ Buy purchase optionとして作成し、Product IDを`support_pack`、purchase option IDを`standard`にする。レンタル、複数数量、割引オファーは使わない。
- 2026-08-09のPlay Console確認では、既存の`support_pack`に有効な`standard`があり、日本価格JPY 500、Google Play対応の173か国 / 地域すべてが価格設定済み・利用可能。
- `IAP_SUPPORT_GUIDE.md`記載の5言語の商品名・説明をPlay Consoleへ保存済み。税区分はデジタルアプリの販売、年齢制限なし、支払い地域制限なし、追加の商品アイコンなし。
- 商品と`standard`の有効化は完了。Payments profile・税務・merchant状態を提出前に別途確認し、署名済みAABをInternal testingへ進める。
- 実課金試験は、`com.nb0129.machiate`の署名済みAABをInternal testingへ公開し、Google Playからインストールしたライセンステスター端末で行う。別packageのsideload debug APKは実課金試験の証拠にしない。
- 購入成功、キャンセル、保留、復元、再起動、再インストール、別端末、返金・権利取消後の再照合を確認する。Music Room以外のゲーム本編を購入で制限しない。

## 実機へ入れる

1. Android端末をUSB接続し、USB debuggingを有効にする。
2. 現在のHEADからdebug APKを`build/machiate-debug-current.apk`へexportする。
3. 次を実行する。

```powershell
$adbPath = 'C:\Users\langt\AppData\Local\Android\Sdk\platform-tools\adb.exe'
$apkPath = 'C:\Users\langt\Documents\Codex\2026-07-15\rotenko-games-coo-chief-of-staff\work\machiate-clean-baseline\build\machiate-debug-current.apk'
& $adbPath devices -l
& $adbPath install -r $apkPath
& $adbPath shell monkey -p com.nb0129.machiate -c android.intent.category.LAUNCHER 1
```

`unauthorized`と表示された場合は端末をunlockし、USB debuggingの許可を承認してから再実行する。

## Google Playアカウント方針（2026-07-22決定）

- 公開には既存のGoogle Play **organization account**を使う。
- 所有者は、同じorganization accountの別アプリでProduction公開が可能なことを確認済み。
- Google公式の12 testers / 14 consecutive days要件は、2023-11-13より後に作成されたpersonal developer accountが対象である。このため、本アプリではmandatory release gateにしない。
- ただし、実機・internal test・通常の新規アプリ審査、Data safety、content declarations、Play Games Services設定は省略しない。
- Play Consoleでaccount typeがOrganizationであることとProductionメニューが利用可能であることを、本アプリの提出前にも再確認する。
- Organization accountでは、verified developer phone numberとdeveloper emailがGoogle Playの公開developer profile / listingに表示される。これはEU availabilityに限定された要件ではない。2026-07-23のPlay Console read-only確認で、Google-only contact phoneとは別のpublic developer phoneとdeveloper emailが設定・認証済みであることを確認した。実値はrelease証跡へ記録しない。現在のpublic developer phoneをそのまま公開する所有者承認、または明示承認された継続利用可能なbusiness phoneへの差し替えが完了するまではGoogle releaseを不可とする。
- Organization name / addressはlinked Google Payments profileおよびD-U-N-S情報と一致する必要がある。同じread-only確認でlegal organization name / addressとverified websiteの設定を確認したが、公開previewの所有者確認は残す。
- `com.nb0129.machiate`は2026-07-23のAndroid developer verification画面で`登録済み`（画面上の最終更新2026-07-05）を確認した。package registration gateは完了済みとし、2026-09-30 rolloutに向けたdeveloper identity / legal informationの正確性と継続維持を別gateとして残す。
- v1はEU加盟国を配信対象から除外しない。以前の「EU 27か国を除外する」方針は2026-07-23に撤回済み。提出前にEUを含む予定配信国・地域が選択されていることと、Google Playの公開連絡先・compliance表示を確認する。organization accountのdeveloper phone公開はEU availabilityとは無関係である。

Google公式確認先:

- Personal-account testing requirement: https://support.google.com/googleplay/android-developer/answer/14151465
- Organization-account public contact requirements: https://support.google.com/googleplay/android-developer/answer/10840893
- Managing organization developer information: https://support.google.com/googleplay/android-developer/answer/13634081
- Keeping organization developer information current: https://support.google.com/googleplay/android-developer/answer/13634888
- Developer verification / package registration: https://support.google.com/googleplay/android-developer/answer/16984799
