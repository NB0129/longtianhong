#!/usr/bin/env python3
"""Deterministic R02 runtime-binding check. This never launches Godot."""
from __future__ import annotations

import hashlib
import json
import re
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "assets" / "ui" / "button_families_r02"

EXPECTED_LAYOUTS = {
    "result_back": {"ja": [24, 63, 11], "en": [26, 53, 10], "zh_CN": [23, 62, 12], "zh_TW": [23, 62, 12], "ko": [23, 63, 12]},
    "confirm_yes": {"ja": [23, 32, 4], "en": [24, 35, 4], "zh_CN": [18, 46, 9], "zh_TW": [18, 46, 9], "ko": [18, 47, 9]},
    "confirm_no": {"ja": [19, 26, 7], "en": [23, 39, 5], "zh_CN": [19, 46, 7], "zh_TW": [19, 46, 7], "ko": [18, 30, 9]},
    "close": {"ja": [22, 32, 7], "en": [21, 35, 9], "zh_CN": [21, 43, 9], "zh_TW": [23, 41, 7], "ko": [22, 44, 8]},
}
EXPECTED_TEXT = {
    "result_back": {"ja": "戻る", "en": "Back", "zh_CN": "返回", "zh_TW": "返回", "ko": "뒤로"},
    "confirm_yes": {"ja": "はい", "en": "Yes", "zh_CN": "是", "zh_TW": "是", "ko": "예"},
    "confirm_no": {"ja": "いいえ", "en": "No", "zh_CN": "否", "zh_TW": "否", "ko": "아니요"},
    "close": {"ja": "閉じる", "en": "Close", "zh_CN": "关闭", "zh_TW": "關閉", "ko": "닫기"},
}
EXPECTED_FRAMES = {
    "result_back_compact_r02_170x62.png": ((170, 62), 11873, "FA4219B78153E24E8344B6D6A34A107FA9E888632964FAF4BBB913CA723FE2D9"),
    "confirm_compact_r02_112x48.png": ((112, 48), 6545, "8A35099418E777F1D44E2685BD2202D6010C31B3E9318D35338EB5FDF8F8B7CF"),
    "close_compact_r02_130x54.png": ((130, 54), 8624, "0AD98422D4D055778A8CF4083B948C41A416A33A67E111ABE31E91879CB20399"),
}
B26 = {"ja": [26, 53, 5], "en": [26, 45, 6], "zh_CN": [26, 52, 6], "zh_TW": [26, 52, 6], "ko": [26, 53, 6]}


def fail(message: str) -> None:
    raise SystemExit(f"FAIL {message}")


def runtime_tuple(source: str, role: str) -> dict[str, list[int]]:
    match = re.search(rf'"{re.escape(role)}": \{{([^\n]+)\}}', source)
    if not match:
        fail(f"runtime tuple missing: {role}")
    return {
        locale: [int(value) for value in values.split(", ")]
        for locale, values in re.findall(r'"([A-Za-z_]+)": \[([0-9, ]+)\]', match.group(1))
    }


layout_path = ASSET_ROOT / "INK_LAYOUTS.json"
receipt_path = ASSET_ROOT / "OWNER_RUNTIME_BINDING_RECEIPT.json"
layout_bytes = layout_path.read_bytes()
layouts = json.loads(layout_bytes.decode("utf-8"))
receipt = json.loads(receipt_path.read_text(encoding="utf-8"))
runtime = (ROOT / "ButtonFamilyRuntime.gd").read_text(encoding="utf-8")
game = (ROOT / "game.gd").read_text(encoding="utf-8")
popup = (ROOT / "PopupSkin.gd").read_text(encoding="utf-8")
custom = (ROOT / "Custom.gd").read_text(encoding="utf-8")
button_test = (ROOT / "tests" / "ButtonFamiliesR01Test.gd").read_text(encoding="utf-8")
result_ui_test = (ROOT / "tests" / "ResultUiImprovementsTest.gd").read_text(encoding="utf-8")
capture_test = (ROOT / "tests" / "R02RuntimeVisualCapture.gd").read_text(encoding="utf-8")

for role, expected in EXPECTED_LAYOUTS.items():
    if layouts["roles"][role]["locales"] != expected:
        fail(f"layout mirror tuple mismatch: {role}")
    if runtime_tuple(runtime, role) != expected:
        fail(f"runtime tuple mismatch: {role}")
if runtime_tuple(runtime, "custom_back") != B26:
    fail("B26 tuple changed")

accepted = {(item["role"], item["locale"]): item for item in receipt["accepted_exact20"]}
if len(accepted) != 20:
    fail(f"owner acceptance count={len(accepted)}")
for role, locales in EXPECTED_LAYOUTS.items():
    for locale, expected_tuple in locales.items():
        item = accepted.get((role, locale))
        if item is None or item["godot_tuple"] != expected_tuple or item["text"] != EXPECTED_TEXT[role][locale]:
            fail(f"owner tuple mismatch: {role}/{locale}")
if receipt["fallback_inventory"]:
    fail("fallback inventory is not empty")
if receipt["runtime_text_composite_png_count"] != 0:
    fail("runtime binds text-composite PNG")
mirror = receipt["runtime_layout_mirror"]
if mirror["bytes"] != len(layout_bytes) or mirror["sha256"] != hashlib.sha256(layout_bytes).hexdigest().upper():
    fail("layout mirror tuple/hash mismatch")

expected_geometry = {
    "result_back": {"position": [112.5, 751], "hitbox": [255, 93], "art_rect": [0, 0, 255, 93], "source_frame_scale": 1.5},
    "confirm_yes": {"position": [93, 194], "hitbox": [112, 48], "art_rect": [0, 0, 112, 48]},
    "confirm_no": {"position": [205, 194], "hitbox": [112, 48], "art_rect": [0, 0, 112, 48]},
    "settings_panel": {"position": [20, 17], "size": [440, 820]},
    "settings_vbox": {"offsets": [58, 160, -50, -70], "resolved_rect": [58, 160, 332, 590], "inner_cream_top": 152, "bgm_top_margin": 8},
    "settings_close": {"hitbox": [130, 70], "art_rect": [0, 8, 130, 54]},
    "credit_close": {"hitbox": [130, 70], "art_rect": [0, 8, 130, 54]},
}
if receipt["geometry"] != expected_geometry:
    fail("owner geometry receipt mismatch")
if layouts["roles"]["result_back"]["hitbox"] != [255, 93] or layouts["roles"]["result_back"]["art_rect"] != [0, 0, 255, 93] or layouts["roles"]["result_back"]["position"] != [112.5, 751]:
    fail("Result Back runtime layout geometry mismatch")
if layouts["roles"]["result_back"].get("source_frame_scale") != 1.5 or layouts["roles"]["result_back"].get("tuple_base_size") != [170, 62]:
    fail("Result Back 1.5x/base-tuple semantics missing")
if layouts["roles"]["close"]["hitboxes"] != {"settings": [130, 70], "credits": [130, 70]}:
    fail("Settings/Credits close hitbox mirror mismatch")
if layouts["roles"]["close"]["art_rects"] != {"settings": [0, 8, 130, 54], "credits": [0, 8, 130, 54]}:
    fail("Settings/Credits close art rectangle mirror mismatch")

settings_panel = (20.0, 17.0, 440.0, 820.0)
settings_vbox = (58.0, 160.0, 332.0, 590.0)
settings_close = (
    settings_panel[0] + settings_vbox[0] + (settings_vbox[2] - 130.0) / 2.0,
    settings_panel[1] + settings_vbox[1] + settings_vbox[3] - 70.0,
    130.0,
    70.0,
)
if settings_close != (179.0, 697.0, 130.0, 70.0):
    fail(f"Settings Close derived screen rect mismatch: {settings_close}")
settings_art_bottom_gap = settings_panel[1] + settings_panel[3] - (settings_close[1] + 8.0 + 54.0)
if settings_art_bottom_gap != 78.0:
    fail(f"Settings Close lower art gap={settings_art_bottom_gap}")
settings_inner_cream_top = settings_panel[1] + 152.0
settings_bgm_control_top = settings_panel[1] + settings_vbox[1]
if settings_bgm_control_top - settings_inner_cream_top < 8.0:
    fail("Settings BGM top visual margin is below 8px")

result_back = (112.5, 751.0, 255.0, 93.0)
if result_back[0] + result_back[2] / 2.0 != 240.0 or 854.0 - (result_back[1] + result_back[3]) != 10.0:
    fail("Result Back center or bottom gap changed")
for locale, (font_size, label_x, label_y) in EXPECTED_LAYOUTS["result_back"].items():
    scaled = (round(font_size * 1.5), label_x * 1.5, label_y * 1.5)
    if scaled[0] < 10 or scaled[1] < 0.0 or scaled[2] < 0.0 or scaled[1] >= 255.0 or scaled[2] >= 93.0:
        fail(f"Result Back scaled tuple escapes art: {locale}={scaled}")

for name, (expected_size, expected_bytes, expected_sha) in EXPECTED_FRAMES.items():
    data = (ASSET_ROOT / name).read_bytes()
    size = struct.unpack(">II", data[16:24])
    if size != expected_size or len(data) != expected_bytes or hashlib.sha256(data).hexdigest().upper() != expected_sha:
        fail(f"frame tuple mismatch: {name}")

required_source = {
    "game.gd": [
        'BUTTON_FAMILY_RESULT_BACK := "res://assets/ui/button_families_r02/result_back_compact_r02_170x62.png"',
        "btn_back.position = Vector2(112.5, 751.0)",
        "btn_back.size = Vector2(255.0, 93.0)",
        "ButtonFamilyRuntime.apply(btn_back, BUTTON_FAMILY_RESULT_BACK, Vector2(255.0, 93.0)",
        "btn_back.pressed.connect(_on_btn_back_to_result_pressed)",
        "ButtonFeedback.install(result_button)",
        "_apply_result_runtime_button_style(btn_retry)",
        "_apply_result_runtime_button_style(btn_home)",
        "_apply_result_runtime_button_style(btn_ranking)",
        "_apply_result_runtime_button_style(btn_answer)",
        "btn_home.disabled = hide_home",
        "var _answer_view_top_bar_states: Dictionary = {}",
        "_hide_answer_view_top_bar_buttons()",
        "_restore_answer_view_top_bar_buttons()",
        'button.visible = bool(saved_state["visible"])',
        'button.disabled = bool(saved_state["disabled"])',
        'button.focus_mode = int(saved_state["focus_mode"])',
        "_answer_view_top_bar_states.clear()",
    ],
    "PopupSkin.gd": [
        "BUTTON_FAMILY_SETTINGS_CLOSE_ART_RECT := Rect2(0.0, 8.0, 130.0, 54.0)",
        "BUTTON_FAMILY_CREDIT_CLOSE_ART_RECT := Rect2(0.0, 8.0, 130.0, 54.0)",
        'ButtonFamilyRuntime.apply(close_button, BUTTON_FAMILY_MODAL_CLOSE, Vector2(130.0, 70.0), TalkLocalization.ui_text(locale, "close"), locale, "settings_close", 1.0, BUTTON_FAMILY_SETTINGS_CLOSE_ART_RECT)',
        'ButtonFamilyRuntime.apply(close_button, BUTTON_FAMILY_MODAL_CLOSE, Vector2(130.0, 70.0), TalkLocalization.ui_text(locale, "close"), locale, "credit_close", 1.0, BUTTON_FAMILY_CREDIT_CLOSE_ART_RECT)',
        'ButtonFamilyRuntime.apply(panel.get_node("BtnConfirmYes"), BUTTON_FAMILY_MODAL_CONFIRM, Vector2(112.0, 48.0), TalkLocalization.ui_text(locale, "yes"), locale, "confirm_yes")',
        'ButtonFamilyRuntime.apply(panel.get_node("BtnConfirmNo"), BUTTON_FAMILY_MODAL_CONFIRM, Vector2(112.0, 48.0), TalkLocalization.ui_text(locale, "no"), locale, "confirm_no")',
        "panel.position = Vector2(20.0, 17.0)",
        "panel.size = Vector2(440.0, 820.0)",
        "vbox.offset_left = 58.0",
        "vbox.offset_top = 160.0",
        "vbox.offset_right = -50.0",
        "vbox.offset_bottom = -70.0",
        "yes_button.position = Vector2(93.0, 194.0)",
        "no_button.position = Vector2(205.0, 194.0)",
    ],
    "ButtonFamilyRuntime.gd": [
        '"result_back": Vector2(170.0, 62.0)',
        "var scale_x := effective_art_rect.size.x / base_size.x",
        "var scale_y := effective_art_rect.size.y / base_size.y",
        "var selected_size := maxi(10, roundi(float(layout[0]) * scale_y))",
        "label.position = effective_art_rect.position + Vector2(float(layout[1]) * scale_x, float(layout[2]) * scale_y)",
    ],
    "Custom.gd": [
        'BUTTON_FAMILY_BACK := "res://assets/ui/button_families_r01/custom_secondary_back_154x54.png"',
        "Vector2(154.0, 54.0)",
    ],
}
for name, needles in required_source.items():
    source = {"game.gd": game, "PopupSkin.gd": popup, "Custom.gd": custom, "ButtonFamilyRuntime.gd": runtime}[name]
    for needle in needles:
        if needle not in source:
            fail(f"callsite missing {name}: {needle}")

restore_match = re.search(r"func _restore_answer_view_top_bar_buttons\(\) -> void:\n(?P<body>.*?)(?=\nfunc )", game, re.DOTALL)
if restore_match is None:
    fail("Answer TopBar restore helper block missing")
restore_body = restore_match.group("body")
restore_order = [
    restore_body.find('button.disabled = bool(saved_state["disabled"])'),
    restore_body.find('button.focus_mode = int(saved_state["focus_mode"])'),
    restore_body.find('button.visible = bool(saved_state["visible"])'),
    restore_body.find("_answer_view_top_bar_states.clear()"),
]
if -1 in restore_order or restore_order != sorted(restore_order):
    fail(f"Answer TopBar restore order must be disabled/focus/visible/clear: {restore_order}")

for name in ("ButtonFamilyRuntime.gd", "PopupSkin.gd", "game.gd", "Custom.gd"):
    source = (ROOT / name).read_text(encoding="utf-8")
    if "artifacts/" in source or "text90/individual" in source:
        fail(f"runtime artifact reference: {name}")

fixture_needles = {
    "ButtonFamiliesR01Test.gd": [
        "Rect2(20.0, 17.0, 440.0, 820.0)",
        "Rect2(58.0, 160.0, 332.0, 590.0)",
        "Settings BGM label keeps at least 8px",
        "Settings close hitbox is 130x70",
        "Settings close art keeps 78px",
        "Vector2(112.5, 751.0)",
        "Vector2(255.0, 93.0)",
        "Vector2(1.5, 1.5)",
        "Rect2(0.0, 0.0, 255.0, 93.0)",
        "Rect2(0.0, 8.0, 130.0, 54.0)",
    ],
    "R02RuntimeVisualCapture.gd": [
        'const OUTPUT_DIR := "res://artifacts/ui_audit_capture_r05_answer_nav_visual_restore_20260831"',
        "Rect2(20.0, 17.0, 440.0, 820.0)",
        "Rect2(58.0, 160.0, 332.0, 590.0)",
        "Settings BGM label keeps 8px",
        "Settings Close art keeps 78px",
        "Vector2(112.5, 751.0)",
        "Vector2(255.0, 93.0)",
        "Vector2(1.5, 1.5)",
        "Result Back stays fully inside the 480x854 viewport",
        "Answer view does not draw %s",
        "Answer view blocks pointer activation for %s",
        "Answer view removes %s from focus",
        "Result Back has no visible overlap with %s",
        "await get_tree().create_timer(0.13).timeout",
        "_assert_restored_top_bar_button(top_home",
        "_assert_restored_top_bar_button(top_settings",
        "Answer return clears saved TopBar state",
        "feedback modulate returns to its pre-Answer rest state",
    ],
    "ResultUiImprovementsTest.gd": [
        '_assert_answer_top_bar_hidden(top_home, top_settings, "Answer entry")',
        "duplicate Answer entry does not overwrite saved TopBar state",
        "system Back restores Home exactly",
        "system Back restores Settings exactly",
        "explicit return restores visible Home state",
        "explicit return restores hidden Settings state",
        "system Back clears saved TopBar state",
        "explicit return clears saved TopBar state",
        "await get_tree().create_timer(0.13).timeout",
        "feedback scale returns to one",
        "feedback modulate returns to its pre-Answer rest state",
    ],
}
for name, needles in fixture_needles.items():
    source = {
        "ButtonFamiliesR01Test.gd": button_test,
        "R02RuntimeVisualCapture.gd": capture_test,
        "ResultUiImprovementsTest.gd": result_ui_test,
    }[name]
    for needle in needles:
        if needle not in source:
            fail(f"fixture expectation missing {name}: {needle}")

topbar_home = (294.0, 780.0, 84.0, 84.0)
overlap_left = max(result_back[0], topbar_home[0])
overlap_top = max(result_back[1], topbar_home[1])
overlap_right = min(result_back[0] + result_back[2], topbar_home[0] + topbar_home[2])
overlap_bottom = min(result_back[1] + result_back[3], topbar_home[1] + topbar_home[3])
overlap = (max(0.0, overlap_right - overlap_left), max(0.0, overlap_bottom - overlap_top))
if overlap != (73.5, 64.0):
    fail(f"Result Back/TopBar Home geometry changed: overlap={overlap}")
print(f"INFO result_back_topbar_geometry_overlap={overlap[0]}x{overlap[1]} answer_view_nav_hidden=1 visible_overlap=0")
print("PASS button_families_r02_static frames=3 exact20=20 art_rects=5 fonts=5 b26_unchanged=1 exact4_unchanged=1 result_back_scale=1.5 settings_panel=440x820 preserved_home_credit=1 answer_topbar_hide_restore=1 feedback_restore_order=1 visual_rest_fixture=1 fallback=0 godot=0")
