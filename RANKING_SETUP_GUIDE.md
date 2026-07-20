# Ranking Setup Guide

## Current implementation

- Android uses a Godot Android plugin singleton named `GodotPlayGamesServices`.
- GDScript calls it through `RankingManager.gd`.
- Local best scores and pending online submissions are saved through `SaveData.gd`.
- Pending scores are cleared only after the native Android submit callback reports success.

## Files to update after Google Play Console setup

1. `android/build/src/main/res/values/play_games_services.xml`
   - Replace `0000000000` with the Google Play Games Services project ID.
   - This is shown under the game name on the Play Games Services configuration page.

2. `RankingManager.gd`
   - Android IDs live in `ANDROID_LEADERBOARD_IDS`. Keep the existing Google Play Console IDs mapped to the same seven stage keys.
   - `IOS_LEADERBOARD_IDS` is intentionally empty and the iOS export keeps `entitlements/game_center=false`. Do not copy Android `Cgk...` IDs into it.
   - Enabling iOS rankings requires a separately implemented and device-tested Game Center adapter for Godot's dictionary-based `show_game_center` / `post_score` API, App Store Connect leaderboard IDs, capability, signing, and TestFlight validation.

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
