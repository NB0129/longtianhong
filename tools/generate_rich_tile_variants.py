from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(r"C:\Users\hskst\work\longtianhong")
SURFACE_ROOT = Path(r"C:\Users\hskst\work\表面画像")
DOWNLOADS = Path(r"C:\Users\hskst\Downloads")

WIDE_TEMPLATE = DOWNLOADS / "Firefly_参考画像の麻雀牌を、ゲームUIに馴染む程度にリッチ化してください。__元画像の麻雀牌らしさ、象牙色の牌面、丸み、図柄の配置と読みやすさを最優先に保つ。装飾は控えめにし、牌 13256.png"
NARROW_TEMPLATE = DOWNLOADS / "Firefly_スマホゲーム用の高品質な麻雀牌の白い土台だけを生成してください。__縦長の麻雀牌、正面向き、完全に中央配置。牌面には一切の文字・記号・模様を入れない。上品な象牙色の牌面、 587343.png"


@dataclass(frozen=True)
class Variant:
	name: str
	template: Path
	out_size: tuple[int, int]
	safe_margin: tuple[int, int, int, int]


VARIANTS = [
    Variant(
		name="wide",
		template=WIDE_TEMPLATE,
		out_size=(414, 562),
		safe_margin=(32, 42, 32, 42),
	),
	Variant(
		name="narrow",
		template=NARROW_TEMPLATE,
		out_size=(334, 562),
		safe_margin=(26, 42, 26, 42),
	),
]


SUITS = [
    ("pinz", "a{}pinz.webp", "hai_pi_{}.png"),
    ("souzu", "so{}.webp", "hai_so_{}.png"),
    ("manzu", "man{}.webp", "hai_ma_{}.png"),
]


def remove_edge_black_background(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    seen: set[tuple[int, int]] = set()
    stack: list[tuple[int, int]] = []

    for x in range(w):
        stack.append((x, 0))
        stack.append((x, h - 1))
    for y in range(h):
        stack.append((0, y))
        stack.append((w - 1, y))

    while stack:
        x, y = stack.pop()
        if (x, y) in seen or x < 0 or y < 0 or x >= w or y >= h:
            continue
        seen.add((x, y))
        r, g, b, a = px[x, y]
        if a == 0 or max(r, g, b) <= 28:
            px[x, y] = (r, g, b, 0)
            stack.append((x + 1, y))
            stack.append((x - 1, y))
            stack.append((x, y + 1))
            stack.append((x, y - 1))

    return rgba


def fit_template(path: Path, size: tuple[int, int]) -> Image.Image:
    image = remove_edge_black_background(Image.open(path))
    bbox = image.getbbox()
    if bbox is None:
        raise RuntimeError(f"Template has no visible pixels: {path}")
    image = image.crop(bbox)
    return image.resize(size, Image.Resampling.LANCZOS)


def fit_surface(path: Path, box: tuple[int, int, int, int]) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    bbox = image.getbbox()
    if bbox is None:
        raise RuntimeError(f"Surface has no visible pixels: {path}")
    image = image.crop(bbox)
    box_w = box[2] - box[0]
    box_h = box[3] - box[1]
    scale = min(box_w / image.width, box_h / image.height)
    size = (max(1, round(image.width * scale)), max(1, round(image.height * scale)))
    return image.resize(size, Image.Resampling.LANCZOS)


def add_surface(base: Image.Image, surface: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    result = base.copy()
    x = box[0] + ((box[2] - box[0]) - surface.width) // 2
    y = box[1] + ((box[3] - box[1]) - surface.height) // 2

    shadow_alpha = surface.getchannel("A").filter(ImageFilter.GaussianBlur(2.0))
    shadow = Image.new("RGBA", surface.size, (8, 6, 3, 92))
    shadow.putalpha(shadow_alpha)
    result.alpha_composite(shadow, (x + 2, y + 3))
    result.alpha_composite(surface, (x, y))
    return result


def safe_box(variant: Variant) -> tuple[int, int, int, int]:
    left, top, right, bottom = variant.safe_margin
    return (left, top, variant.out_size[0] - right, variant.out_size[1] - bottom)


def generate_variant(variant: Variant) -> list[Path]:
    out_dir = ROOT / "assets" / f"tiles_rich_{variant.name}"
    out_dir.mkdir(parents=True, exist_ok=True)
    template = fit_template(variant.template, variant.out_size)
    written: list[Path] = []

    for _suit_name, output_pattern, source_pattern in SUITS:
        for number in range(1, 10):
            source = SURFACE_ROOT / source_pattern.format(number)
            output = out_dir / output_pattern.format(number)
            box = safe_box(variant)
            surface = fit_surface(source, box)
            tile = add_surface(template, surface, box)
            tile.save(output, format="WEBP", quality=95, lossless=False, method=6)
            written.append(output)

    return written


def make_preview(variant: Variant) -> Path:
    tile_dir = ROOT / "assets" / f"tiles_rich_{variant.name}"
    preview_dir = ROOT / "tools" / "tile_variant_previews"
    preview_dir.mkdir(parents=True, exist_ok=True)
    scale_h = 146
    gap = 10
    label_h = 28
    names = [
        ("筒子", "a{}pinz.webp"),
        ("索子", "so{}.webp"),
        ("萬子", "man{}.webp"),
    ]

    sample = Image.open(tile_dir / names[0][1].format(1)).convert("RGBA")
    scale_w = round(sample.width * scale_h / sample.height)
    canvas_w = 9 * scale_w + 10 * gap
    canvas_h = 3 * (scale_h + label_h) + 4 * gap
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (20, 16, 26, 255))

    for row, (_label, pattern) in enumerate(names):
        y = gap + row * (scale_h + label_h + gap) + label_h
        for number in range(1, 10):
            tile = Image.open(tile_dir / pattern.format(number)).convert("RGBA")
            tile = tile.resize((scale_w, scale_h), Image.Resampling.LANCZOS)
            x = gap + (number - 1) * (scale_w + gap)
            canvas.alpha_composite(tile, (x, y))

    output = preview_dir / f"rich_tiles_{variant.name}_preview.png"
    canvas.save(output)
    return output


def main() -> None:
    all_written: list[Path] = []
    previews: list[Path] = []
    for variant in VARIANTS:
        all_written.extend(generate_variant(variant))
        previews.append(make_preview(variant))

    print(f"Generated {len(all_written)} tile assets.")
    for path in previews:
        print(f"Preview: {path}")


if __name__ == "__main__":
    main()
