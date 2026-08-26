extends Control

const LOCALES := ["ja", "en", "zh_CN", "zh_TW", "ko"]
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
const LANGUAGE_LABELS := {
	"ja": "日本語",
	"en": "English",
	"zh_CN": "简体中文",
	"zh_TW": "繁體中文",
	"ko": "한국어",
}
const THEME_PATH := "res://assets/font/locale_theme.tres"
const LOCALE_FONTS_PATH := "res://LocaleFonts.gd"
const PROJECT_PATH := "res://project.godot"
const EXPORT_PRESETS_PATH := "res://export_presets.cfg"
const TITLE_PATH := "res://title.gd"
const IPA_PATH := "res://assets/font/IPA_Font_License_Agreement_v1.0.txt"
const OFL_PATH := "res://assets/font/noto_cjk_2_004/OFL-1.1.txt"
const ASCII_REQUIRED := " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!?.,:;+-/%()[]'\""

var _failed := false
var _corpus: Dictionary = {}
var _source_files: PackedStringArray = []
var _quoted_string_regex := RegEx.new()
var _locale_entry_regex := RegEx.new()
var _original_language := "ja"
var _original_translation_locale := "ja"


func _ready() -> void:
	_original_language = SaveData.normalize_language_code(SaveData.language_code)
	_original_translation_locale = TranslationServer.get_locale()
	for locale in LOCALES:
		_corpus[locale] = {}
	_assert(_quoted_string_regex.compile("\"(?:\\\\.|[^\"\\\\])*\"") == OK, "quoted-string scanner compiles")
	_assert(_locale_entry_regex.compile("^\\s*\"(ja|en|zh_CN|zh_TW|ko)\"\\s*:\\s*(.*)$") == OK, "locale-entry scanner compiles")
	_collect_source_files("res://")
	_validate_font_resources_and_stacks()
	_collect_production_corpus()
	_validate_production_coverage()
	_validate_no_system_font()
	await _validate_project_theme_switching()
	_validate_language_buttons()
	_validate_legal_and_export_wiring()
	_restore_locale()
	if _failed:
		get_tree().quit(1)
		return
	var counts := PackedStringArray()
	for locale in LOCALES:
		counts.append("%s=%d" % [locale, (_corpus[locale] as Dictionary).size()])
	print("PASS machiate_locale_fonts corpus_codepoints[%s] sources=%d unique_fonts=4 system_fonts=0" % [", ".join(counts), _source_files.size()])
	get_tree().quit(0)


func _collect_source_files(directory_path: String) -> void:
	var directory := DirAccess.open(directory_path)
	_assert(directory != null, "source directory opens: %s" % directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry.is_empty():
			break
		if entry.begins_with("."):
			continue
		var path := directory_path.path_join(entry)
		if directory.current_is_dir():
			if path in ["res://tests", "res://tools", "res://android", "res://build", "res://ios_export"]:
				continue
			_collect_source_files(path)
		elif path.get_extension().to_lower() in ["gd", "tscn", "tres"]:
			_source_files.append(path)
	directory.list_dir_end()


func _validate_font_resources_and_stacks() -> void:
	_assert(str(ProjectSettings.get_setting("gui/theme/custom", "")) == THEME_PATH, "project uses locale_theme.tres")
	_assert(ResourceLoader.exists(THEME_PATH), "locale Theme exists")
	_assert(load(THEME_PATH) is Theme, "locale Theme parses")
	_assert(ResourceLoader.exists(LOCALE_FONTS_PATH), "LocaleFonts autoload script exists")
	var project_source := FileAccess.get_file_as_string(PROJECT_PATH)
	_assert(project_source.contains("LocaleFonts=\"*res://LocaleFonts.gd\""), "LocaleFonts is registered as an autoload")
	var unique_paths := {}
	for locale in LOCALES:
		var path := str(FONT_PATHS[locale])
		unique_paths[path] = true
		_assert(ResourceLoader.exists(path), "%s bundled base font exists" % locale)
		var font := load(path) as FontFile
		_assert(font != null, "%s bundled base font loads as FontFile" % locale)
		if font != null:
			_assert(not font.allow_system_fallback, "%s FontFile disables runtime system fallback" % locale)
		var import_text := FileAccess.get_file_as_string(path + ".import")
		_assert(not import_text.is_empty(), "%s font import metadata exists" % locale)
		_assert(import_text.contains("allow_system_fallback=false"), "%s font import disables system fallback" % locale)
		var stack := LocaleFonts.font_for_locale(locale) as FontVariation
		_assert(stack != null, "%s bundled font stack resolves" % locale)
		if stack == null:
			continue
		var order: Array = STACK_ORDER[locale]
		_assert(stack.base_font != null and stack.base_font.resource_path == str(FONT_PATHS[order[0]]), "%s stack has the correct base font" % locale)
		_assert(stack.fallbacks.size() == order.size() - 1, "%s stack has the expected bundled fallback count" % locale)
		for index in range(stack.fallbacks.size()):
			var expected_path := str(FONT_PATHS[order[index + 1]])
			_assert(stack.fallbacks[index] != null and stack.fallbacks[index].resource_path == expected_path, "%s stack fallback %d is correct" % [locale, index])
	_assert(unique_paths.size() == 4, "five locale mappings use exactly four unique bundled FontFiles")


func _collect_production_corpus() -> void:
	for locale in LOCALES:
		_record_text(locale, ASCII_REQUIRED, "required ASCII")
		_record_text(locale, str(LANGUAGE_LABELS[locale]), "language selector")
	for path in _source_files:
		if path.get_extension().to_lower() not in ["gd", "tscn"]:
			continue
		var source := FileAccess.get_file_as_string(path)
		_assert(not source.is_empty(), "production source is readable: %s" % path)
		_scan_production_source(path, source)
	for locale in LOCALES:
		var codepoints := _corpus[locale] as Dictionary
		_assert(codepoints.size() >= 70, "%s production corpus is non-trivial" % locale)
	_assert(_contains_codepoint_in_range(_corpus["ja"], 0x3040, 0x30FF), "Japanese corpus includes kana")
	_assert(_contains_codepoint_in_range(_corpus["zh_CN"], 0x3400, 0x9FFF), "Simplified Chinese corpus includes ideographs")
	_assert(_contains_codepoint_in_range(_corpus["zh_TW"], 0x3400, 0x9FFF), "Traditional Chinese corpus includes ideographs")
	_assert(_contains_codepoint_in_range(_corpus["ko"], 0xAC00, 0xD7A3), "Korean corpus includes Hangul syllables")


func _scan_production_source(path: String, source: String) -> void:
	var active_locale := ""
	var brace_depth := 0
	var lines := source.split("\n")
	for line_index in range(lines.size()):
		var line := str(lines[line_index])
		var source_location := "%s:%d" % [path, line_index + 1]
		if active_locale.is_empty():
			var locale_match := _locale_entry_regex.search(line)
			if locale_match != null:
				var locale := locale_match.get_string(1)
				_record_quoted_strings(locale, line, source_location)
				brace_depth = _brace_delta(line)
				if brace_depth > 0:
					active_locale = locale
				continue
			if _record_language_option_line(line, source_location):
				continue
			for value in _decoded_strings(line):
				if _contains_japanese_text(value):
					_record_text("ja", value, source_location)
		else:
			_record_quoted_strings(active_locale, line, source_location)
			brace_depth += _brace_delta(line)
			if brace_depth <= 0:
				active_locale = ""
				brace_depth = 0


func _record_language_option_line(line: String, source_location: String) -> bool:
	if not line.contains("\"code\"") or not line.contains("\"label\""):
		return false
	var values := _decoded_strings(line)
	var locale := ""
	var label := ""
	for index in range(values.size() - 1):
		if values[index] == "code":
			locale = values[index + 1]
		elif values[index] == "label":
			label = values[index + 1]
	if locale in LOCALES and not label.is_empty():
		_record_text(locale, label, source_location)
		return true
	return false


func _record_quoted_strings(locale: String, line: String, source_location: String) -> void:
	for value in _decoded_strings(line):
		_record_text(locale, value, source_location)


func _decoded_strings(line: String) -> PackedStringArray:
	var values := PackedStringArray()
	for matched in _quoted_string_regex.search_all(line):
		var parsed: Variant = JSON.parse_string(matched.get_string())
		if typeof(parsed) == TYPE_STRING:
			values.append(str(parsed))
	return values


func _brace_delta(line: String) -> int:
	var outside_quotes := ""
	var quoted := false
	var escaped := false
	for index in range(line.length()):
		var character := line[index]
		if quoted:
			if escaped:
				escaped = false
			elif character == "\\":
				escaped = true
			elif character == "\"":
				quoted = false
		elif character == "\"":
			quoted = true
		else:
			outside_quotes += character
	return outside_quotes.count("{") - outside_quotes.count("}")


func _record_text(locale: String, text: String, source_location: String) -> void:
	if locale not in LOCALES:
		return
	var codepoints := _corpus[locale] as Dictionary
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if _skip_codepoint(codepoint):
			continue
		if not codepoints.has(codepoint):
			codepoints[codepoint] = source_location


func _skip_codepoint(codepoint: int) -> bool:
	return codepoint < 0x20 \
			or (codepoint >= 0x7F and codepoint <= 0x9F) \
			or codepoint == 0x200B \
			or codepoint == 0x200C \
			or codepoint == 0x200D \
			or (codepoint >= 0xFE00 and codepoint <= 0xFE0F)


func _contains_japanese_text(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if (codepoint >= 0x3040 and codepoint <= 0x30FF) \
				or (codepoint >= 0x3400 and codepoint <= 0x9FFF) \
				or (codepoint >= 0xFF01 and codepoint <= 0xFF60):
			return true
	return false


func _contains_codepoint_in_range(codepoints: Dictionary, first: int, last: int) -> bool:
	for codepoint in codepoints:
		if int(codepoint) >= first and int(codepoint) <= last:
			return true
	return false


func _validate_production_coverage() -> void:
	for locale in LOCALES:
		var font := load(str(FONT_PATHS[locale])) as FontFile
		if font == null:
			continue
		var missing := PackedStringArray()
		var codepoints := _corpus[locale] as Dictionary
		for codepoint in codepoints:
			if not font.has_char(int(codepoint)):
				missing.append("U+%04X(%s)@%s" % [int(codepoint), String.chr(int(codepoint)), codepoints[codepoint]])
		missing.sort()
		var sample := ", ".join(missing.slice(0, mini(12, missing.size())))
		_assert(missing.is_empty(), "%s base font misses %d production codepoints: %s" % [locale, missing.size(), sample])


func _validate_no_system_font() -> void:
	var hits := PackedStringArray()
	for path in _source_files:
		var source := FileAccess.get_file_as_string(path)
		if source.contains("SystemFont"):
			hits.append(path)
	_assert(hits.is_empty(), "production source contains no SystemFont resources or constructors: %s" % ", ".join(hits))


func _validate_project_theme_switching() -> void:
	for locale in LOCALES:
		LocaleFonts.call("_apply_locale", locale)
		await get_tree().process_frame
		var expected := LocaleFonts.font_for_locale(locale)
		var project_theme := ThemeDB.get_project_theme()
		_assert(project_theme != null and project_theme.default_font == expected, "%s switch updates the project Theme default font" % locale)
		_assert(ThemeDB.fallback_font == expected, "%s switch updates the engine fallback font without using the OS" % locale)
		var label := Label.new()
		label.text = str(LANGUAGE_LABELS[locale])
		add_child(label)
		var button := Button.new()
		button.text = str(LANGUAGE_LABELS[locale])
		add_child(button)
		await get_tree().process_frame
		_assert(label.get_theme_font("font") == expected, "%s newly created Label resolves the selected project stack" % locale)
		_assert(button.get_theme_font("font") == expected, "%s newly created Button resolves the selected project stack" % locale)
		remove_child(label)
		label.free()
		remove_child(button)
		button.free()


func _validate_language_buttons() -> void:
	for locale in LOCALES:
		var button := CheckBox.new()
		button.name = "BtnLanguage" + locale.replace("_", "")
		button.text = str(LANGUAGE_LABELS[locale])
		LocaleFonts.apply_language_button(button, locale)
		add_child(button)
		var expected := LocaleFonts.font_for_locale(locale)
		_assert(button.has_theme_font_override("font"), "%s language button has an explicit bundled font override" % locale)
		_assert(button.get_theme_font("font") == expected, "%s language button resolves its own locale stack" % locale)
		_assert(button.language == locale.replace("_", "-"), "%s language button has the correct shaping language" % locale)
		_assert(str(button.get_meta("locale_font_code", "")) == locale, "%s language button records its normalized locale" % locale)
		remove_child(button)
		button.free()


func _validate_legal_and_export_wiring() -> void:
	_assert(FileAccess.file_exists(IPA_PATH), "IPA license is bundled")
	_assert(FileAccess.get_file_as_string(IPA_PATH).contains("IPA Font License Agreement v1.0"), "IPA license text is valid")
	_assert(FileAccess.file_exists(OFL_PATH), "Noto SIL OFL is bundled")
	_assert(FileAccess.get_file_as_string(OFL_PATH).contains("SIL OPEN FONT LICENSE Version 1.1"), "Noto SIL OFL text is valid")
	var title_source := FileAccess.get_file_as_string(TITLE_PATH)
	_assert(title_source.contains("const PATH_IPA_LICENSE := \"" + IPA_PATH + "\""), "title legal view declares the IPA license path")
	_assert(title_source.contains("const PATH_NOTO_OFL := \"" + OFL_PATH + "\""), "title legal view declares the Noto OFL path")
	_assert(title_source.contains("_read_legal_text(PATH_IPA_LICENSE)"), "title legal view reads the IPA license")
	_assert(title_source.contains("_read_legal_text(PATH_NOTO_OFL)"), "title legal view reads the Noto OFL")
	_assert(title_source.contains("BtnLicenses"), "credits provide a separate licenses and OSS view")
	var export_source := FileAccess.get_file_as_string(EXPORT_PRESETS_PATH)
	_assert(export_source.count("assets/font/IPA_Font_License_Agreement_v1.0.txt") >= 2, "all release export presets include the IPA license")
	_assert(export_source.count("assets/font/noto_cjk_2_004/OFL-1.1.txt") >= 2, "all release export presets include the Noto OFL")


func _restore_locale() -> void:
	SaveData.language_code = _original_language
	LocaleFonts.call("_apply_locale", _original_language)
	TranslationServer.set_locale(_original_translation_locale)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
