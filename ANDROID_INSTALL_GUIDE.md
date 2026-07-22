# Android実機・Google Play公開手順

## 現在の基準

- package: `com.nb0129.machiate`
- release AAB export: `build/machiate-release.aab`
- ADB: `C:\Users\langt\AppData\Local\Android\Sdk\platform-tools\adb.exe`
- 過去の`longtianhong`名や古いdebug APKを現行release証拠として使わない。実機試験前に現在のHEADから新しいdebug APKをexportする。

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
- v1はEU 27か国（`AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE`）を配信対象から除外する。保存後・提出直前に除外国一覧を証跡化し、提出時点のGoogle Playの国一覧に変更があればその公式一覧を優先する。ただし、この地域除外によってorganization accountのdeveloper phone公開は回避できない。EU追加は各platformのcomplianceを再確認する将来の別scopeとする。

Google公式確認先:

- Personal-account testing requirement: https://support.google.com/googleplay/android-developer/answer/14151465
- Organization-account public contact requirements: https://support.google.com/googleplay/android-developer/answer/10840893
- Managing organization developer information: https://support.google.com/googleplay/android-developer/answer/13634081
- Keeping organization developer information current: https://support.google.com/googleplay/android-developer/answer/13634888
- Developer verification / package registration: https://support.google.com/googleplay/android-developer/answer/16984799
