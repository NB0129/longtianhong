# iOS Game Center plugin build

Release decision (2026-07-22): all seven iOS Game Center leaderboards are mandatory for v1 and must not be deferred to v1.1. The GDScript integration and this pinned native patch are implemented, but the app is not release-ready until the macOS/Xcode build, App Store Connect setup, signed archive, physical iPhone, and TestFlight gates pass.

`build_gamecenter_plugin.sh` builds the official Godot iOS Game Center plugin at pinned upstream and Godot commits. Run it on macOS with Xcode, SCons, Python, Git, the iOS SDK, and the Godot 4.6 iOS build prerequisites installed. The script deliberately completes Godot's current `target=template_debug` iOS build instead of relying on the upstream 90-second header-generation workaround.

The local patch makes score reporting safe for this game:

- exposes only a persistent, game-scoped `gamePlayerID` after authentication;
- correlates authentication attempts so a late result cannot replace a newer login;
- requires the expected player ID and a request ID for every score submission;
- verifies the current Game Center player immediately before calling Apple;
- sends integer scores through Apple's current `GKLeaderboard.submitScore` API;
- returns the player ID, request ID, leaderboard ID, and score on the main queue so the game clears only the matching pending score;
- correlates Game Center presentation and reports completion only after the native controller is dismissed;
- refuses to present Game Center while the app is inactive or another native view controller is already open.

The script writes debug and release XCFrameworks, the `.gdip`, the upstream MIT license, provenance, and hashes to `res://ios/plugins/gamecenter/`. Do not enable the release entitlement or ship an archive until all seven IDs in `RankingManager.gd` exist in App Store Connect and the signed archive passes the Game Center checks.

## Windows contract tests

From the repository root, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ios_gamecenter\run_contract_tests.ps1 -GodotExe 'E:\FileHistory\狼天紅\work\Godot_v4.6.2-stable_win64_console.exe'
```

The expected results are `PASS: native authentication payload excludes alias/displayName` and `PASS: 108 deterministic iOS Game Center assertions`. The static payload gate prevents the authentication event from exposing Game Center display names to GDScript; only the game-scoped player identifier needed for score ownership is returned. The remaining assertions cover the GDScript/native API and state-machine contract. They do not compile the Objective-C++ plugin or validate Apple services. Keep `entitlements/game_center=false` until the plugin build/load, seven App Store Connect IDs, signing configuration, and archive contents have been validated. A physical iPhone and TestFlight pass are still mandatory before release.

Pinned inputs:

- Upstream: `godot-sdk-integrations/godot-ios-plugins`
- Commit: `caafb2c7fbfb5c72a64f163c76449274fa49abaa`
- Engine tag: `4.6.2-stable`
- Engine commit: `001aa128b1cd80dc4e47e823c360bccf45ed6bad`

Official references:

- https://docs.godotengine.org/en/4.6/tutorials/platform/ios/plugins_for_ios.html
- https://docs.godotengine.org/en/4.6/tutorials/platform/ios/ios_plugin.html
- https://docs.godotengine.org/en/4.6/engine_details/development/compiling/compiling_for_ios.html
- https://developer.apple.com/documentation/gamekit/gkleaderboard/3577545-submitscore
- https://developer.apple.com/documentation/gamekit/protecting-the-player-s-privacy-using-scoped-identifiers
