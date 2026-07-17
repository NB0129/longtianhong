from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(r"C:\Users\hskst\work\longtianhong")
RICH_ROOT = Path(r"C:\Users\hskst\work\表面画像\rich")
PREVIEW_DIR = ROOT / "tools" / "rich_tile_previews"


@dataclass(frozen=True)
class TemplateConfig:
    name: str
    source: Path
    out_size: tuple[int, int]
    safe_margin: tuple[int, int, int, int]


TEMPLATES = [
    TemplateConfig(
        name="siro",
        source=RICH_ROOT / "siro.png",
        out_size=(414, 562),
        safe_margin=(32, 42, 32, 42),
    ),
    TemplateConfig(
        name="tatenaga",
        source=RICH_ROOT / "tatenaga.png",
        out_size=(334, 562),
        safe_margin=(26, 42, 26, 42),
    ),
]

SUITS = [
    ("pin", "pin{}.png", "a{}pinz.webp"),
    ("so", "so{}.png", "so{}.webp"),
    ("man", "man{}.png", "man{}.webp"),
]

TATENAGA_SURFACE_SCALE = {
    ("pin", 2): 0.85,
    ("pin", 6): 0.85,
    ("pin", 8): 0.85,
    ("so", 2): 0.85,
    ("so", 4): 0.85,
    ("so", 5): 0.90,
    ("so", 7): 0.85,
    ("so", 8): 0.85,
    ("so", 9): 0.90,
    ("man", 1): 0.95,
}


def safe_box(config: TemplateConfig) -> tuple[int, int, int, int]:
    left, top, right, bottom = config.safe_margin
    return (
        left,
        top,
        config.out_size[0] - right,
        config.out_size[1] - bottom,
    )


def fit_template(config: TemplateConfig) -> Image.Image:
    image = Image.open(config.source).convert("RGBA")
    bbox = image.getbbox()
    if bbox is not None:
        image = image.crop(bbox)
    return image.resize(config.out_size, Image.Resampling.LANCZOS)


def fit_surface(path: Path, box: tuple[int, int, int, int], surface_scale: float = 1.0) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    bbox = image.getbbox()
    if bbox is None:
        raise RuntimeError(f"Surface has no visible pixels: {path}")

    cropped = image.crop(bbox)
    box_w = box[2] - box[0]
    box_h = box[3] - box[1]
    scale = min(box_w / cropped.width, box_h / cropped.height) * surface_scale
    size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    return cropped.resize(size, Image.Resampling.LANCZOS)


def compose_tile(template: Image.Image, surface: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    tile = template.copy()
    x = box[0] + (box[2] - box[0] - surface.width) // 2
    y = box[1] + (box[3] - box[1] - surface.height) // 2

    shadow_alpha = surface.getchannel("A").filter(ImageFilter.GaussianBlur(2.0))
    shadow = Image.new("RGBA", surface.size, (14, 9, 4, 80))
    shadow.putalpha(shadow_alpha)
    tile.alpha_composite(shadow, (x + 2, y + 3))
    tile.alpha_composite(surface, (x, y))
    return tile


def generate_tiles(config: TemplateConfig) -> list[Path]:
    out_dir = ROOT / "assets" / f"tiles_rich_{config.name}"
    out_dir.mkdir(parents=True, exist_ok=True)
    template = fit_template(config)
    box = safe_box(config)
    written: list[Path] = []

    for _suit_name, source_pattern, output_pattern in SUITS:
        for number in range(1, 10):
            source = RICH_ROOT / source_pattern.format(number)
            output = out_dir / output_pattern.format(number)
            surface_scale = 1.0
            if config.name == "tatenaga":
                surface_scale = TATENAGA_SURFACE_SCALE.get((_suit_name, number), 1.0)
            surface = fit_surface(source, box, surface_scale)
            tile = compose_tile(template, surface, box)
            tile.save(output, format="WEBP", quality=95, method=4)
            written.append(output)

    return written


def make_preview(config: TemplateConfig) -> Path:
    tile_dir = ROOT / "assets" / f"tiles_rich_{config.name}"
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    scale_h = 146
    gap = 10
    rows = [
        "a{}pinz.webp",
        "so{}.webp",
        "man{}.webp",
    ]

    sample = Image.open(tile_dir / rows[0].format(1)).convert("RGBA")
    scale_w = round(sample.width * scale_h / sample.height)
    canvas_w = 9 * scale_w + 10 * gap
    canvas_h = 3 * scale_h + 4 * gap
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (24, 20, 30, 255))

    for row_index, pattern in enumerate(rows):
        y = gap + row_index * (scale_h + gap)
        for number in range(1, 10):
            tile = Image.open(tile_dir / pattern.format(number)).convert("RGBA")
            tile = tile.resize((scale_w, scale_h), Image.Resampling.LANCZOS)
            x = gap + (number - 1) * (scale_w + gap)
            canvas.alpha_composite(tile, (x, y))

    output = PREVIEW_DIR / f"rich_tiles_{config.name}_preview.png"
    canvas.save(output)
    return output


def main() -> None:
    total = 0
    previews: list[Path] = []
    for config in TEMPLATES:
        written = generate_tiles(config)
        total += len(written)
        previews.append(make_preview(config))
        print(f"{config.name}: generated {len(written)} tiles")

    print(f"Generated {total} tile assets.")
    for preview in previews:
        print(f"Preview: {preview}")


if __name__ == "__main__":
    main()
