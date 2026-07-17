from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(r"C:\Users\hskst\work\longtianhong")
BG = ROOT / "assets" / "bg"

RENAMES_BY_SIZE = {
    (864, 1821): "music_bg_src.png",
    (1855, 848): "music_title_src.png",
    (1254, 1254): "icon_tile_display_src.png",
    (1717, 916): "music_button_sheet_src.png",
    (2100, 749): "music_small_button_sheet_src.png",
    (1933, 814): "music_row_bgm_src.png",
    (1952, 806): "music_now_playing_src.png",
    (2025, 776): "music_row_playing_src.png",
    (1983, 793): "music_all_tracks_src.png",
    (1907, 825): "music_playlist_src.png",
}


def rename_sources() -> None:
    for path in list(BG.glob("*.png")):
        if path.name.startswith("music_") or path.name.startswith("icon_tile_display"):
            continue
        with Image.open(path) as image:
            target_name = RENAMES_BY_SIZE.get(image.size)
        if target_name is None:
            continue
        target = BG / target_name
        if target.exists() and target != path:
            path.unlink()
        elif target != path:
            path.rename(target)


def tight_crop(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    bbox = rgba.getbbox()
    if bbox is None:
        return rgba
    return rgba.crop(bbox)


def save_webp(image: Image.Image, name: str, quality: int = 95) -> Path:
    output = BG / name
    image.save(output, format="WEBP", quality=quality, method=4)
    return output


def cover_crop(path: Path, size: tuple[int, int], focus_y: float) -> Image.Image:
    image = Image.open(path).convert("RGB")
    target_w, target_h = size
    scale = max(target_w / image.width, target_h / image.height)
    resized = image.resize(
        (round(image.width * scale), round(image.height * scale)),
        Image.Resampling.LANCZOS,
    )
    max_left = resized.width - target_w
    max_top = resized.height - target_h
    left = max(0, max_left // 2)
    top = max(0, round(max_top * focus_y))
    return resized.crop((left, top, left + target_w, top + target_h)).convert("RGBA")


def crop_sheet_cells(path: Path, cols: int, rows: int, names: list[str]) -> None:
    image = Image.open(path).convert("RGBA")
    bbox = image.getbbox()
    if bbox is None:
        return
    sheet = image.crop(bbox)
    cell_w = sheet.width / cols
    cell_h = sheet.height / rows
    for index, name in enumerate(names):
        col = index % cols
        row = index // cols
        cell = sheet.crop((
            round(col * cell_w),
            round(row * cell_h),
            round((col + 1) * cell_w),
            round((row + 1) * cell_h),
        ))
        save_webp(tight_crop(cell), name)


def save_ui_resizes() -> None:
    sizes = {
        "music_title.webp": ("music_title_ui.webp", (416, 74)),
        "music_header_all_tracks.webp": ("music_header_all_tracks_ui.webp", (364, 48)),
        "music_header_playlist.webp": ("music_header_playlist_ui.webp", (364, 48)),
        "music_now_playing.webp": ("music_now_playing_ui.webp", (456, 108)),
        "music_btn_play.webp": ("music_btn_play_ui.webp", (124, 38)),
        "music_btn_pause.webp": ("music_btn_pause_ui.webp", (124, 38)),
        "music_btn_stop.webp": ("music_btn_stop_ui.webp", (124, 38)),
        "music_btn_add.webp": ("music_btn_add_ui.webp", (116, 42)),
        "music_btn_reset.webp": ("music_btn_reset_ui.webp", (122, 42)),
        "music_btn_order.webp": ("music_btn_order_ui.webp", (146, 42)),
        "music_btn_random.webp": ("music_btn_random_ui.webp", (146, 42)),
        "music_btn_back.webp": ("music_btn_back_ui.webp", (154, 54)),
        "music_icon_settings.webp": ("music_icon_settings_ui.webp", (72, 72)),
        "music_icon_delete.webp": ("music_icon_delete_ui.webp", (40, 48)),
        "music_icon_up.webp": ("music_icon_up_ui.webp", (40, 48)),
        "music_icon_down.webp": ("music_icon_down_ui.webp", (40, 48)),
    }
    for src_name, (dest_name, size) in sizes.items():
        image = Image.open(BG / src_name).convert("RGBA")
        target_w, target_h = size
        scale = min(target_w / image.width, target_h / image.height)
        resized = image.resize(
            (round(image.width * scale), round(image.height * scale)),
            Image.Resampling.LANCZOS,
        )
        canvas = Image.new("RGBA", size, (0, 0, 0, 0))
        canvas.alpha_composite(
            resized,
            ((target_w - resized.width) // 2, (target_h - resized.height) // 2),
        )
        save_webp(canvas, dest_name, 92)


def main() -> None:
    rename_sources()

    save_webp(cover_crop(BG / "music_bg_src.png", (480, 854), 0.45), "music_bg.webp", 92)
    save_webp(tight_crop(Image.open(BG / "music_title_src.png")), "music_title.webp")
    save_webp(tight_crop(Image.open(BG / "icon_tile_display_src.png")), "icon_tile_display.webp")
    save_webp(tight_crop(Image.open(BG / "music_all_tracks_src.png")), "music_header_all_tracks.webp")
    save_webp(tight_crop(Image.open(BG / "music_playlist_src.png")), "music_header_playlist.webp")
    save_webp(tight_crop(Image.open(BG / "music_now_playing_src.png")), "music_now_playing.webp")
    save_webp(tight_crop(Image.open(BG / "music_row_bgm_src.png")), "music_row_bgm.webp")
    save_webp(tight_crop(Image.open(BG / "music_row_playing_src.png")), "music_row_playing.webp")

    crop_sheet_cells(
        BG / "music_button_sheet_src.png",
        2,
        4,
        [
            "music_btn_play.webp",
            "music_btn_pause.webp",
            "music_btn_stop.webp",
            "music_btn_add.webp",
            "music_btn_reset.webp",
            "music_btn_order.webp",
            "music_btn_random.webp",
            "music_btn_back.webp",
        ],
    )
    crop_sheet_cells(
        BG / "music_small_button_sheet_src.png",
        5,
        1,
        [
            "music_icon_delete.webp",
            "music_icon_up.webp",
            "music_icon_down.webp",
            "music_icon_settings.webp",
            "music_icon_back.webp",
        ],
    )
    save_ui_resizes()


if __name__ == "__main__":
    main()
