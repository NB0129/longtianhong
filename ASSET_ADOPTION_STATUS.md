# Asset Adoption Status

This is a non-destructive working list based on Codex thread notes, user feedback, file names, and current project references.

## Rules

- Do not move or delete files based only on this list.
- Treat `Adopted` as usable/current unless the user says otherwise.
- Treat `Rejected` as do-not-use candidates.
- Treat `Review` as needs human confirmation.
- Current code does not reference `assets/ui/stage_intro/*` yet, so stage intro status is based on conversation history and file naming, not runtime usage.

## Stage Intro / Difficulty

### Adopted

- `assets/ui/stage_intro/difficulty_label_jp.png`
  - Final transparent `難易度` text asset.
- `assets/ui/stage_intro/difficulty_mirage_logo.png`
  - Transparent `Mirage` logo saved after generation.
- `assets/ui/stage_intro/mock_intro_mirage_kougetu_v2.png`
  - Latest mock after moving the jacket lower and removing duplicate song title display.
- `assets/ui/stage_intro/difficulty_star_full.png`
- `assets/ui/stage_intro/difficulty_star_empty.png`
- `assets/ui/stage_intro/difficulty_star_half.png`
  - Current 96x96 transparent star parts cut from one matched generated sheet.
  - Only these three star image files remain in the active stage intro asset folder.

### Rejected

- `assets/ui/stage_intro/不採用/jacket_bgm_utu_higakureru_trial.png`
  - Rejected by concept feedback: interpreted as literal sunset/clock instead of teasing "too slow" concept.
- `assets/ui/stage_intro/不採用/jacket_bgm_utu_higakureru_v2.png`
  - Rejected by rule feedback: added an unrelated character.
- `assets/ui/stage_intro/不採用/jacket_bgm_utu_higakureru_v3.png`
  - Superseded by the active `jacket_bgm_utu_higakureru_v4.png` file.
- `assets/ui/stage_intro/不採用/jacket_bgm_mabo_first_appaku_trial.png`
  - Superseded by the active `jacket_bgm_mabo_first_appaku_no_tiles.png` file.
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_full_gen_raw.png`
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_full_gen_chromakey.png`
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_empty_gen_chromakey.png`
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_half_gen_raw.png`
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_half_gen_chromakey.png`
  - Rejected/obsolete because the three stars were generated separately and the borders did not match.
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_full_gen_matched.png`
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_empty_gen_matched.png`
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_star_half_gen_matched.png`
- `assets/ui/stage_intro/不採用/stars_20260627/difficulty_stars_matched_preview.png`
  - Rejected/obsolete duplicate star intermediates. The adopted files are the simpler `difficulty_star_full/empty/half.png` set.
- `assets/ui/stage_intro/不採用/wip_from_root_20260627/difficulty_stars_set_raw.png`
- `assets/ui/stage_intro/不採用/wip_from_root_20260627/difficulty_stars_set_chromakey.png`
- `assets/ui/stage_intro/不採用/wip_from_root_20260627/difficulty_parts_preview.png`
  - Source and preview files for the adopted stars. Moved out of the active asset folder so only runtime star files are imported.

### Review

- `assets/ui/stage_intro/jacket_bgm_utu_higakureru_v4.png`
  - Current active variant after older `trial`, `v2`, and `v3` files were moved to `不採用`.
- `assets/ui/stage_intro/jacket_bgm_utu_nochan_trial.png`
- `assets/ui/stage_intro/jacket_bgm_yume_jantou_trial.png`
- `assets/ui/stage_intro/jacket_bgm_mabo_first_appaku_no_tiles.png`
- `assets/ui/stage_intro/jacket_bgm_mabo_second_inisie_trial.png`
- `assets/ui/stage_intro/jacket_bgm_mabo_second_kougetu_trial.png`
  - No explicit accept/reject found yet in the inspected thread pages.
- `assets/ui/stage_intro/不採用/wip_from_root_20260627/mock_intro_mirage_kougetu.png`
- `assets/ui/stage_intro/不採用/wip_from_root_20260627/mock_intro_mirage_kougetu_clean.png`
  - Older mock variants. Likely obsolete if `mock_intro_mirage_kougetu_v2.png` is accepted.
- `assets/ui/stage_intro/不採用/wip_from_root_20260627/_stage_intro_contact_sheet.png`
  - Preview/reference file, not a runtime asset.

## Portrait Frames / Face UI

### Adopted

- `assets/kao/kao_bg_normal_title.png`
- `assets/kao/kao_bg_correct_gold_title.png`
- `assets/kao/kao_bg_correct_green_title.png`
- `assets/kao/kao_bg_correct_star_title.png`
- `assets/kao/kao_bg_wrong_wine_title.png`
- `assets/kao/kao_bg_wrong_mist_title.png`
- `assets/kao/kao_bg_wrong_purple_title.png`
  - Accepted in-thread as the 7 inner background images.
- `assets/kao/kao_bg_wolf_normal_title.png`
- `assets/kao/kao_bg_wolf_correct_crimson_title.png`
- `assets/kao/kao_bg_wolf_correct_claw_title.png`
- `assets/kao/kao_bg_wolf_wrong_crimson_title.png`
- `assets/kao/kao_bg_wolf_wrong_mist_title.png`
  - Mabo wolf inner background set. No rejection found.
- `assets/kao/portrait_parts/mabo`
- `assets/kao/portrait_parts/mabo_wolf`
- `assets/kao/portrait_parts/pyoko`
- `assets/kao/portrait_parts/yume`
  - Main portrait parts folders.
- `assets/kao/portrait_parts/ututu_no_flower_square`
  - Accepted as a corrected square frame direction after the red-rose/tall-frame problem.
- `assets/kao/portrait_parts/ututu_cute_square`
  - Latest generated ututu square parts folder; likely current for ututu, but confirm against `ututu_no_flower_square`.

### Rejected

- `assets/kao/kao_frame_ututu_square_v2.png`
- `assets/kao/kao_frame_ututu_square_generated_raw_alpha.png`
- `assets/kao/kao_frame_ututu_square_fixed.png`
- `assets/kao/kao_frame_ututu_square_redesign.png`
- `assets/kao/kao_frame_ututu_no_rose_square.png`
- `assets/kao/kao_frame_ututu_badge_square.png`
- `assets/kao/kao_frame_ututu_badge_square_fixed.png`
  - Older attempts around the "ututu square frame" problem. The thread later says the prior checks were too loose and accepted `ututu_no_flower_square` as the corrected direction.
- `assets/kao/portrait_parts/ututu_square`
- `assets/kao/portrait_parts/ututu_badge_square`
  - Older ututu square/badge attempts; likely superseded.

### Review

- `assets/kao/portrait_parts/ututu_no_flower_square`
- `assets/kao/portrait_parts/ututu_cute_square`
  - Both are plausible. Need final user preference for current ututu face style.
- `assets/kao/kao_frame_*_title.png`
  - Source/generated title-style frames. Keep if source retention is desired; not necessarily runtime assets.
- `tools/*preview*.png`
- `tools/*compare*.png`
- `tools/*contact_sheet*.png`
  - Preview/reference files. Useful while sorting, not runtime assets.

## Next Sorting Step

Recommended physical organization after confirmation:

- Keep runtime assets at their current paths.
- Keep rejected source/intermediate images under `assets/ui/stage_intro/不採用/`.
- The `不採用` folder contains `.gdignore`; `.import` files inside rejected folders should not be kept.
- Active star imports are limited to `difficulty_star_full.png`, `difficulty_star_empty.png`, and `difficulty_star_half.png`.
