"""
プロジェクト内の全 PNG/JPG/JPEG を WebP に変換し、
.gd ファイルのパス参照と .import ファイルも更新するスクリプト。
"""

import os
import sys
from pathlib import Path
from PIL import Image

PROJECT_ROOT = Path(__file__).parent.parent
ASSETS_DIR = PROJECT_ROOT / "assets"
IMAGE_EXTS = {".png", ".jpg", ".jpeg"}


def convert_image(src: Path) -> Path | None:
    """画像を WebP に変換して保存し、元ファイルを削除する。成功時は出力パスを返す。"""
    dest = src.with_suffix(".webp")
    try:
        with Image.open(src) as img:
            # PNG は透過を保持するため lossless、JPG/JPEG は品質 85 の lossy
            if src.suffix.lower() == ".png":
                img.save(dest, "WEBP", lossless=True)
            else:
                img.save(dest, "WEBP", quality=85)
        src.unlink()
        return dest
    except Exception as e:
        print(f"  [ERROR] {src}: {e}")
        return None


def remove_import_file(img_path: Path) -> None:
    """対応する .import ファイルを削除する（Godot が自動再生成する）。"""
    import_file = img_path.parent / (img_path.name + ".import")
    if import_file.exists():
        import_file.unlink()


def update_gd_references(converted: dict[str, str]) -> None:
    """
    converted: {"res://assets/foo/bar.png": "res://assets/foo/bar.webp", ...}
    .gd ファイル内の旧パスを新パスに一括置換する。
    """
    gd_files = list(PROJECT_ROOT.glob("*.gd"))
    for gd_file in gd_files:
        text = gd_file.read_text(encoding="utf-8")
        original = text
        for old, new in converted.items():
            text = text.replace(old, new)
        if text != original:
            gd_file.write_text(text, encoding="utf-8")
            print(f"  [GD] {gd_file.name} を更新しました")


def main() -> None:
    converted: dict[str, str] = {}

    print("=== 画像 → WebP 変換を開始 ===")
    for img_path in sorted(ASSETS_DIR.rglob("*")):
        if img_path.suffix.lower() not in IMAGE_EXTS:
            continue

        rel = img_path.relative_to(PROJECT_ROOT)
        old_res = "res://" + rel.as_posix()

        print(f"  変換中: {rel}")
        remove_import_file(img_path)
        dest = convert_image(img_path)

        if dest:
            new_rel = dest.relative_to(PROJECT_ROOT)
            new_res = "res://" + new_rel.as_posix()
            converted[old_res] = new_res
            print(f"    → {new_rel.name}")

    print(f"\n変換完了: {len(converted)} 件")

    print("\n=== .gd ファイルのパス参照を更新 ===")
    update_gd_references(converted)

    print("\n=== 完了 ===")
    print("Godot エディタを再起動（またはプロジェクトを再インポート）してください。")


if __name__ == "__main__":
    main()
