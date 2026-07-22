# Ranking Setup Guide

## v1 release decision

The founder decided on 2026-07-22 that all seven iOS Game Center leaderboards are mandatory for v1. They must not be deferred to v1.1. iOS ranking remains a release blocker until the macOS/Xcode build, App Store Connect configuration, signed archive, physical iPhone, and TestFlight gates all pass.

## Current implementation

- Android uses a Godot Android plugin singleton named `GodotPlayGamesServices`.
- GDScript calls it through `RankingManager.gd`.
- Local best scores and pending online submissions are saved through `SaveData.gd`.
- Pending scores are cleared only after the native Android submit callback reports success.
- iOS uses the official Godot `GameCenter` singleton through `IOSGameCenterAdapter.gd`.
- The iOS adapter requires a persistent game-scoped player ID, submits one score at a time, correlates every completion by player and request ID, drains asynchronous plugin events, and prioritizes the leaderboard the player explicitly requested.
- iOS pending scores are stored in separate player-ID buckets. A score earned without a verified persistent identity remains unowned and is never assigned to a later account automatically.
- The pinned native plugin patch uses Apple's integer `GKLeaderboard.submitScore` API, verifies the expected player immediately before submission, and returns the player ID, request ID, leaderboard ID, and score on the main queue.
- Authentication, score, and leaderboard operations have recovery timeouts. Native Game Center presentation is rejected while another Apple view controller is open.
- The GDScript integration and pinned native plugin patch are implemented. The reproducible Windows contract harness passes 108 deterministic assertions.

Run the contract suite from the repository root on Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ios_gamecenter\run_contract_tests.ps1 -GodotExe 'E:\FileHistory\狼天紅\work\Godot_v4.6.2-stable_win64_console.exe'
```

Expected output includes `PASS: native authentication payload excludes alias/displayName` and `PASS: 108 deterministic iOS Game Center assertions`. The first gate ensures that the native authentication event returns only the game-scoped identifier needed by the app, not the player's Game Center display names. These checks validate the local API/state-machine contract, not Apple's runtime, signing, or service configuration.

## Files to update after Google Play Console setup

1. `android/build/src/main/res/values/play_games_services.xml`
   - Replace `0000000000` with the Google Play Games Services project ID.
   - This is shown under the game name on the Play Games Services configuration page.

2. `RankingManager.gd`
   - Android IDs live in `ANDROID_LEADERBOARD_IDS`. Keep the existing Google Play Console IDs mapped to the same seven stage keys.
   - iOS IDs live in `IOS_LEADERBOARD_IDS`. Create the exact seven IDs below in App Store Connect; never copy Android `Cgk...` IDs into the iOS map.

## iOS Game Center setup

Create seven **Classic** leaderboards with **Best Score**, **High to Low**, and an integer score format:

- `easy`: `com.nb0129.machiate.leaderboard.easy`
- `normal`: `com.nb0129.machiate.leaderboard.normal`
- `hard + mirage`: `com.nb0129.machiate.leaderboard.hardmirage`
- `Too easy`: `com.nb0129.machiate.leaderboard.tooeasy`
- `abnormal`: `com.nb0129.machiate.leaderboard.abnormal`
- `very hard + nightmare`: `com.nb0129.machiate.leaderboard.veryhardnightmare`
- `endless / instant`: `com.nb0129.machiate.leaderboard.endless`

Add Japanese, English, Simplified Chinese, Traditional Chinese, and Korean localizations. Do not submit the components until their ID mapping, ordering, score direction, display names, and review association have been checked.

On a Mac, run `tools/ios_gamecenter/build_gamecenter_plugin.sh`. It builds the pinned Godot plugin into `ios/plugins/gamecenter/` and records provenance and hashes. Keep `entitlements/game_center=false` while validating the plugin artifacts and all seven App Store Connect IDs. Then:

1. Enable the detected `GameCenter` plugin in the iOS export preset.
2. After plugin load and App Store Connect mapping are confirmed, enable the Game Center capability for the explicit App ID, provisioning profile, Xcode target, and Godot export preset.
3. Confirm the signed app's code-sign entitlements contain Boolean `com.apple.developer.game-center = true`, and verify the expected plugin/framework linkage.
4. Test authentication success, cancellation, restrictions, all seven score submissions, failed/offline retention, resume/relaunch retry, individual and aggregate leaderboard display, a second account/device, and TestFlight. Use at least two dedicated Game Center test accounts with no friend relationships; pre-release tests use the production Game Center server environment, so personal or public accounts can expose unreleased activity or scores to friends.
5. In the two-account test, create an unsent score under player A, switch to player B, and prove that A's score is never submitted or cleared while B is active. Switch back to A and confirm only A's bucket is retried.
6. Confirm that scores earned without a persistent player identity remain local/unowned and are not uploaded automatically after any account signs in.
7. Remove leaderboard test data before review. Enable Game Center on the first iOS app version, associate all seven leaderboard components, and use **Add for Review** so all seven components enter the same draft submission as the app version. Verify that no component is missing or remains Rejected / Developer Rejected.

Until the XCFrameworks, Apple configuration, signed archive, physical-device tests, and TestFlight all pass, iOS ranking remains a release blocker even though the GDScript/native contract and 108 deterministic Windows assertions are implemented. Do not release without the seven iOS leaderboards, and do not treat v1.1 as a fallback deferral.

## Leaderboards to create

Create these seven Google Play Games leaderboards:

- `easy`: `CgkI6s38m_cNEAIQAQ`
- `normal`: `CgkI6s38m_cNEAIQAg`
- `hard + mirage`: `CgkI6s38m_cNEAIQAw`
- `Too easy`: `CgkI6s38m_cNEAIQBA`
- `abnormal`: `CgkI6s38m_cNEAIQBQ`
- `very hard + nightmare`: `CgkI6s38m_cNEAIQBg`
- `endless / instant`: `CgkI6s38m_cNEAIQBw`

The names do not need to match exactly, but the IDs must be copied into the matching keys in `RankingManager.gd`.

## Android verification

After the project ID and leaderboard IDs are set:

```powershell
cd C:\Users\hskst\work\longtianhong\android\build
.\gradlew.bat assembleStandardDebug
```

Then test on an Android device or internal test build signed with a certificate registered in Play Games Services.
