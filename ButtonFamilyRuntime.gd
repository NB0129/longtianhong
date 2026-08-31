extends RefCounted

# Shared, textless-button treatment for the owner-adopted Button Families.
# The source frames remain art-only; visible copy is always supplied at runtime.
const KAISEI_DECOL_BOLD := "res://assets/font/kaisei_decol_bold_700/KaiseiDecol-Bold.ttf"
const TEXT_FILL := Color(1.0, 0.9372549, 0.7098039, 1.0)
const TEXT_OUTLINE := Color(0.3490196, 0.0666667, 0.054902, 1.0)
const TEXT_SHADOW := Color(0.0784314, 0.0117647, 0.0156863, 0.7215686)
const SAFE_TEXT_LEFT_RIGHT_RATIO := 0.20

# [font_size, label_x, label_y] values are Godot Label placements. They are
# deliberately not the preview PNG's visible-ink bounding-box coordinates.
const INK_LAYOUTS := {
	"custom_start": {"ja": [23, 42, 8], "en": [22, 44, 7], "zh_CN": [29, 44, 4], "zh_TW": [29, 44, 4], "ko": [29, 44, 4]},
	# OWNER_VISUAL_ACCEPTED: retained R01 B at its unchanged 154x54 target.
	"custom_back": {"ja": [26, 53, 5], "en": [26, 45, 6], "zh_CN": [26, 52, 6], "zh_TW": [26, 52, 6], "ko": [26, 53, 6]},
	# OWNER_VISUAL_ACCEPTED: R02 TEXT90 Godot runtime tuples.
	"result_back": {"ja": [24, 63, 11], "en": [26, 53, 10], "zh_CN": [23, 62, 12], "zh_TW": [23, 62, 12], "ko": [23, 63, 12]},
	"confirm_yes": {"ja": [23, 32, 4], "en": [24, 35, 4], "zh_CN": [18, 46, 9], "zh_TW": [18, 46, 9], "ko": [18, 47, 9]},
	"confirm_no": {"ja": [19, 26, 7], "en": [23, 39, 5], "zh_CN": [19, 46, 7], "zh_TW": [19, 46, 7], "ko": [18, 30, 9]},
	"close": {"ja": [22, 32, 7], "en": [21, 35, 9], "zh_CN": [21, 43, 9], "zh_TW": [23, 41, 7], "ko": [22, 44, 8]},
}
const INK_BASE_SIZES := {
	"custom_start": Vector2(204.0, 54.0),
	"custom_back": Vector2(154.0, 54.0),
	"result_back": Vector2(170.0, 62.0),
	"confirm_yes": Vector2(112.0, 48.0),
	"confirm_no": Vector2(112.0, 48.0),
	"close": Vector2(130.0, 54.0),
}

static var _kaisei_base: FontFile = null
static var _font_stacks: Dictionary = {}


static func apply(button: Button, art_path: String, target_size: Vector2, visible_text: String, locale: String, variant: String = "default", visible_height_ratio: float = 1.0, art_rect: Rect2 = Rect2()) -> void:
	if button == null or not is_instance_valid(button):
		return
	var has_explicit_art_rect := art_rect.size.x > 0.0 and art_rect.size.y > 0.0
	var resolved_art_rect := art_rect if has_explicit_art_rect else Rect2(Vector2.ZERO, target_size)
	button.text = ""
	button.icon = null
	button.expand_icon = false
	button.flat = true
	button.custom_minimum_size = target_size
	button.size = target_size
	button.clip_contents = false
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_stylebox_override("focus", _make_focus_style())
	var art := button.get_node_or_null("ButtonFamilyArt") as TextureRect
	if art == null:
		art = TextureRect.new()
		art.name = "ButtonFamilyArt"
		button.add_child(art)
	art.set_anchors_preset(Control.PRESET_TOP_LEFT)
	art.position = resolved_art_rect.position
	art.size = resolved_art_rect.size
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.clip_contents = false
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.modulate = _art_tint(variant, art_path)
	art.texture = load(art_path) as Texture2D
	if art.texture == null:
		push_error("[ButtonFamilyRuntime] Failed to load button-family frame: %s" % art_path)
	button.move_child(art, 0)
	var label := button.get_node_or_null("ButtonFamilyText") as Label
	if label == null:
		label = Label.new()
		label.name = "ButtonFamilyText"
		button.add_child(label)
	label.anchor_left = 0.0
	label.anchor_top = 0.0
	label.anchor_right = 0.0
	label.anchor_bottom = 0.0
	label.offset_left = 0.0
	label.offset_top = 0.0
	label.offset_right = 0.0
	label.offset_bottom = 0.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	label.clip_text = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", TEXT_FILL)
	label.add_theme_color_override("font_outline_color", TEXT_OUTLINE)
	label.add_theme_color_override("font_shadow_color", TEXT_SHADOW)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	button.set_meta("button_family_runtime_text", true)
	button.set_meta("button_family_variant", variant)
	button.set_meta("button_family_safe_text_ratio", SAFE_TEXT_LEFT_RIGHT_RATIO)
	button.set_meta("button_family_target_size", target_size)
	button.set_meta("button_family_art_rect", resolved_art_rect)
	var resolved_visible_height_ratio := visible_height_ratio
	if has_explicit_art_rect and target_size.y > 0.0:
		resolved_visible_height_ratio = resolved_art_rect.size.y / target_size.y
	button.set_meta("button_family_visible_height_ratio", clampf(resolved_visible_height_ratio, 0.1, 1.0))
	button.set_meta("button_family_frame_revision", "r02" if art_path.contains("/button_families_r02/") else "r01")
	button.set_meta("button_family_ink_centered", true)
	set_text(button, visible_text, locale)


static func set_text(button: Button, visible_text: String, locale: String) -> void:
	if button == null or not is_instance_valid(button):
		return
	var label := button.get_node_or_null("ButtonFamilyText") as Label
	if label == null:
		return
	var normalized := str(SaveData.normalize_language_code(locale))
	var font := _font_for_locale(normalized)
	if font == null:
		return
	label.text = visible_text
	label.language = normalized.replace("_", "-")
	label.add_theme_font_override("font", font)
	var effective_size: Vector2 = button.get_meta("button_family_target_size", button.custom_minimum_size)
	if effective_size.x <= 0.0 or effective_size.y <= 0.0:
		effective_size = button.size
	var effective_art_rect: Rect2 = button.get_meta("button_family_art_rect", Rect2(Vector2.ZERO, effective_size))
	var layout_key := _ink_layout_key(str(button.get_meta("button_family_variant", "")))
	var per_locale: Dictionary = INK_LAYOUTS.get(layout_key, INK_LAYOUTS["custom_back"])
	var layout: Array = per_locale.get(normalized, per_locale["ja"])
	var base_size: Vector2 = INK_BASE_SIZES.get(layout_key, effective_art_rect.size)
	var scale_x := effective_art_rect.size.x / base_size.x if base_size.x > 0.0 else 1.0
	var scale_y := effective_art_rect.size.y / base_size.y if base_size.y > 0.0 else 1.0
	var selected_size := maxi(10, roundi(float(layout[0]) * scale_y))
	label.position = effective_art_rect.position + Vector2(float(layout[1]) * scale_x, float(layout[2]) * scale_y)
	label.size = effective_art_rect.size
	label.add_theme_font_size_override("font_size", selected_size)
	label.set_meta("button_family_ink_layout_key", layout_key)
	label.set_meta("button_family_ink_draw_position", label.position)
	label.set_meta("button_family_ink_scale", Vector2(scale_x, scale_y))
	label.set_meta("button_family_art_rect", effective_art_rect)
	label.set_meta("button_family_locale", normalized)
	label.set_meta("button_family_font_size", selected_size)
	button.accessibility_name = visible_text
	button.text = ""


static func _ink_layout_key(variant: String) -> String:
	if variant == "settings_close" or variant == "credit_close":
		return "close"
	return variant


static func _font_for_locale(locale: String) -> Font:
	var normalized := str(SaveData.normalize_language_code(locale))
	if normalized == "zh_CN" or normalized == "zh_TW" or normalized == "ko":
		return LocaleFonts.font_for_locale(normalized)
	if _font_stacks.has(normalized):
		return _font_stacks[normalized] as Font
	if _kaisei_base == null:
		_kaisei_base = load(KAISEI_DECOL_BOLD) as FontFile
		if _kaisei_base == null:
			push_error("[ButtonFamilyRuntime] Failed to load Kaisei Decol Bold: %s" % KAISEI_DECOL_BOLD)
			return null
		_kaisei_base.allow_system_fallback = false
	var stack := FontVariation.new()
	stack.base_font = _kaisei_base
	var regional_fallback := LocaleFonts.font_for_locale(normalized)
	if regional_fallback != null:
		var fallbacks: Array[Font] = [regional_fallback]
		stack.fallbacks = fallbacks
	_font_stacks[normalized] = stack
	return stack


static func _art_tint(variant: String, art_path: String) -> Color:
	# R02 owner-approved previews use the exact un-tinted frame for Yes and No.
	if art_path.contains("/button_families_r02/"):
		return Color.WHITE
	match variant:
		"confirm_yes":
			return Color(1.0, 0.96, 0.88, 1.0)
		"confirm_no":
			return Color(0.72, 0.84, 1.0, 1.0)
	return Color.WHITE


static func _make_focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = Color(1.0, 0.88, 0.45, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.expand_margin_left = 2.0
	style.expand_margin_top = 2.0
	style.expand_margin_right = 2.0
	style.expand_margin_bottom = 2.0
	return style
