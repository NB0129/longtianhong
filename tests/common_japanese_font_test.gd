extends Control

const FONT_PATH := "res://assets/font/font_1_kokumr_1.00_rls.ttf"
const THEME_PATH := "res://assets/font/locale_theme.tres"
const LICENSE_PATH := "res://assets/font/IPA_Font_License_Agreement_v1.0.txt"
const EXPORT_PRESETS_PATH := "res://export_presets.cfg"
const TITLE_SCRIPT_PATH := "res://title.gd"
const TALK_SCRIPT_PATH := "res://TalkScene.gd"

const STATIC_SURFACES := {
	"Title": "res://Title.tscn",
	"StageSelect": "res://StageSelect.tscn",
	"MusicRoom": "res://MusicRoom.tscn",
	"custom": "res://custom.tscn",
	"game": "res://game.tscn",
}

const DYNAMIC_SURFACES := {
	"Title": "res://title.gd",
	"StageSelect": "res://StageSelect.gd",
	"MusicRoom": "res://MusicRoom.gd",
	"custom": "res://Custom.gd",
	"game": "res://game.gd",
	"TalkLocalization": "res://TalkLocalization.gd",
}

const DYNAMIC_SOURCE_RANGES := {
	"Title": [Vector2i(28, 35)],
	"StageSelect": [Vector2i(545, 561), Vector2i(709, 721)],
	"MusicRoom": [Vector2i(9, 29), Vector2i(129, 131), Vector2i(157, 159), Vector2i(739, 744)],
	"custom": [Vector2i(22, 38)],
	"game": [Vector2i(12, 29), Vector2i(158, 171), Vector2i(383, 393), Vector2i(974, 999), Vector2i(1745, 1748), Vector2i(2040, 2047), Vector2i(2243, 2257), Vector2i(2538, 2538), Vector2i(2688, 2688), Vector2i(2770, 2772), Vector2i(3008, 3025)],
	"TalkLocalization": [Vector2i(6, 6), Vector2i(21, 21)],
}

const EXPECTED_JAPANESE_CODEPOINT_COUNT := 316
const EXPECTED_JAPANESE_MANIFEST_SHA256 := "84CEDB756D2EA8D44E73B0B32CE13C5DAECF43EB94F69D59D4F4A534B59F817F"

const REPRESENTATIVE_TEXT := {
	"Title": "設定　BGM音量　SE音量\n牌の種類　筒子　索子　萬子　閉じる",
	"StageSelect": "ステージ選択　難易度\nサポート　戻る",
	"MusicRoom": "再生　一時停止　停止\n全曲リスト　同じ曲を繰り返し",
	"custom": "難易度　理牌　タイム　秒数\n問題数　ゲーム開始",
	"game": "クリア　提出　正解：なし\n結果　もう一度　ホーム",
}

@export var capture_only := false
@export var capture_viewport_size := Vector2i.ZERO

var _failed := false
var _font: FontFile
var _package_mode := false
var _coverage: Dictionary = {}
var _surface_counts: Dictionary = {}
var _representative_labels: Array[Label] = []
var _representative_buttons: Array[Button] = []


func _enter_tree() -> void:
	if capture_viewport_size != Vector2i.ZERO:
		get_window().size = capture_viewport_size
		get_window().content_scale_size = capture_viewport_size


func _ready() -> void:
	LocaleFonts.call("_apply_locale", "ja")
	await get_tree().process_frame
	_validate_project_binding()
	_package_mode = FileAccess.get_file_as_string(TITLE_SCRIPT_PATH).is_empty()
	_validate_license_and_provenance()
	_validate_static_surfaces()
	_validate_dynamic_surfaces()
	_validate_coverage_manifest()
	_validate_talk_scene_overrides()
	_build_representative_surface()
	await get_tree().process_frame
	_validate_representative_surface()
	if _failed:
		get_tree().quit(1)
		return
	print("PASS machiate_common_japanese_font coverage=%d surfaces=%d capture=%d package=%d" % [_coverage.size(), STATIC_SURFACES.size(), int(capture_only), int(_package_mode)])
	if not capture_only:
		get_tree().quit(0)


func _validate_project_binding() -> void:
	_assert(str(ProjectSettings.get_setting("gui/theme/custom", "")) == THEME_PATH, "project-wide Theme points to the locale font theme")
	_assert(str(ProjectSettings.get_setting("gui/theme/custom_font", "")).is_empty(), "legacy project custom_font binding is removed")
	_assert(ResourceLoader.exists(THEME_PATH), "locale font Theme resource exists")
	_assert(load(THEME_PATH) is Theme, "locale font Theme parses as Theme")
	_assert(ResourceLoader.exists(FONT_PATH), "bundled Koku Mincho resource exists")
	_font = load(FONT_PATH) as FontFile
	_assert(_font != null, "bundled Koku Mincho loads as FontFile")
	if _font != null:
		_assert(_font.get_font_name() == "Koku Mincho Regular", "font identity is Koku Mincho Regular")
		_assert(not _font.allow_system_fallback, "Koku Mincho disables system fallback")
	_assert(ThemeDB.get_project_theme().default_font == LocaleFonts.font_for_locale("ja"), "Japanese locale stack is active in the project Theme")


func _validate_license_and_provenance() -> void:
	_assert(FileAccess.file_exists(LICENSE_PATH), "IPA Font License Agreement accompanies the font")
	var license_text := FileAccess.get_file_as_string(LICENSE_PATH)
	_assert(license_text.contains("IPA Font License Agreement v1.0"), "IPA Font License Agreement text is present")
	if not _package_mode:
		var title_source := FileAccess.get_file_as_string(TITLE_SCRIPT_PATH)
		_assert(title_source.contains("Koku Mincho Regular"), "credits identify Koku Mincho Regular")
		_assert(title_source.contains("freefontnoki, Information-technology Promotion Agency, Japan (IPA)"), "credits retain font copyright provenance")
		var export_source := FileAccess.get_file_as_string(EXPORT_PRESETS_PATH)
		_assert(export_source.contains("assets/font/IPA_Font_License_Agreement_v1.0.txt"), "export presets include the IPA license")


func _validate_static_surfaces() -> void:
	for surface in STATIC_SURFACES:
		var before := _coverage.size()
		var scene_path := str(STATIC_SURFACES[surface])
		_assert(ResourceLoader.exists(scene_path), "%s scene resource exists" % surface)
		_assert(load(scene_path) is PackedScene, "%s scene parses as PackedScene" % surface)
		var source := FileAccess.get_file_as_string(scene_path)
		if _package_mode:
			continue
		_assert(not source.is_empty(), "%s scene source is readable" % surface)
		for line in source.split("\n"):
			var stripped := line.strip_edges()
			var prefix := ""
			for candidate in ["text", "placeholder_text", "tooltip_text"]:
				if stripped.begins_with(candidate + " = "):
					prefix = candidate
					break
			if prefix.is_empty():
				continue
			var parsed: Variant = JSON.parse_string(stripped.substr(prefix.length() + 3))
			if typeof(parsed) == TYPE_STRING:
				_record_supported_text(surface, str(parsed))
		_surface_counts[surface] = _coverage.size() - before


func _validate_dynamic_surfaces() -> void:
	var quoted := RegEx.new()
	_assert(quoted.compile("\"(?:\\\\.|[^\"\\\\])*\"") == OK, "quoted-string scanner compiles")
	for surface in DYNAMIC_SURFACES:
		var script_path := str(DYNAMIC_SURFACES[surface])
		_assert(ResourceLoader.exists(script_path), "%s script resource exists" % surface)
		_assert(load(script_path) is Script, "%s script parses as Script" % surface)
		var source := FileAccess.get_file_as_string(script_path)
		if _package_mode:
			continue
		_assert(not source.is_empty(), "%s script source is readable" % surface)
		var lines := source.split("\n")
		for source_range in DYNAMIC_SOURCE_RANGES[surface]:
			var first_line := maxi(1, int(source_range.x))
			var last_line := mini(lines.size(), int(source_range.y))
			for line_number in range(first_line, last_line + 1):
				var line := str(lines[line_number - 1])
				for matched in quoted.search_all(line):
					var parsed: Variant = JSON.parse_string(matched.get_string())
					if typeof(parsed) == TYPE_STRING:
						_record_supported_text(surface, str(parsed))


func _record_supported_text(surface: String, text: String) -> void:
	if _font == null:
		return
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if not _is_japanese_codepoint(codepoint):
			continue
		_coverage[codepoint] = true
		_assert(_font.has_char(codepoint), "%s bundled font missing U+%04X" % [surface, codepoint])


func _is_japanese_codepoint(codepoint: int) -> bool:
	return (codepoint >= 0x3000 and codepoint <= 0x30FF) \
			or (codepoint >= 0x3400 and codepoint <= 0x9FFF) \
			or (codepoint >= 0xFF01 and codepoint <= 0xFF60)


func _validate_coverage_manifest() -> void:
	if _package_mode:
		return
	var codepoints := _coverage.keys()
	codepoints.sort()
	var manifest := PackedStringArray()
	for codepoint in codepoints:
		manifest.append("U+%04X" % int(codepoint))
	var serialized := ",".join(manifest)
	var actual_hash := serialized.sha256_text().to_upper()
	_assert(codepoints.size() == EXPECTED_JAPANESE_CODEPOINT_COUNT, "Japanese source-region coverage count remains exact (actual=%d)" % codepoints.size())
	_assert(actual_hash == EXPECTED_JAPANESE_MANIFEST_SHA256, "Japanese source-region coverage manifest hash remains exact (actual=%s)" % actual_hash)


func _validate_talk_scene_overrides() -> void:
	_assert(ResourceLoader.exists(TALK_SCRIPT_PATH), "TalkScene script resource exists")
	_assert(load(TALK_SCRIPT_PATH) is Script, "TalkScene script parses as Script")
	if _package_mode:
		return
	var source := FileAccess.get_file_as_string(TALK_SCRIPT_PATH)
	_assert(not source.contains("SystemFont"), "TalkScene has no environment-dependent SystemFont")
	_assert(source.contains("LocaleFonts.font_for_locale("), "TalkScene resolves its bundled locale font stack")
	_assert(source.contains("label.add_theme_font_override(\"font\", selected_font)"), "TalkScene retains explicit locale font selection")


func _build_representative_surface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("17131f")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var title := Label.new()
	title.text = "まちあて！　共通日本語フォント検証"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	_representative_labels.append(title)

	var grid := GridContainer.new()
	grid.columns = 2 if get_viewport_rect().size.x > get_viewport_rect().size.y else 1
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	column.add_child(grid)

	for surface in REPRESENTATIVE_TEXT:
		var label := Label.new()
		label.text = "%s\n%s" % [surface, REPRESENTATIVE_TEXT[surface]]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.custom_minimum_size = Vector2(200, 92)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 18)
		grid.add_child(label)
		_representative_labels.append(label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 8)
	column.add_child(actions)
	for text in ["戻る", "サポート", "ゲーム開始", "提出", "ホーム"]:
		var button := Button.new()
		button.text = text
		button.add_theme_font_size_override("font_size", 16)
		actions.add_child(button)
		_representative_buttons.append(button)


func _validate_representative_surface() -> void:
	var viewport_bounds := get_viewport_rect()
	var expected_font := LocaleFonts.font_for_locale("ja")
	for label in _representative_labels:
		var resolved := label.get_theme_font("font")
		_assert(resolved != null and resolved == expected_font, "%s inherits the project-wide Japanese bundled stack" % label.name)
		_record_supported_text("representative", label.text)
		_assert(label.get_combined_minimum_size().x <= label.size.x + 1.0, "representative text has no horizontal clipping")
		_assert(label.get_combined_minimum_size().y <= label.size.y + 1.0, "representative text has no vertical clipping")
		_assert(viewport_bounds.encloses(label.get_global_rect()), "representative text stays inside the viewport")
	for button in _representative_buttons:
		var resolved := button.get_theme_font("font")
		_assert(resolved != null and resolved == expected_font, "representative Button inherits the project-wide Japanese bundled stack")
		_record_supported_text("representative_button", button.text)
		_assert(button.get_combined_minimum_size().x <= button.size.x + 1.0, "representative Button has no horizontal clipping")
		_assert(button.get_combined_minimum_size().y <= button.size.y + 1.0, "representative Button has no vertical clipping")
		_assert(viewport_bounds.encloses(button.get_global_rect()), "representative Button stays inside the viewport")


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
