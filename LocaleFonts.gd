extends Node

const FONT_PATHS := {
	"ja": "res://assets/font/font_1_kokumr_1.00_rls.ttf",
	"en": "res://assets/font/font_1_kokumr_1.00_rls.ttf",
	"zh_CN": "res://assets/font/noto_cjk_2_004/NotoSansSC-Regular.otf",
	"zh_TW": "res://assets/font/noto_cjk_2_004/NotoSansTC-Regular.otf",
	"ko": "res://assets/font/noto_cjk_2_004/NotoSansKR-Regular.otf",
}
const STACK_ORDER := {
	"ja": ["ja", "zh_CN", "zh_TW", "ko"],
	"en": ["en", "zh_CN", "zh_TW", "ko"],
	"zh_CN": ["zh_CN", "zh_TW", "ko", "ja"],
	"zh_TW": ["zh_TW", "zh_CN", "ko", "ja"],
	"ko": ["ko", "zh_CN", "zh_TW", "ja"],
}
var _base_fonts: Dictionary = {}
var _font_stacks: Dictionary = {}


func _ready() -> void:
	_load_fonts()
	if SaveData.has_signal("language_changed") and not SaveData.language_changed.is_connected(_on_language_changed):
		SaveData.language_changed.connect(_on_language_changed)
	_apply_locale(SaveData.language_code)


func font_for_locale(locale: String) -> Font:
	var normalized: String = str(SaveData.normalize_language_code(locale))
	return _font_stacks.get(normalized, _font_stacks.get("ja")) as Font


func apply_language_button(button: Button, locale: String) -> void:
	var normalized: String = str(SaveData.normalize_language_code(locale))
	var locale_font := font_for_locale(normalized)
	if locale_font != null:
		button.add_theme_font_override("font", locale_font)
	button.language = normalized.replace("_", "-")
	button.set_meta("locale_font_code", normalized)


func _load_fonts() -> void:
	_base_fonts.clear()
	_font_stacks.clear()
	for locale: String in FONT_PATHS:
		var loaded := load(str(FONT_PATHS[locale])) as FontFile
		if loaded == null:
			push_error("[LocaleFonts] Failed to load bundled font: %s" % FONT_PATHS[locale])
			continue
		loaded.allow_system_fallback = false
		_base_fonts[locale] = loaded
	for locale: String in STACK_ORDER:
		var order: Array = STACK_ORDER[locale]
		if order.is_empty() or not _base_fonts.has(str(order[0])):
			continue
		var stack := FontVariation.new()
		stack.base_font = _base_fonts[str(order[0])] as Font
		var fallbacks: Array[Font] = []
		for index in range(1, order.size()):
			var fallback_locale := str(order[index])
			if _base_fonts.has(fallback_locale):
				fallbacks.append(_base_fonts[fallback_locale] as Font)
		stack.fallbacks = fallbacks
		_font_stacks[locale] = stack


func _apply_locale(locale: String) -> void:
	var normalized: String = str(SaveData.normalize_language_code(locale))
	var selected_font := font_for_locale(normalized)
	if selected_font == null:
		push_error("[LocaleFonts] No bundled font stack for locale: %s" % normalized)
		return
	TranslationServer.set_locale(normalized)
	var project_theme := ThemeDB.get_project_theme()
	if project_theme != null:
		project_theme.default_font = selected_font
		project_theme.emit_changed()
	ThemeDB.fallback_font = selected_font


func _on_language_changed(locale: String) -> void:
	_apply_locale(locale)
