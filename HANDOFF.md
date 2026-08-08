# Handoff

Last updated: 2026-07-22

This file is the short entry point for future Codex threads. Read this before opening older threads. Older image-generation threads can contain huge inline image payloads and may overflow the context window.

## Project

- Project path: `C:\Users\langt\Documents\Codex\2026-07-15\rotenko-games-coo-chief-of-staff\work\machiate-clean-baseline`
- Engine: Godot 4.6.2 console binary at `E:\FileHistory\狼天紅\work\Godot_v4.6.2-stable_win64_console.exe`
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

The worktree was clean immediately before this handoff correction. Always verify the live state with `git status --short --branch`; local `main` contains unpublished commits and must not be pushed without explicit owner authorization.

The founder decided on 2026-07-22 that all seven iOS Game Center leaderboards are mandatory for v1. There is no v1.1 deferral. The GDScript integration and pinned native plugin patch are implemented, and the Windows contract harness currently passes 108 deterministic assertions. This does not complete the Apple platform gates: the plugin still has to be built and loaded on macOS, all seven leaderboards have to be configured in App Store Connect, and the signed archive, physical iPhone, and TestFlight flows all have to pass. Keep `entitlements/game_center=false` until the plugin and Apple configuration have been validated; iOS ranking remains a release blocker until every gate passes.

The Apple organization-enrollment attempt failed, and the founder decided on 2026-07-22 to release v1 through the existing individual Apple Developer Program membership instead of blocking on organization conversion. Apple states that an individual member's personal legal name is shown as the App Store seller and developer name. The developer name is fixed when that account creates its first app record; if the membership already has an app record, capture the existing fixed value instead of assuming it can be changed for this app. The founder explicitly accepts public display of the legal name and has a virtual-office address plus a company-domain email prepared as public-contact candidates. The address is not approved Apple evidence until it passes the applicable Apple document check. Record the exact public preview before submission. The prior EU-exclusion decision was revoked on 2026-07-23: v1 must not exclude EU member-state storefronts on either Apple or Google Play. Complete each platform's compliance and public-contact requirements instead of using storefront exclusion as an avoidance measure. Organization conversion may be requested later, but it is not a v1 dependency. The Google Play account is already an organization account; the founder has confirmed production access with another app on that same account, so the 12-testers/14-days requirement for newly created personal accounts is not a mandatory gate for this app. An organization developer account must show a verified developer phone number and email on Google Play independent of EU availability, and its public legal organization name/address must match the linked Payments/D-U-N-S data. A read-only Play Console check on 2026-07-23 confirmed that a distinct public developer phone and developer email are already configured and verified, while the Google-only contact phone is a separate nonpublic field; the legal organization name/address and verified website are also present. Do not record the actual contact values in release evidence. Google release remains blocked until the founder accepts the currently configured public developer phone or explicitly replaces it with a durable business number, and until the public legal-address preview is accepted. The same check confirmed `com.nb0129.machiate` is already registered for Android developer verification, so the package-registration gate is closed; retain the ongoing identity/legal-information accuracy gate through and after the 2026-09-30 rollout. Normal internal/device QA remains required.

- The prior PNG-to-WebP and tile-suit work is historical, not an outstanding dirty-worktree bundle.
- The current release chain includes all approved dialogue localization, hardened iOS support-purchase lifecycle handling, mandatory iOS Game Center integration, and the minimized Game Center authentication payload.
- The release implementation baseline is `bdcbffbd4f6fbec49df738a543390fa2d8980090`; later documentation-only commits do not replace the need to build and test that implementation on Apple hardware.
- Do not publish, push, upload, submit, or change App Store Connect values without the normal explicit authorization gates.

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
& 'E:\FileHistory\狼天紅\work\Godot_v4.6.2-stable_win64_console.exe' --headless --editor --path 'C:\Users\langt\Documents\Codex\2026-07-15\rotenko-games-coo-chief-of-staff\work\machiate-clean-baseline' --quit
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

- `RankingManager.gd` is the implemented cross-platform ranking coordinator. Its iOS path uses the exact seven Game Center leaderboard IDs, player-scoped pending scores, request correlation, retry/timeout handling, and native leaderboard presentation.
- `SupportPurchase.gd` and `MusicRoom.gd` exist for development-support and music-room related flow.
- `StageSelect.gd` handles normal/EX stage selection and the stage select UI.
- Tile suit selection now tries to prevent `manzu2` on sorted-hand stages.
- Tutorial gameplay is intentionally special-cased in `game.gd`: 3 fixed questions, 4 displayed tiles, no face portraits, and a guided mask/message overlay that only enables the highlighted answer/submit button. Replace `TUTORIAL_QUESTIONS` when final tutorial hands are decided.
- Android uses Google Play Games Services leaderboards. iOS v1 must ship with all seven Game Center leaderboards; achievements/cloud save remain later work.
- Google Play Games Level Up may be worth revisiting after release for lower service fees, but do not block the initial release on it. Current plan is normal Google Play Billing for purchases and no external billing.
- `RankingManager.gd` records local best scores and pending online submissions through `SaveData.gd`. Android IDs are isolated in `ANDROID_LEADERBOARD_IDS`; `IOS_LEADERBOARD_IDS` contains the exact seven App Store Connect IDs. `IOSGameCenterAdapter.gd` and the pinned native plugin patch implement authenticated, player-scoped submission and leaderboard presentation. The Windows contract harness passes 108 deterministic assertions, but that is not a substitute for a macOS/Xcode build, App Store Connect configuration, signed-archive inspection, physical-iPhone testing, or TestFlight. Keep `entitlements/game_center=false` until the plugin/configuration checks pass, and do not ship while any iOS ranking gate remains open. No local fallback ranking popup should be shown in release UI.
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
& 'E:\FileHistory\狼天紅\work\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'C:\Users\langt\Documents\Codex\2026-07-15\rotenko-games-coo-chief-of-staff\work\machiate-clean-baseline' --quit
```

For import-sensitive asset work, use the editor import command from the Asset Rules section first.

Run the reproducible iOS Game Center contract suite from the repository root on Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ios_gamecenter\run_contract_tests.ps1 -GodotExe 'E:\FileHistory\狼天紅\work\Godot_v4.6.2-stable_win64_console.exe'
```

The expected results include `PASS: native authentication payload excludes alias/displayName` and `PASS: 108 deterministic iOS Game Center assertions`. The payload gate verifies that Game Center display names are not exposed to GDScript; the game uses only the game-scoped identifier for pending-score ownership. These checks verify the GDScript/native contract only; they do not close the macOS, Apple signing, App Store Connect component-review, device, or TestFlight gates.

## Next Suggested Work

- Build the pinned Game Center native plugin on macOS/Xcode against Godot `4.6.2-stable @ 001aa128b1cd80dc4e47e823c360bccf45ed6bad` and confirm the built authentication payload excludes `alias` and `displayName`.
- Confirm the individual Apple membership is active with no leftover legal-entity verification hold, capture its Team ID and exact public seller/developer names, and keep signing/provisioning bound to that same team.
- Create all seven leaderboard components in App Store Connect, associate all 7/7 with the first iOS app version, and add every component to the same draft submission with **Add for Review**.
- Confirm the signed app has Boolean `com.apple.developer.game-center = true` and that the embedded provisioning profile matches.
- Test all seven rankings on physical iPhones/TestFlight with at least two dedicated non-friend Game Center accounts, then use **Delete Test Data** before review submission.
- If the support-pack IAP ships in v1, have the individual Account Holder activate the Paid Apps Agreement and finish banking/tax information before sandbox validation. Add the first `support_pack` IAP to the same v1 app-version submission and do not release until it is approved and publishable. Verify that EU member-state storefronts are not excluded from v1 on either store, and separately obtain acceptance of the already configured Google public developer phone and public Payments/D-U-N-S address, or replace the phone with an explicitly approved durable business number.
- Keep App Privacy **UNRESOLVED / DO NOT SAVE** until Apple gives written confirmation for Route A or the conservative Route B disclosure is finalized against the submitted archive.
