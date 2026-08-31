#!/usr/bin/env python3
"""Static tuple check only; it does not launch Godot."""
from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {"ja": [26, 53, 5], "en": [26, 45, 6], "zh_CN": [26, 52, 6], "zh_TW": [26, 52, 6], "ko": [26, 53, 6]}
runtime = (ROOT / "ButtonFamilyRuntime.gd").read_text(encoding="utf-8")
match = re.search(r'"custom_back": \{([^\n]+)\}', runtime)
if not match:
    raise SystemExit("FAIL runtime custom_back tuple missing")
runtime_tuple = {locale: [int(value) for value in values.split(", ")] for locale, values in re.findall(r'"([A-Za-z_]+)": \[([0-9, ]+)\]', match.group(1))}
json_tuple = json.loads((ROOT / "assets" / "ui" / "button_families_r01" / "INK_LAYOUTS.json").read_text(encoding="utf-8"))["layouts"]["custom_back"]
if runtime_tuple != EXPECTED or json_tuple != EXPECTED:
    raise SystemExit(f"FAIL expected={EXPECTED} runtime={runtime_tuple} json={json_tuple}")
print("PASS B26 runtime=1 json_mirror=1 godot=0")
