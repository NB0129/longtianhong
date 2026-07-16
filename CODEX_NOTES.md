# Codex Development Notes

This file is intentionally placed at the project root so future Codex threads should inspect it before continuing work.

For current project state and handoff notes, read `HANDOFF.md` before opening older threads. Do not bulk-read old image-generation threads; they can contain huge inline image payloads.

## Image Generation

- For this project, assume modern image generation can render Japanese text correctly.
- Do not reject or avoid text-in-image generation because of old concerns about Japanese text becoming garbled.
- When the user asks for text inside generated UI images, treat that as an acceptable and preferred workflow unless the user says otherwise.
- Do not manually draw UI image assets.
- Do not add text afterward on top of generated images.
- In this project, "make/create an image" means using image generation unless the user explicitly says otherwise.
- Generated UI images must not be casually cropped after generation. Top/bottom cropping is especially risky, and the bottom edge is often where ornaments, shadows, descenders, or glow get clipped.
- When generating image assets that will later need transparency, do not ask Adobe/image generation for a transparent background. It often generates a fake checkerboard transparency pattern instead. Ask for a perfectly flat solid chroma key background such as pure green `#00FF00` or pure magenta `#FF00FF`.
- For chroma-keyed generated text assets, white or light lettering is allowed. The problem to avoid is a white/gray/beige/checkerboard background, because background removal can accidentally remove the inside of light letters too.
- Chroma key background prompts should explicitly say: no transparency, no checkerboard transparency pattern, no gray/white/beige background, perfectly flat solid background color.
- When removing a background or making an image transparent, preserve enough transparent padding so all visible pixels, shadows, outlines, and decorative parts remain intact.
- For placement and scaling, always reason from the visible non-transparent bounds, not the full transparent canvas size. Transparent padding is only safety margin, not the apparent object size.
- Do not size generated UI assets by the whole image dimensions when the image contains transparent padding; doing so makes the visible object appear too small in-game.
- Before replacing or placing a generated UI asset, check the alpha/visible bounds and use those bounds when matching neighboring UI sizes.
- Convert all image assets used by the project to WebP before referencing them in-game.
- Successful WebP conversion workflow on this PC: use the bundled Python/Pillow runtime at `C:\Users\hskst\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`. Check support first with `from PIL import features; print(features.check("webp"))`; it should print `True`.
- For PNG to WebP conversion, transparent images worked well as `RGBA` + WebP `lossless=True`; opaque images can use `RGB` + `quality=90` + `method=6`.
- After converting a PNG source to WebP, update project references to `.webp`, delete the converted `.png` and its `.png.import`, then run Godot editor headless so `.webp.import` files are generated.
- Do not delete unreferenced character art under `assets/chara` without an explicit cleanup request. Unused character images may be kept for future scenes or alternate expressions.
- Successful import command: `& 'C:\Users\hskst\work\Godot_v4.6.2-stable_win64_console.exe' --headless --editor --path 'C:\Users\hskst\work\longtianhong' --quit`.
- Do not use PowerShell `Set-Content` for script edits unless UTF-8 is explicit; it corrupted `game.gd` once. Prefer `apply_patch` for code edits.

## Godot Verification

- After implementing visual or asset changes, launch Godot so the user can debug and inspect the result.
- Do not launch Godot before the relevant files and imported assets have been updated, because that can show a stale pre-change state.
- Correct order: finish edits, process/import assets, then launch Godot for verification.
- For visible launches, use `C:\Users\hskst\work\Godot_v4.6.2-stable_win64.exe`. Use the `_console.exe` binary only for headless/import commands, otherwise an extra terminal-like window appears.

## Shutdown After Work

- When the user asks to shut down this PC after work is complete, use PowerShell `Stop-Computer -Force`.
- Run the shutdown command only as the final action after reporting that work is complete.
- Do not use direct `shutdown`, `shutdown.exe`, `cmd /c shutdown`, or `Start-Process ... shutdown.exe`; on this PC direct calls failed with `The system could not find the environment option that was entered.(203)`, and `Start-Process` appeared to succeed but did not actually power off.
- Confirmed successful examples: 2026-06-25 thread line 731 used `Stop-Computer -Force` and the next event was a fresh task after reboot; 2026-06-29 this same command succeeded after the `shutdown.exe` attempts failed.
