extends Control

const GAME_SCENE := preload("res://game.tscn")

const LOCALE_LABELS := {
	"ja": {
		"retry": "もう一度",
		"next": "次へ",
		"home": "ホーム",
		"title": "タイトルへ",
		"ranking": "ランキング",
		"answer": "答えを確認",
		"back": "戻る",
	},
	"en": {
		"retry": "Retry",
		"next": "Next",
		"home": "Home",
		"title": "To Title",
		"ranking": "Ranking",
		"answer": "Answer",
		"back": "Back",
	},
	"zh_CN": {
		"retry": "重试",
		"next": "下一关",
		"home": "主页",
		"title": "返回标题",
		"ranking": "排行榜",
		"answer": "答案",
		"back": "返回",
	},
	"zh_TW": {
		"retry": "重試",
		"next": "下一關",
		"home": "首頁",
		"title": "返回標題",
		"ranking": "排行榜",
		"answer": "答案",
		"back": "返回",
	},
	"ko": {
		"retry": "다시 하기",
		"next": "다음",
		"home": "홈",
		"title": "타이틀로",
		"ranking": "랭킹",
		"answer": "정답 보기",
		"back": "뒤로",
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
	await _validate_instant_title_semantics()
	await _validate_final_clear("stage4")
	await _validate_final_clear("ex_stage4")
	await _validate_normal_result_and_answer_focus()
	await _finish()


func _prepare_result(stage: String, is_gameover: bool, instant: bool, state := "clear") -> void:
	GameState.current_stage = stage
	GameState.is_instant_mode = instant
	_game.set("is_gameover_result", is_gameover)
	_game.set("is_result_answer_view", false)
	_game.set("popup_state", state)
	_game.call("_setup_popup_buttons", state)
	_game.call("_move_clear_buttons_to_result_layer")
	(_game.get_node("PopupResult") as Control).visible = true
	_game.call("_configure_result_focus_navigation")
	await get_tree().process_frame


func _validate_instant_title_semantics() -> void:
	for state in ["clear", "wrong"]:
		await _prepare_result("custom", state == "clear", true, state)
		for locale: String in LOCALE_LABELS:
			SaveData.language_code = locale
			if state == "clear" and locale == "en":
				_game.call("_refresh_localized_game_images")
			else:
				_game.call("_refresh_result_button_semantics")
			var labels: Dictionary = LOCALE_LABELS[locale]
			_assert(_button("BtnRetry").accessibility_name == str(labels["retry"]), "%s %s retry accessibility" % [locale, state])
			_assert(_button("BtnHome").accessibility_name == str(labels["title"]), "%s %s title accessibility" % [locale, state])
			_assert(_button("BtnSubmitRanking").accessibility_name == str(labels["ranking"]), "%s %s ranking accessibility" % [locale, state])
			_assert(_button("BtnShowAnswer").accessibility_name == str(labels["answer"]), "%s %s answer accessibility" % [locale, state])
			_assert(_button("BtnBackToResult").accessibility_name == str(labels["back"]), "%s %s back accessibility" % [locale, state])
		_assert(not _button("BtnHome").has_meta("result_title_asset_blocked"), "%s instant Title no longer has a baked-asset blocker" % state)
		SaveData.language_code = "ko"
		_game.call("_refresh_result_button_semantics")
		_assert((_button("BtnHome").get_node("ResultButtonText") as Label).text == str(LOCALE_LABELS["ko"]["title"]), "%s instant Title is rendered as runtime text" % state)
	SaveData.language_code = "ja"


func _validate_final_clear(stage: String) -> void:
	await _prepare_result(stage, false, false)
	var btn_next := _button("BtnRetry")
	var btn_home := _button("BtnHome")
	var btn_ranking := _button("BtnSubmitRanking")
	var btn_answer := _button("BtnShowAnswer")
	btn_ranking.disabled = false
	btn_ranking.visible = true
	_game.call("_configure_result_focus_navigation")
	await get_tree().process_frame
	_assert(btn_next.visible and not btn_next.disabled, "%s Next remains enabled" % stage)
	for locale: String in LOCALE_LABELS:
		SaveData.language_code = locale
		_game.call("_refresh_result_button_semantics")
		_assert(btn_next.accessibility_name == str(LOCALE_LABELS[locale]["next"]), "%s %s primary button semantics are Next" % [stage, locale])
	SaveData.language_code = "ja"
	_game.call("_refresh_result_button_semantics")
	_assert(not btn_home.visible and btn_home.disabled, "%s Home is hidden and inert" % stage)
	_assert(btn_home.focus_mode == Control.FOCUS_NONE, "%s hidden Home is not focusable" % stage)
	_assert(btn_next.custom_minimum_size == Vector2(184.0, 70.0), "%s Next target remains 184x70" % stage)
	_assert(btn_home.custom_minimum_size == Vector2(184.0, 70.0), "%s Home target definition remains 184x70" % stage)
	_assert(btn_answer.custom_minimum_size == Vector2(184.0, 70.0), "%s Answer target remains 184x70" % stage)
	_assert(btn_next.pressed.is_connected(Callable(_game, "_on_btn_retry_pressed")), "%s Next keeps the existing Retry callback" % stage)
	_assert_result_grid_geometry(stage, true)
	_assert_focus_graph_closed(stage)
	_game.call("_focus_initial_result_button")
	await get_tree().process_frame
	_assert(get_viewport().gui_get_focus_owner() == btn_next, "%s clear initial focus is Next" % stage)


func _validate_normal_result_and_answer_focus() -> void:
	await _prepare_result("custom", true, false)
	var btn_retry := _button("BtnRetry")
	var btn_home := _button("BtnHome")
	var btn_answer := _button("BtnShowAnswer")
	_assert(btn_retry.visible and not btn_retry.disabled, "normal gameover Retry remains enabled")
	_assert(btn_home.visible and not btn_home.disabled, "normal gameover Home remains enabled")
	for locale: String in LOCALE_LABELS:
		SaveData.language_code = locale
		_game.call("_refresh_result_button_semantics")
		_assert(btn_home.accessibility_name == str(LOCALE_LABELS[locale]["home"]), "%s normal Home accessibility" % locale)
	SaveData.language_code = "ja"
	_game.call("_refresh_result_button_semantics")
	_assert(btn_retry.accessibility_name == "もう一度", "normal gameover Retry semantics")
	_assert(btn_home.accessibility_name == "ホーム", "normal gameover Home semantics")
	_assert(not btn_home.has_meta("result_title_asset_blocked"), "normal Home has no Title asset blocker marker")
	var btn_ranking := _button("BtnSubmitRanking")
	btn_ranking.visible = true
	btn_ranking.disabled = true
	_game.call("_configure_result_focus_navigation")
	_assert(btn_ranking.focus_mode == Control.FOCUS_NONE, "disabled Ranking is not focusable")
	btn_ranking.disabled = false
	_game.call("_configure_result_focus_navigation")
	await get_tree().process_frame
	_assert(btn_retry.pressed.is_connected(Callable(_game, "_on_btn_retry_pressed")), "Retry callback is preserved")
	_assert(btn_home.pressed.is_connected(Callable(_game, "_on_popup_btn_home_pressed")), "Home callback is preserved")
	_assert(btn_ranking.pressed.is_connected(Callable(_game, "_on_btn_submit_ranking_pressed")), "Ranking callback is preserved")
	_assert(btn_answer.pressed.is_connected(Callable(_game, "_on_btn_show_answer_pressed")), "Answer callback is preserved")
	_assert_result_grid_geometry("normal", false)
	_assert_focus_graph_closed("normal")
	_game.call("_focus_initial_result_button")
	await get_tree().process_frame
	_assert(get_viewport().gui_get_focus_owner() == btn_retry, "gameover initial focus is Retry")
	_game.call("_show_answer_view_from_result")
	await get_tree().process_frame
	var btn_back := _button("BtnBackToResult")
	_assert(btn_back.visible and btn_back.focus_mode == Control.FOCUS_ALL, "Answer view Back is visible and focusable")
	_assert(btn_back.accessibility_name == "戻る", "Answer view Back accessibility")
	_assert(btn_back.pressed.is_connected(Callable(_game, "_on_btn_back_to_result_pressed")), "Back callback is preserved")
	_assert(get_viewport().gui_get_focus_owner() == btn_back, "Answer view initial focus is Back")
	_assert_focus_graph_closed("answer")
	_game.call("_handle_system_back")
	await get_tree().process_frame
	_assert(not bool(_game.get("is_result_answer_view")), "system Back returns from Answer view")
	_assert(not btn_back.visible and btn_back.focus_mode == Control.FOCUS_NONE, "hidden Back is not focusable")
	_assert(get_viewport().gui_get_focus_owner() == btn_answer, "returning to result restores Answer focus")
	_assert_focus_graph_closed("result restored")
	(_game.get_node("PopupResult") as Control).visible = false
	await get_tree().process_frame
	for name in ["BtnRetry", "BtnHome", "BtnSubmitRanking", "BtnShowAnswer", "BtnBackToResult"]:
		_assert(_button(name).focus_mode == Control.FOCUS_NONE, "hidden result %s is not focusable" % name)


func _assert_result_grid_geometry(context: String, final_layout: bool) -> void:
	var grid := _game.get_node("PopupResult/ResultButtons") as GridContainer
	var home_spacer := grid.get_node("FinalHomeSpacer") as Control
	_assert(grid.position == Vector2(50.0, 700.0), "%s result grid position preserved" % context)
	_assert(grid.size == Vector2(380.0, 144.0), "%s result grid size preserved" % context)
	for name in ["BtnRetry", "BtnHome", "BtnSubmitRanking", "BtnShowAnswer"]:
		var button := _button(name)
		_assert(button.custom_minimum_size == Vector2(184.0, 70.0), "%s %s target remains 184x70" % [context, name])
		if button.visible:
			_assert(button.size == Vector2(184.0, 70.0), "%s %s effective target is 184x70" % [context, name])
	_assert(home_spacer.visible == final_layout, "%s layout spacer visibility matches final state" % context)
	_assert(home_spacer.custom_minimum_size == Vector2(184.0, 70.0), "%s layout spacer preserves the Home slot" % context)
	_assert(home_spacer.mouse_filter == Control.MOUSE_FILTER_IGNORE and home_spacer.focus_mode == Control.FOCUS_NONE, "%s layout spacer is inert" % context)
	_assert(_button("BtnRetry").position == Vector2(0.0, 0.0), "%s Retry/Next slot is preserved" % context)
	var second_slot: Control = home_spacer if final_layout else _button("BtnHome")
	_assert(second_slot.position == Vector2(196.0, 0.0), "%s second route slot is preserved" % context)
	_assert(_button("BtnSubmitRanking").position == Vector2(0.0, 74.0), "%s Ranking slot is preserved" % context)
	_assert(_button("BtnShowAnswer").position == Vector2(196.0, 74.0), "%s Answer slot is preserved" % context)


func _assert_focus_graph_closed(context: String) -> void:
	var active: Array[Button] = _game.call("_visible_enabled_result_buttons")
	_assert(not active.is_empty(), "%s has an active result focus set" % context)
	var allowed := {}
	for button in active:
		allowed[str(button.get_path())] = true
		_assert(button.focus_mode == Control.FOCUS_ALL, "%s %s is focusable" % [context, button.name])
		var focus_style := button.get_theme_stylebox("focus")
		_assert(focus_style is StyleBoxFlat, "%s %s has visible focus style" % [context, button.name])
		if focus_style is StyleBoxFlat:
			_assert((focus_style as StyleBoxFlat).border_width_left >= 3, "%s %s focus border is visible" % [context, button.name])
		_assert(button.has_meta("button_feedback_installed"), "%s %s keeps ButtonFeedback" % [context, button.name])
	for button in active:
		for property in ["focus_neighbor_left", "focus_neighbor_right", "focus_neighbor_top", "focus_neighbor_bottom", "focus_next", "focus_previous"]:
			var target_path := str(button.get(property))
			_assert(target_path != "" and allowed.has(target_path), "%s %s %s stays inside visible buttons" % [context, button.name, property])
	for name in ["BtnRetry", "BtnHome", "BtnSubmitRanking", "BtnShowAnswer", "BtnBackToResult"]:
		var button := _button(name)
		if button not in active:
			_assert(button.focus_mode == Control.FOCUS_NONE, "%s inactive %s is not focusable" % [context, name])


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
	print("PASS result_ui_improvements final_home_hidden=2 locales=5 title_semantics=1 focus_closed=1 answer_restore=1 target_184x70=1 runtime_title_text=1")
	get_tree().quit(0)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
