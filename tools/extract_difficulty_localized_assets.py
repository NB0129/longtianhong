from pathlib import Path

from PIL import Image


ROOT = Path(r"C:\Users\hskst\work\longtianhong")
SHEET = ROOT / "tools" / "localized_difficulty_regen_attempt.png"
OUT_ROOT = ROOT / "assets" / "language" / "normalized"

LOCALES = ["en", "zh_CN", "zh_TW", "ko"]
ROWS = [
    ("difficulty_label.webp", (1860, 845)),
    ("difficulty_kantan_logo.webp", (1719, 770)),
    ("difficulty_futsuu_logo.webp", (1719, 770)),
    ("difficulty_muzukashii_logo.webp", (1719, 770)),
    ("difficulty_mirage_logo.webp", (1719, 770)),
    ("difficulty_ex_too_easy_logo.webp", (1719, 770)),
    ("difficulty_ex_abnormal_logo.webp", (1719, 770)),
    ("difficulty_ex_very_hard_logo.webp", (1719, 770)),
    ("difficulty_ex_nightmare_logo.webp", (1719, 770)),
    ("difficulty_ex_endless_logo.webp", (1719, 770)),
]


def is_green(r: int, g: int, b: int) -> bool:
    return g > 115 and r < 105 and b < 105 and g > r * 1.35 and g > b * 1.35


def remove_green(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    pixels = []
    for r, g, b, a in rgba.getdata():
        if is_green(r, g, b):
            pixels.append((r, g, b, 0))
        else:
            pixels.append((r, g, b, a))
    rgba.putdata(pixels)
    return rgba


def trim(img: Image.Image, pad: int = 18) -> Image.Image:
    bbox = img.getchannel("A").getbbox()
    if bbox is None:
        return img
    left, top, right, bottom = bbox
    left = max(0, left - pad)
    top = max(0, top - pad)
    right = min(img.width, right + pad)
    bottom = min(img.height, bottom + pad)
    return img.crop((left, top, right, bottom))


def component_boxes(img: Image.Image) -> list[tuple[int, int, int, int, int]]:
    alpha = img.getchannel("A")
    w, h = img.size
    data = alpha.load()
    seen = bytearray(w * h)
    boxes: list[tuple[int, int, int, int, int]] = []
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if seen[idx] or data[x, y] == 0:
                continue
            stack = [(x, y)]
            seen[idx] = 1
            count = 0
            min_x = max_x = x
            min_y = max_y = y
            while stack:
                cx, cy = stack.pop()
                count += 1
                min_x = min(min_x, cx)
                max_x = max(max_x, cx)
                min_y = min(min_y, cy)
                max_y = max(max_y, cy)
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if nx < 0 or ny < 0 or nx >= w or ny >= h:
                        continue
                    nidx = ny * w + nx
                    if seen[nidx] or data[nx, ny] == 0:
                        continue
                    seen[nidx] = 1
                    stack.append((nx, ny))
            if count >= 80:
                boxes.append((count, min_x, min_y, max_x + 1, max_y + 1))
    return boxes


def fit(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    target_w, target_h = size
    if img.width == 0 or img.height == 0:
        return Image.new("RGBA", size, (0, 0, 0, 0))
    scale = min(target_w / img.width, target_h / img.height) * 0.94
    new_size = (max(1, int(img.width * scale)), max(1, int(img.height * scale)))
    resized = img.resize(new_size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    canvas.alpha_composite(resized, ((target_w - new_size[0]) // 2, (target_h - new_size[1]) // 2))
    return canvas


def extract_cell(sheet: Image.Image, col: int, row: int) -> Image.Image:
    cell_w = sheet.width / 4
    cell_h = sheet.height / 10
    inset_x = 2
    inset_y = 10
    box = (
        int(round(col * cell_w)) + inset_x,
        int(round(row * cell_h)) + inset_y,
        int(round((col + 1) * cell_w)) - inset_x,
        int(round((row + 1) * cell_h)) - inset_y,
    )
    return sheet.crop(box)


def extract_by_component_center(
    alpha_sheet: Image.Image,
    boxes: list[tuple[int, int, int, int, int]],
    col: int,
    row: int,
) -> Image.Image:
    cell_w = alpha_sheet.width / 4
    cell_h = alpha_sheet.height / 10
    selected = []
    for box in boxes:
        count, left, top, right, bottom = box
        center_x = (left + right) / 2.0
        center_y = (top + bottom) / 2.0
        box_col = int(min(3, max(0, center_x // cell_w)))
        box_row = int(min(9, max(0, center_y // cell_h)))
        if box_col == col and box_row == row:
            selected.append(box)

    if not selected:
        return remove_green(extract_cell(alpha_sheet, col, row))

    left = max(0, min(box[1] for box in selected) - 18)
    top = max(0, min(box[2] for box in selected) - 18)
    right = min(alpha_sheet.width, max(box[3] for box in selected) + 18)
    bottom = min(alpha_sheet.height, max(box[4] for box in selected) + 18)
    return alpha_sheet.crop((left, top, right, bottom))


def main() -> None:
    sheet = Image.open(SHEET)
    alpha_sheet = remove_green(sheet)
    boxes = component_boxes(alpha_sheet)
    for col, locale in enumerate(LOCALES):
        max_row = 5 if locale == "en" else len(ROWS)
        for row in range(max_row):
            file_name, size = ROWS[row]
            asset = fit(trim(extract_by_component_center(alpha_sheet, boxes, col, row)), size)
            out = OUT_ROOT / locale / "stage_intro" / file_name
            out.parent.mkdir(parents=True, exist_ok=True)
            asset.save(out, "WEBP", lossless=True, method=6)
            print(out)


if __name__ == "__main__":
    main()
