"""
Claude Code PostToolUse フック用スクリプト。
Write ツールで PNG/JPG/JPEG が保存されたとき、自動で WebP に変換する。
stdin から Claude Code が渡す JSON を受け取り、file_path を取得する。
"""

import json
import sys
from pathlib import Path
from PIL import Image

IMAGE_EXTS = {".png", ".jpg", ".jpeg"}


def main() -> None:
    # Claude Code はフック入力を stdin に JSON で渡す
    # 形式: {"tool_name": "Write", "tool_input": {"file_path": "...", ...}}
    # utf-8-sig で読むことで UTF-8 BOM も透過的に処理する
    try:
        raw = sys.stdin.buffer.read().decode("utf-8-sig")
        hook_data = json.loads(raw)
    except (json.JSONDecodeError, OSError, UnicodeDecodeError):
        sys.exit(0)

    tool_input = hook_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    if not file_path:
        sys.exit(0)

    src = Path(file_path)
    if src.suffix.lower() not in IMAGE_EXTS:
        sys.exit(0)  # 画像でなければ何もしない

    if not src.exists():
        sys.exit(0)

    dest = src.with_suffix(".webp")
    try:
        with Image.open(src) as img:
            if src.suffix.lower() == ".png":
                img.save(dest, "WEBP", lossless=True)
            else:
                img.save(dest, "WEBP", quality=85)
        src.unlink()
        print(f"[auto_webp] {src.name} → {dest.name}", file=sys.stderr)
    except Exception as e:
        print(f"[auto_webp] エラー: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
