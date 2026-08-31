extends Control

const GAME_SCENE := preload("res://game.tscn")
const BLANK_FRAME_PATH := "res://assets/ui/result_buttons/result_button_blank_r02.png"
const BUTTON_FAMILY_RESULT_BACK_PATH := "res://assets/ui/button_families_r02/result_back_compact_r02_170x62.png"
const KAISEI_FONT_PATH := "res://assets/font/kaisei_decol_bold_700/KaiseiDecol-Bold.ttf"
const CAPTURE_DIR := "res://artifacts/visual_evidence/result_r02_exact4_20260830"
const RUNTIME_BUTTON_NAMES := ["BtnRetry", "BtnHome", "BtnSubmitRanking", "BtnShowAnswer"]
const TEXT_KEYS := ["result_retry", "result_next", "result_home", "result_title", "result_ranking", "result_answer"]
const EXPECTED := {
	"ja": {
		"result_retry": "もう一度", "result_next": "次へ", "result_home": "ホーム",
		"result_title": "タイトルへ", "result_ranking": "ランキング", "result_answer": "答えを確認",
	},
	"en": {
		"result_retry": "Retry", "result_next": "Next", "result_home": "Home",
		"result_title": "To Title", "result_ranking": "Ranking", "result_answer": "Answer",
	},
	"zh_CN": {
		"result_retry": "重试", "result_next": "下一关", "result_home": "主页",
		"result_title": "返回标题", "result_ranking": "排行榜", "result_answer": "答案",
	},
	"zh_TW": {
		"result_retry": "重試", "result_next": "下一關", "result_home": "首頁",
		"result_title": "返回標題", "result_ranking": "排行榜", "result_answer": "答案",
	},
	"ko": {
		"result_retry": "다시 하기", "result_next": "다음", "result_home": "홈",
		"result_title": "타이틀로", "result_ranking": "랭킹", "result_answer": "정답 보기",
	},
}

var _failed := false
var _game: Control = null
var _original_stage := ""
var _original_instant := false
var _original_language := "ja"
var _original_timer_enabled := false
var _original_timer_seconds := 0
var _original_question_count := 0
var _original_bgm_yume := false
var _text_case_count := 0
var _worst_width := 0.0
var _worst_case := ""
var _capture_paths: Array[String] = []


func _ready() -> void:
	_original_stage = GameState.current_stage
	_original_instant = GameState.is_instant_mode
	_original_language = SaveData.language_code
	_original_timer_enabled = SaveData.custom_timer_enabled
	_original_timer_seconds = SaveData.custom_timer_seconds
	_original_question_count = SaveData.custom_question_count
	_original_bgm_yume = SaveData.custom_bgm_yume
	GameState.current_stage = "custom"
	GameState.is_instant_mode = false
	SaveData.language_code = "ja"
	SaveData.custom_timer_enabled = false
	SaveData.custom_timer_seconds = 9
	SaveData.custom_question_count = 10
	SaveData.custom_bgm_yume = true
	_game = GAME_SCENE.instantiate() as Control
	_assert(_game != null, "game scene instantiates")
	if _game == null:
		await _finish()
		return
	add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame
	var stage_intro := _game.get_node_or_null("StageIntro") as Control
	if stage_intro != null:
		stage_intro.visible = false
	_game.set("is_animating", false)
	_game.set("timer_running", false)
	await _validate_runtime_structure()
	await _validate_all_locale_texts()
	await _validate_state_visibility_and_callbacks()
	await _validate_feedback_and_disabled_state()
	await _capture_actual_result_nodes()
	await _finish()


func _prepare_result(stage: String, gameover: bool, instant: bool, state: String, force_four_visible := false) -> void:
	GameState.current_stage = stage
	GameState.is_instant_mode = instant
	_game.set("is_gameover_result", gameover)
	_game.set("is_result_answer_view", false)
	_game.set("popup_state", state)
	_game.call("_setup_popup_buttons", state)
	_game.call("_move_clear_buttons_to_result_layer")
	var popup := _game.get_node("PopupResult") as Control
	popup.visible = true
	if force_four_visible:
		for button_name in RUNTIME_BUTTON_NAMES:
			var button := _button(button_name)
			button.visible = true
			button.disabled = false
		var spacer := _game.get_node("PopupResult/ResultButtons/FinalHomeSpacer") as Control
		spacer.visible = false
	_game.call("_configure_result_focus_navigation")
	await get_tree().process_frame
	await get_tree().process_frame


func _validate_runtime_structure() -> void:
	SaveData.language_code = "ja"
	await _prepare_result("custom", true, false, "clear", true)
	var grid := _game.get_node("PopupResult/ResultButtons") as GridContainer
	_assert(grid.position == Vector2(50.0, 700.0), "result grid position remains (50,700)")
	_assert(grid.size == Vector2(380.0, 144.0), "result grid remains 380x144")
	_assert(grid.columns == 2, "result grid remains two columns")
	_assert(grid.get_theme_constant("h_separation") == 12, "result grid horizontal separation remains 12")
	_assert(grid.get_theme_constant("v_separation") == 4, "result grid vertical separation remains 4")
	var expected_positions := {
		"BtnRetry": Vector2(0.0, 0.0),
		"BtnHome": Vector2(196.0, 0.0),
		"BtnSubmitRanking": Vector2(0.0, 74.0),
		"BtnShowAnswer": Vector2(196.0, 74.0),
	}
	for button_name in RUNTIME_BUTTON_NAMES:
		var button := _button(button_name)
		_assert(button.custom_minimum_size == Vector2(184.0, 70.0), "%s minimum target remains 184x70" % button_name)
		_assert(button.size == Vector2(184.0, 70.0), "%s effective target remains 184x70" % button_name)
		_assert(button.position == expected_positions[button_name], "%s grid slot is unchanged" % button_name)
		_assert(bool(button.get_meta("result_runtime_text_button", false)), "%s uses runtime text" % button_name)
		_assert(button.text == "", "%s has no native or baked text" % button_name)
		var art := button.get_node_or_null("ResultButtonArt") as TextureRect
		var label := button.get_node_or_null("ResultButtonText") as Label
		_assert(art != null and art.texture != null, "%s has a blank frame texture" % button_name)
		if art != null and art.texture != null:
			_assert(art.texture.resource_path == BLANK_FRAME_PATH, "%s references only the adopted blank frame" % button_name)
			_assert(art.size == Vector2(184.0, 70.0), "%s blank frame fills 184x70" % button_name)
		_assert(label != null, "%s has a runtime Label child" % button_name)
		if label != null:
			_assert(is_equal_approx(label.position.x, 38.0) and is_equal_approx(label.position.y, -2.0), "%s runtime text is centered in 108px and shifted Y=-2" % button_name)
			_assert(label.size == Vector2(108.0, 70.0), "%s runtime text composite box is 108x70" % button_name)
			_assert(label.autowrap_mode == TextServer.AUTOWRAP_OFF, "%s wrapping is disabled" % button_name)
			_assert(label.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "%s trimming and ellipsis are disabled" % button_name)
			_assert(not label.clip_text, "%s clipping is disabled" % button_name)
			_assert(label.get_theme_color("font_color").is_equal_approx(Color.from_rgba8(255, 239, 181, 255)), "%s fill color is exact" % button_name)
			_assert(label.get_theme_color("font_outline_color").is_equal_approx(Color.from_rgba8(89, 17, 14, 255)), "%s outline color is exact" % button_name)
			_assert(label.get_theme_color("font_shadow_color").is_equal_approx(Color.from_rgba8(20, 3, 4, 184)), "%s shadow color is exact" % button_name)
			_assert(label.get_theme_constant("outline_size") == 1, "%s outline is 1px" % button_name)
			_assert(label.get_theme_constant("shadow_offset_x") == 1 and label.get_theme_constant("shadow_offset_y") == 1, "%s shadow offset is (1,1)" % button_name)
		_assert(button.has_meta("button_feedback_installed"), "%s keeps shared held feedback" % button_name)
		_assert(button.get_theme_stylebox("focus") is StyleBoxFlat, "%s keeps a visible focus style" % button_name)
	var btn_back := _button("BtnBackToResult")
	_assert(not bool(btn_back.get_meta("result_runtime_text_button", false)), "BtnBackToResult remains outside exact4 runtime text")
	_assert(bool(btn_back.get_meta("button_family_runtime_text", false)), "BtnBackToResult uses Button Families R02 runtime text")
	_assert(btn_back.position == Vector2(112.5, 751.0) and btn_back.custom_minimum_size == Vector2(255.0, 93.0), "BtnBackToResult uses the owner-adopted 1.5x geometry")
	var back_label := btn_back.get_node_or_null("ButtonFamilyText") as Label
	_assert(back_label != null and back_label.text == "戻る", "BtnBackToResult renders its localized runtime label")
	_assert(back_label != null and back_label.get_meta("button_family_ink_scale", Vector2.ZERO) == Vector2(1.5, 1.5), "BtnBackToResult text and frame scale together by 1.5")
	var back_art := btn_back.get_node_or_null("ButtonFamilyArt") as TextureRect
	_assert(back_art != null and back_art.texture != null and back_art.texture.resource_path == BUTTON_FAMILY_RESULT_BACK_PATH, "BtnBackToResult uses only the adopted R02 result frame")


func _validate_all_locale_texts() -> void:
	for locale: String in EXPECTED:
		SaveData.language_code = locale
		for text_key: String in TEXT_KEYS:
			var button := _button_for_text_key(text_key)
			_game.call("_set_result_button_semantics", button, text_key)
			var expected_text := str(EXPECTED[locale][text_key])
			var label := button.get_node("ResultButtonText") as Label
			_assert(button.accessibility_name == expected_text, "%s %s accessibility name is localized" % [locale, text_key])
			_assert(label.text == expected_text, "%s %s runtime text is localized" % [locale, text_key])
			_assert(button.text == "", "%s %s is not baked into Button.text" % [locale, text_key])
			_assert(not expected_text.contains("\n"), "%s %s is one line" % [locale, text_key])
			var font := label.get_theme_font("font")
			_assert(font is FontVariation, "%s %s uses deterministic FontVariation" % [locale, text_key])
			if font is FontVariation:
				var variation := font as FontVariation
				_assert(variation.base_font != null and variation.base_font.resource_path == KAISEI_FONT_PATH, "%s %s base font is adopted Kaisei Decol Bold" % [locale, text_key])
				_assert(variation.fallbacks.size() == 1, "%s %s has exactly one bundled locale fallback stack" % [locale, text_key])
			var font_size := label.get_theme_font_size("font_size")
			_assert(font_size <= 21 and font_size >= 12, "%s %s deterministic font size is within 12..21" % [locale, text_key])
			var composite_width := ceilf(font.get_string_size(expected_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x) + 3.0
			var composite_height := ceilf(font.get_height(font_size)) + 3.0
			_assert(composite_width <= 108.0, "%s %s composite width %.3f fits 108" % [locale, text_key, composite_width])
			_assert(composite_height <= 70.0, "%s %s composite height %.3f fits 70" % [locale, text_key, composite_height])
			for character: String in expected_text:
				if character != " ":
					_assert(font.has_char(character.unicode_at(0)), "%s %s has glyph U+%04X" % [locale, text_key, character.unicode_at(0)])
			if composite_width > _worst_width:
				_worst_width = composite_width
				_worst_case = "%s/%s/%s@%d" % [locale, text_key, expected_text, font_size]
			_text_case_count += 1
	_assert(_text_case_count == 30, "five locales by six states equals 30 measured text cases")


func _validate_state_visibility_and_callbacks() -> void:
	SaveData.language_code = "ja"
	await _prepare_result("stage1", false, false, "clear")
	_assert(str(_button("BtnRetry").get_meta("result_semantic_key")) == "result_next", "stage1 clear primary state is Next")
	_assert(str(_button("BtnHome").get_meta("result_semantic_key")) == "result_home", "stage1 clear secondary state is Home")
	await _prepare_result("stage4", false, false, "clear")
	_assert(_button("BtnRetry").visible and not _button("BtnRetry").disabled, "final clear keeps Next enabled")
	_assert(not _button("BtnHome").visible and _button("BtnHome").disabled, "final clear hides and disables Home")
	_assert(_button("BtnHome").focus_mode == Control.FOCUS_NONE, "hidden final Home is not focusable")
	await _prepare_result("custom", false, true, "wrong")
	_assert(str(_button("BtnRetry").get_meta("result_semantic_key")) == "result_retry", "instant wrong primary state is Retry")
	_assert(str(_button("BtnHome").get_meta("result_semantic_key")) == "result_title", "instant wrong secondary state is To Title")
	_assert((_button("BtnHome").get_node("ResultButtonText") as Label).text == "タイトルへ", "instant wrong visibly says To Title")
	_assert(not _button("BtnHome").has_meta("result_title_asset_blocked"), "runtime To Title has no missing-asset blocker")
	await _prepare_result("custom", true, false, "clear", true)
	_assert(str(_button("BtnRetry").get_meta("result_semantic_key")) == "result_retry", "normal gameover primary state is Retry")
	_assert(str(_button("BtnHome").get_meta("result_semantic_key")) == "result_home", "normal gameover secondary state is Home")
	_assert(_button("BtnRetry").pressed.is_connected(Callable(_game, "_on_btn_retry_pressed")), "Retry/Next callback is preserved")
	_assert(_button("BtnHome").pressed.is_connected(Callable(_game, "_on_popup_btn_home_pressed")), "Home/Title callback is preserved")
	_assert(_button("BtnSubmitRanking").pressed.is_connected(Callable(_game, "_on_btn_submit_ranking_pressed")), "Ranking callback is preserved")
	_assert(_button("BtnShowAnswer").pressed.is_connected(Callable(_game, "_on_btn_show_answer_pressed")), "Answer callback is preserved")
	_game.call("_configure_result_focus_navigation")
	for button_name in RUNTIME_BUTTON_NAMES:
		var button := _button(button_name)
		_assert(button.focus_mode == Control.FOCUS_ALL, "%s is focusable while visible and enabled" % button_name)
		for property in ["focus_neighbor_left", "focus_neighbor_right", "focus_neighbor_top", "focus_neighbor_bottom", "focus_next", "focus_previous"]:
			var target := get_node_or_null(str(button.get(property)))
			_assert(target is Button and str(target.name) in RUNTIME_BUTTON_NAMES, "%s %s stays inside exact4 visible buttons" % [button_name, property])


func _validate_feedback_and_disabled_state() -> void:
	var retry := _button("BtnRetry")
	retry.disabled = false
	retry.scale = Vector2.ONE
	retry.modulate = Color.WHITE
	retry.button_down.emit()
	await get_tree().create_timer(0.08).timeout
	_assert(retry.scale.x < 1.0 and retry.scale.y < 1.0, "enabled runtime button keeps held scale feedback")
	retry.button_up.emit()
	await get_tree().create_timer(0.14).timeout
	_assert(retry.scale.is_equal_approx(Vector2.ONE), "runtime button returns cleanly after release")
	var art := retry.get_node("ResultButtonArt") as TextureRect
	var label := retry.get_node("ResultButtonText") as Label
	var text_before_hover := label.text
	retry.mouse_entered.emit()
	await get_tree().process_frame
	_assert(art.texture.resource_path == BLANK_FRAME_PATH and label.text == text_before_hover, "hover preserves blank frame and runtime text")
	var ranking := _button("BtnSubmitRanking")
	ranking.visible = true
	_game.call("_set_result_ranking_button_disabled", true)
	await get_tree().process_frame
	_assert(ranking.disabled and ranking.focus_mode == Control.FOCUS_NONE, "ranking submission disabled state remains inert and unfocusable")
	ranking.scale = Vector2.ONE
	ranking.button_down.emit()
	await get_tree().create_timer(0.08).timeout
	_assert(ranking.scale.is_equal_approx(Vector2.ONE), "disabled Ranking does not react to held feedback")
	_assert((ranking.get_node("ResultButtonArt") as TextureRect).texture.resource_path == BLANK_FRAME_PATH, "disabled Ranking retains adopted blank frame")
	_game.call("_set_result_ranking_button_disabled", false)
	await get_tree().process_frame
	_assert(not ranking.disabled and ranking.focus_mode == Control.FOCUS_ALL, "Ranking focus is restored after submission completes")


func _capture_actual_result_nodes() -> void:
	var capture_absolute := ProjectSettings.globalize_path(CAPTURE_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(capture_absolute)
	_assert(mkdir_error == OK or mkdir_error == ERR_ALREADY_EXISTS, "capture directory is available")
	var scenarios := [
		{"locale": "ja", "stage": "custom", "gameover": true, "instant": false, "state": "clear", "name": "ja_retry_home"},
		{"locale": "en", "stage": "custom", "gameover": false, "instant": true, "state": "wrong", "name": "en_retry_to_title"},
		{"locale": "zh_CN", "stage": "stage1", "gameover": false, "instant": false, "state": "clear", "name": "zh_cn_next_home"},
		{"locale": "zh_TW", "stage": "custom", "gameover": true, "instant": true, "state": "clear", "name": "zh_tw_retry_to_title"},
		{"locale": "ko", "stage": "custom", "gameover": true, "instant": false, "state": "clear", "name": "ko_retry_home"},
	]
	for scenario: Dictionary in scenarios:
		SaveData.language_code = str(scenario["locale"])
		await _prepare_result(str(scenario["stage"]), bool(scenario["gameover"]), bool(scenario["instant"]), str(scenario["state"]), true)
		var popup := _game.get_node("PopupResult") as Control
		(popup.get_node("ResultMask") as Control).visible = true
		(popup.get_node("StageClearImage") as Control).visible = true
		(popup.get_node("ResultChara") as Control).visible = true
		(popup.get_node("ResultPanel") as Control).visible = true
		(popup.get_node("ResultButtons") as Control).visible = true
		_game.call("_refresh_localized_game_images")
		for button_name in RUNTIME_BUTTON_NAMES:
			var button := _button(button_name)
			button.visible = true
			button.disabled = false
		_game.call("_configure_result_focus_navigation")
		_button("BtnRetry").grab_focus()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		_assert(not image.is_empty(), "%s capture image is available" % scenario["name"])
		_assert(image.get_size() == Vector2i(480, 854), "%s capture is 480x854" % scenario["name"])
		var path := "%s/%s.png" % [capture_absolute, scenario["name"]]
		var save_error := image.save_png(path)
		_assert(save_error == OK, "%s capture saves as PNG" % scenario["name"])
		if save_error == OK:
			_capture_paths.append(path)
			print("CAPTURE result_r02_exact4 locale=%s state=%s path=%s" % [scenario["locale"], scenario["name"], path])
	_assert(_capture_paths.size() == 5, "five locale captures were saved")


func _button_for_text_key(text_key: String) -> Button:
	if text_key in ["result_retry", "result_next"]:
		return _button("BtnRetry")
	if text_key in ["result_home", "result_title"]:
		return _button("BtnHome")
	if text_key == "result_ranking":
		return _button("BtnSubmitRanking")
	return _button("BtnShowAnswer")


func _button(button_name: String) -> Button:
	return _game.call("_get_result_button", button_name) as Button


func _finish() -> void:
	SaveData.language_code = _original_language
	SaveData.custom_timer_enabled = _original_timer_enabled
	SaveData.custom_timer_seconds = _original_timer_seconds
	SaveData.custom_question_count = _original_question_count
	SaveData.custom_bgm_yume = _original_bgm_yume
	GameState.current_stage = _original_stage
	GameState.is_instant_mode = _original_instant
	if AudioManager != null:
		AudioManager.stop_bgm()
	if _game != null and is_instance_valid(_game):
		_game.queue_free()
		_game = null
		await get_tree().process_frame
		await get_tree().process_frame
	if _failed:
		get_tree().quit(1)
		return
	print("PASS result_button_runtime_text exact4=1 locales=5 states=6 cases=%d max_width=%.3f worst=%s grid=184x70 callbacks=4 focus=1 feedback=1 disabled=1 captures=%d" % [_text_case_count, _worst_width, _worst_case, _capture_paths.size()])
	get_tree().quit(0)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
