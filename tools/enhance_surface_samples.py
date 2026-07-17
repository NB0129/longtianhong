from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter, ImageOps


ROOT = Path(r"C:\Users\hskst\work\longtianhong")
SURFACE_ROOT = Path(r"C:\Users\hskst\work\表面画像")
OUT_DIR = SURFACE_ROOT / "加工サンプル"
PREVIEW_DIR = ROOT / "tools" / "surface_enhance_previews"
DOWNLOADS = Path(r"C:\Users\hskst\Downloads")
WIDE_TEMPLATE = DOWNLOADS / "Firefly_参考画像の麻雀牌を、ゲームUIに馴染む程度にリッチ化してください。__元画像の麻雀牌らしさ、象牙色の牌面、丸み、図柄の配置と読みやすさを最優先に保つ。装飾は控えめにし、牌 13256.png"

SAMPLES = [
    ("1pin", SURFACE_ROOT / "hai_pi_1.png"),
    ("2sou", SURFACE_ROOT / "hai_so_2.png"),
    ("1man", SURFACE_ROOT / "hai_ma_1.png"),
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


def enhance_surface(path: Path) -> Image.Image:
    src = Image.open(path).convert("RGBA")
    alpha = src.getchannel("A")
    rgb = src.convert("RGB")

    rgb = ImageEnhance.Color(rgb).enhance(1.12)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.18)
    rgb = ImageEnhance.Sharpness(rgb).enhance(1.75)

    px = rgb.load()
    for y in range(rgb.height):
        for x in range(rgb.width):
            a = alpha.getpixel((x, y))
            if a == 0:
                continue
            r, g, b = px[x, y]
            if r > 110 and g < 100 and b < 100:
                # Red ink: deeper vermilion with a little more punch.
                px[x, y] = (min(255, int(r * 1.08 + 10)), int(g * 0.72), int(b * 0.72))
            elif max(r, g, b) < 95:
                # Black ink: denser sumi, without crushing all detail.
                px[x, y] = (int(r * 0.55), int(g * 0.57), int(b * 0.60))
            elif r > 165 and g > 150 and b > 125:
                # Cream/white areas: keep them warm and a touch brighter.
                px[x, y] = (min(255, int(r * 1.04 + 4)), min(255, int(g * 1.03 + 3)), min(255, int(b * 1.01 + 2)))

    enhanced = Image.merge("RGBA", (*rgb.split(), alpha))

    bbox = alpha.getbbox()
    if bbox is None:
        return enhanced

    edge = ImageOps.expand(alpha, 1, 0).filter(ImageFilter.MaxFilter(3)).crop((1, 1, alpha.width + 1, alpha.height + 1))
    edge = Image.eval(edge, lambda v: max(0, min(95, v // 3)))
    dark_stroke = Image.new("RGBA", src.size, (18, 13, 8, 0))
    dark_stroke.putalpha(edge)

    shadow = Image.new("RGBA", src.size, (0, 0, 0, 0))
    shadow_alpha = alpha.filter(ImageFilter.GaussianBlur(1.6))
    shadow_layer = Image.new("RGBA", src.size, (18, 10, 4, 82))
    shadow_layer.putalpha(shadow_alpha)
    shadow.alpha_composite(shadow_layer, (1, 2))

    highlight_alpha = alpha.filter(ImageFilter.GaussianBlur(0.8))
    highlight_layer = Image.new("RGBA", src.size, (255, 244, 214, 0))
    highlight_layer.putalpha(Image.eval(highlight_alpha, lambda v: min(48, v // 8)))

    result = Image.new("RGBA", src.size, (0, 0, 0, 0))
    result.alpha_composite(shadow)
    result.alpha_composite(dark_stroke)
    result.alpha_composite(enhanced)
    result.alpha_composite(highlight_layer, (-1, -1))
    return result


def blank_tile(target_h: int = 160) -> Image.Image:
    tile = remove_edge_black_background(Image.open(WIDE_TEMPLATE))
    bbox = tile.getbbox()
    if bbox is not None:
        tile = tile.crop(bbox)
    return tile.resize((round(tile.width * target_h / tile.height), target_h), Image.Resampling.LANCZOS)


def paste_surface_on_tile(surface: Image.Image, target_h: int = 160) -> Image.Image:
    preview = blank_tile(target_h)
    scale = target_h / 562.0
    box = (
        round(32 * scale),
        round(42 * scale),
        preview.width - round(32 * scale),
        preview.height - round(42 * scale),
    )
    face_w = box[2] - box[0]
    face_h = box[3] - box[1]
    bbox = surface.getbbox()
    cropped = surface.crop(bbox) if bbox else surface
    surface_scale = min(face_w / cropped.width, face_h / cropped.height)
    resized = cropped.resize((round(cropped.width * surface_scale), round(cropped.height * surface_scale)), Image.Resampling.LANCZOS)
    x = box[0] + (face_w - resized.width) // 2
    y = box[1] + (face_h - resized.height) // 2
    preview.alpha_composite(resized, (x, y))
    return preview


def make_preview(processed: dict[str, Image.Image]) -> Path:
    previews = []
    for name, source in SAMPLES:
        original = paste_surface_on_tile(Image.open(source).convert("RGBA"))
        enhanced = paste_surface_on_tile(processed[name])
        previews.append((name, original, enhanced))

    gap = 16
    cell_w = max(max(original.width, enhanced.width) for _name, original, enhanced in previews)
    cell_h = max(max(original.height, enhanced.height) for _name, original, enhanced in previews)
    canvas = Image.new("RGBA", (gap * 4 + cell_w * 6, gap * 2 + cell_h), (22, 18, 28, 255))

    x = gap
    for _name, original, enhanced in previews:
        canvas.alpha_composite(original, (x + (cell_w - original.width) // 2, gap))
        x += cell_w + gap
        canvas.alpha_composite(enhanced, (x + (cell_w - enhanced.width) // 2, gap))
        x += cell_w + gap

    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    output = PREVIEW_DIR / "surface_enhance_sample_preview.png"
    canvas.save(output)
    return output


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    processed: dict[str, Image.Image] = {}
    for name, source in SAMPLES:
        image = enhance_surface(source)
        output = OUT_DIR / f"{source.stem}_rich_sample.png"
        image.save(output)
        processed[name] = image
        print(f"Wrote {output}")
    print(f"Preview: {make_preview(processed)}")


if __name__ == "__main__":
    main()
