from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(r"C:\Users\hskst\work\longtianhong")
RICH_ROOT = Path(r"C:\Users\hskst\work\表面画像\rich")
OUT_DIR = ROOT / "tools" / "rich_tile_samples"

TEMPLATES = {
    "siro": {
        "path": RICH_ROOT / "siro.png",
        "out_size": (414, 562),
        "safe_margin": (32, 42, 32, 42),
    },
    "tatenaga": {
        "path": RICH_ROOT / "tatenaga.png",
        "out_size": (334, 562),
        "safe_margin": (26, 42, 26, 42),
    },
}

SAMPLES = [
    ("pin1", RICH_ROOT / "pin1.png", "sample_pin1.webp"),
    ("so2", RICH_ROOT / "so2.png", "sample_so2.webp"),
    ("man1", RICH_ROOT / "man1.png", "sample_man1.webp"),
]


def safe_box(out_size: tuple[int, int], safe_margin: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    left, top, right, bottom = safe_margin
    return (left, top, out_size[0] - right, out_size[1] - bottom)


def fit_template(path: Path, out_size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    bbox = image.getbbox()
    if bbox is not None:
        image = image.crop(bbox)
    return image.resize(out_size, Image.Resampling.LANCZOS)


def fit_surface(path: Path, box: tuple[int, int, int, int]) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    bbox = image.getbbox()
    if bbox is None:
        raise RuntimeError(f"Surface has no visible pixels: {path}")

    cropped = image.crop(bbox)
    box_w = box[2] - box[0]
    box_h = box[3] - box[1]
    scale = min(box_w / cropped.width, box_h / cropped.height)
    size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    return cropped.resize(size, Image.Resampling.LANCZOS)


def compose_tile(surface_path: Path, template_path: Path, out_size: tuple[int, int], box: tuple[int, int, int, int]) -> Image.Image:
    tile = fit_template(template_path, out_size)
    surface = fit_surface(surface_path, box)
    x = box[0] + (box[2] - box[0] - surface.width) // 2
    y = box[1] + (box[3] - box[1] - surface.height) // 2

    shadow_alpha = surface.getchannel("A").filter(ImageFilter.GaussianBlur(2.0))
    shadow = Image.new("RGBA", surface.size, (14, 9, 4, 80))
    shadow.putalpha(shadow_alpha)
    tile.alpha_composite(shadow, (x + 2, y + 3))
    tile.alpha_composite(surface, (x, y))
    return tile


def make_preview(written: list[Path], template_name: str, out_size: tuple[int, int]) -> Path:
    gap = 22
    bg = Image.new(
        "RGBA",
        (gap * 4 + out_size[0] * len(written), gap * 2 + out_size[1]),
        (24, 20, 30, 255),
    )
    for index, path in enumerate(written):
        tile = Image.open(path).convert("RGBA")
        bg.alpha_composite(tile, (gap + index * (out_size[0] + gap), gap))

    output = OUT_DIR / f"rich_tile_sample_preview_{template_name}.png"
    bg.save(output)
    return output


def make_small_preview(written: list[Path], template_name: str) -> Path:
    gap = 10
    target_h = 146
    tiles: list[Image.Image] = []
    for path in written:
        image = Image.open(path).convert("RGBA")
        target_w = round(image.width * target_h / image.height)
        tiles.append(image.resize((target_w, target_h), Image.Resampling.LANCZOS))

    bg = Image.new(
        "RGBA",
        (gap * (len(tiles) + 1) + sum(tile.width for tile in tiles), target_h + gap * 2),
        (24, 20, 30, 255),
    )
    x = gap
    for tile in tiles:
        bg.alpha_composite(tile, (x, gap))
        x += tile.width + gap

    output = OUT_DIR / f"rich_tile_sample_preview_{template_name}_small.png"
    bg.save(output)
    return output


def generate_samples(template_name: str) -> None:
    config = TEMPLATES[template_name]
    out_size = config["out_size"]
    box = safe_box(out_size, config["safe_margin"])
    written: list[Path] = []
    for _name, surface_path, output_name in SAMPLES:
        tile = compose_tile(surface_path, config["path"], out_size, box)
        output = OUT_DIR / f"{template_name}_{output_name}"
        tile.save(output, format="WEBP", quality=95, method=4)
        written.append(output)
        print(f"Wrote {output}")

    print(f"Preview: {make_preview(written, template_name, out_size)}")
    print(f"Small preview: {make_small_preview(written, template_name)}")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    generate_samples("siro")
    generate_samples("tatenaga")


if __name__ == "__main__":
    main()
