# Handoff

Last updated: 2026-06-29

This file is the short entry point for future Codex threads. Read this before opening older threads. Older image-generation threads can contain huge inline image payloads and may overflow the context window.

## Project

- Project path: `C:\Users\hskst\work\longtianhong`
- Engine: Godot 4.6.2 console binary at `C:\Users\hskst\work\Godot_v4.6.2-stable_win64_console.exe`
- Main game code is mostly in `game.gd`, `StageSelect.gd`, `title.gd`, `TalkScene.gd`, `SaveData.gd`, `AudioManager.gd`, and `RankingManager.gd`.
- Fixed operating rules live in `CODEX_NOTES.md`.
- Asset acceptance/rejection notes live in `ASSET_ADOPTION_STATUS.md`.

## First Steps For A New Thread

1. Read `CODEX_NOTES.md`, then this file.
2. Check `git status --short` before editing.
3. Do not bulk-read old image-generation threads. If history is needed, read one thread at a time and prefer summaries/previews.
4. Treat uncommitted changes as user/previous-thread work unless proven otherwise.
5. Do not read `引継ぎデータ.md` for current context. It is an early project note and is no longer needed for ongoing work.
6. While working, add durable handoff notes here when a decision, unfinished task, or project state would help a future thread continue safely.

## Current Working State

The worktree is not clean. Recent work includes asset/WebP conversion passes plus a tile-suit behavior change.

- `game.gd` now references many `assets/kao/*.webp` files instead of old PNG face assets.
- Matching old `assets/kao/*.png` and `.png.import` files are deleted.
- New `assets/kao/*.webp` and `.webp.import` files are present but untracked.
- `TalkScene.gd` now references `assets/chara/*.webp` for the remaining talk character PNGs.
- Matching old talk character PNGs and `.png.import` files are deleted.
- New `assets/chara/*.webp` and `.webp.import` files are present but untracked.
- `CODEX_NOTES.md` has recent additions about WebP conversion and shutdown command behavior.
- `TileSuitSelector.gd` has logic to disable `manzu2` when the current stage sorts the hand.
- `TalkScene.gd` sets `disable_manzu2_when_sorted_stage` for the settings tile selector.

Before committing or continuing, inspect the actual diff and verify the intended grouping. Do not revert these changes casually.

Useful commands:

```powershell
git status --short
git diff --stat
git diff -- game.gd TileSuitSelector.gd TalkScene.gd CODEX_NOTES.md
```

## Asset Rules

- Japanese text inside generated UI images is allowed and preferred when the user asks for text in an image.
- Do not manually draw UI assets or add text afterward on top of generated images unless the user explicitly asks.
- Runtime images should be WebP when referenced in the project.
- Do not delete unreferenced files under `assets/chara` just because they are unused right now. Character art may be kept as future-use stock unless the user explicitly asks for cleanup.
- For transparent PNG to WebP, use Pillow with `RGBA` and `lossless=True`.
- After adding or converting assets, run Godot editor headless to generate imports:

```powershell
& 'C:\Users\hskst\work\Godot_v4.6.2-stable_win64_console.exe' --headless --editor --path 'C:\Users\hskst\work\longtianhong' --quit
```

## Stage Intro Assets

Stage intro assets are under `assets/ui/stage_intro`.

Current direction:

- Difficulty logos and labels have WebP versions.
- Star parts are `difficulty_star_full.webp`, `difficulty_star_empty.webp`, and `difficulty_star_half.webp`.
- Jacket images and difficulty logos have been generated/converted, but runtime integration may still need confirmation.
- See `ASSET_ADOPTION_STATUS.md` before moving, deleting, or replacing stage intro assets.

## Face / Portrait Assets

Face and talk character assets under `assets/kao` and `assets/chara` are in the middle of PNG-to-WebP adoption.

Current likely intent:

- Use WebP files for runtime references in `game.gd`.
- Use WebP files for talk character references in `TalkScene.gd`.
- Old PNG face files and their `.png.import` files are being removed after conversion.
- Old PNG talk character files and their `.png.import` files are being removed after conversion.
- Confirm all referenced `.webp.import` files exist after Godot import.

## Gameplay / Feature Notes

- `RankingManager.gd` exists as a local/print-style placeholder for leaderboard flow.
- `SupportPurchase.gd` and `MusicRoom.gd` exist for development-support and music-room related flow.
- `StageSelect.gd` handles normal/EX stage selection and the stage select UI.
- Tile suit selection now tries to prevent `manzu2` on sorted-hand stages.
- Tutorial gameplay is intentionally special-cased in `game.gd`: 3 fixed questions, 4 displayed tiles, no face portraits, and a guided mask/message overlay that only enables the highlighted answer/submit button. Replace `TUTORIAL_QUESTIONS` when final tutorial hands are decided.
- Ranking should use the free Google Play Games Services leaderboard on Android and Game Center on iOS if possible. Keep the integration clean enough that achievements/cloud save could be added later.
- Google Play Games Level Up may be worth revisiting after release for lower service fees, but do not block the initial release on it. Current plan is normal Google Play Billing for purchases and no external billing.
- `RankingManager.gd` now records local ranking best scores and pending online submissions through `SaveData.gd`. The native Google Play Games / Game Center bridge is still placeholder-based: set real leaderboard IDs in `LEADERBOARD_IDS` and align singleton/method names after choosing the actual Godot plugin. No local fallback ranking popup should be shown in release UI.
- Android ranking bridge work has started: `GodotPlayGamesServices` is registered as a Godot Android plugin singleton, uses `play-services-games-v2:21.0.0`, and supports sign-in, score submit, and leaderboard UI. Replace `android/build/src/main/res/values/play_games_services.xml` project ID and `RankingManager.gd` leaderboard IDs after Google Play Console setup. See `RANKING_SETUP_GUIDE.md`.
- The release package/bundle ID has been changed from the early placeholder `com.nb0129.longtianhong` to `com.nb0129.machiate` before creating the Google Play app.
- Planned localization targets are Japanese, English, Simplified Chinese, Traditional Chinese, and Korean. Use locale codes `ja`, `en`, `zh_CN`, `zh_TW`, and `ko`. Start localization by extracting code/text strings into translation keys before replacing generated text-in-image assets; image localization can come later.
- Title screen localization is now started: `SaveData.language_code` persists the selected locale, and `title.gd` swaps localized title assets from `assets/language/<locale>/*.webp` for `en`, `zh_CN`, `zh_TW`, and `ko`. Japanese still uses the original `assets/ui/*.webp` title assets.
- The title settings popup now keeps its close button fixed and puts settings content in a scroll area. Language selection was originally planned as generated image buttons, but the current/final direction is text `CheckBox` controls for easier localization and maintenance.
- Localized `four_chiitoi_hint.webp` assets are adopted under `assets/language/normalized/<locale>/misc/`. Localized stage intro difficulty assets are adopted under `assets/language/normalized/<locale>/stage_intro/`; English intentionally includes only `Difficulty`, `Easy`, `Normal`, `Hard`, and `Mirage`, because EX difficulty names are already English and should fall back to the original assets. Earlier placeholders for custom room, result clear header, stage select locked label, ending END, and music-room labels/buttons were removed because they did not faithfully match the original assets. A new top-four preview sheet exists at `tools/localized_top4_regen_attempt.png` and is not wired into runtime.
- Talk scene localization is implemented through `TalkLocalization.gd`. `TalkScene.gd` keeps the Japanese line arrays as fallback/source text and looks up translated speaker names and dialogue by `GameState.talk_scene_id` plus line index.
- Talk scene settings now include the same text-based language selector. Changing language in a talk scene saves `SaveData.language_code` and immediately redraws the currently visible name/body text without changing the current line index.

## Verification

After code or asset changes:

```powershell
& 'C:\Users\hskst\work\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'C:\Users\hskst\work\longtianhong' --quit
```

For import-sensitive asset work, use the editor import command from the Asset Rules section first.

## Next Suggested Work

- Verify the current WebP face asset conversion in Godot.
- Confirm there are no stale `res://*.png` references after WebP conversion.
- Decide whether the WebP conversion and tile-suit restriction should be separate commits.
- Continue stage intro runtime implementation only after checking `ASSET_ADOPTION_STATUS.md`.
