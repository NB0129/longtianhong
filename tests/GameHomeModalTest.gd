extends Control

const GAME_SCENE := preload("res://game.tscn")

const NOTICE_TEXT := {
	"ja": "※確認中も制限時間は進みます",
	"en": "* The timer continues while this confirmation is open.",
	"zh_CN": "※确认期间计时仍会继续。",
	"zh_TW": "※確認期間計時仍會繼續。",
	"ko": "※확인 중에도 제한 시간은 계속 흐릅니다.",
}

var _failed := false
var _game: Control = null
var _original_stage := ""
var _original_language := "ja"
var _original_timer_enabled := false
var _original_timer_seconds := 0
var _original_question_count := 0
var _original_bgm_yume := false


func _ready() -> void:
	_original_stage = GameState.current_stage
	_original_language = SaveData.language_code
	_original_timer_enabled = SaveData.custom_timer_enabled
	_original_timer_seconds = SaveData.custom_timer_seconds
	_original_question_count = SaveData.custom_question_count
	_original_bgm_yume = SaveData.custom_bgm_yume
	GameState.current_stage = "custom"
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
	_validate_localized_notice()
	await _validate_fixed_layout_and_pointer_reach()
	await _validate_non_pausing_modal()
	await _validate_single_normal_timeout()
	await _finish()


func _validate_localized_notice() -> void:
	var label := _game.get_node("HomeConfirmPopup/TimerNoticeLabel") as Label
	for locale: String in NOTICE_TEXT:
		SaveData.language_code = locale
		_game.call("_refresh_home_confirm_notice")
		_assert(label.text == str(NOTICE_TEXT[locale]), "%s timer notice matches" % locale)
	SaveData.language_code = "ja"
	_game.call("_refresh_home_confirm_notice")


func _validate_fixed_layout_and_pointer_reach() -> void:
	var intro_panel := _game.get_node("StageIntro/IntroPanel") as Control
	intro_panel.visible = false
	_game.set("is_animating", false)
	_game.set("is_game_over", false)
	var top_bar := _game.get_node("TopBar") as Control
	var keypad := _game.get_node("Keypad") as Control
	_assert(is_equal_approx(top_bar.position.y, 780.0), "game TopBar returns to Y=780")
	_assert(keypad.position == Vector2(51.0, 470.0), "game Keypad returns to (51,470)")
	_assert_top_bar_pointer_centers_clear(keypad)

	var home_button := _game.get_node("TopBar/BtnHome") as Button
	await _click_control(home_button)
	_assert(bool(_game.get("_home_confirm_modal_active")), "viewport pointer input reaches game Home")
	if bool(_game.get("_home_confirm_modal_active")):
		await _click_control(_game.get_node("HomeConfirmPopup/BtnConfirmNo") as Button)
	_assert(not bool(_game.get("_home_confirm_modal_active")), "pointer No closes the Home confirmation")

	_assert(is_equal_approx(top_bar.position.y, 780.0), "game non-timer TopBar remains at Y=780")
	_assert_top_bar_pointer_centers_clear(keypad)
	var settings_button := _game.get_node("TopBar/BtnSettings") as Button
	_assert(settings_button.visible, "game Settings is visible in a non-timer stage layout")
	await _click_control(settings_button)
	_assert((_game.get_node("SettingsPopup") as Control).visible, "viewport pointer input reaches game Settings")
	if (_game.get_node("SettingsPopup") as Control).visible:
		await _click_control(_game.get_node("SettingsPopup/VBox/BtnSettingsClose") as Button)
	_assert(not (_game.get_node("SettingsPopup") as Control).visible, "pointer Close dismisses game Settings")
	_game.set("timer_enabled", true)


func _assert_top_bar_pointer_centers_clear(keypad: Control) -> void:
	for top_path in ["TopBar/BtnHome", "TopBar/BtnSettings"]:
		var top_button := _game.get_node(top_path) as Button
		if not top_button.visible:
			continue
		var pointer_center := top_button.get_global_rect().get_center()
		for child in keypad.get_children():
			var keypad_control := child as Control
			if keypad_control == null or not keypad_control.visible:
				continue
			_assert(not keypad_control.get_global_rect().has_point(pointer_center), "%s pointer center is clear of %s" % [top_button.name, keypad_control.name])


func _click_control(control: Control) -> void:
	_assert(control != null and control.is_visible_in_tree(), "pointer target is a visible scene control")
	if control == null:
		return
	var point := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	get_viewport().push_input(motion, true)
	await get_tree().process_frame
	for is_pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if is_pressed else 0
		event.pressed = is_pressed
		event.position = point
		event.global_position = point
		get_viewport().push_input(event, true)
		await get_tree().process_frame


func _validate_non_pausing_modal() -> void:
	_game.set("timer_enabled", true)
	_game.set("time_limit", 9.0)
	_game.set("time_left", 4.0)
	_game.set("timer_running", true)
	_game.set("is_animating", false)
	_game.set("is_game_over", false)
	_game.set("current_question", 2)
	_game.set("selected_tiles", [1])
	var question_start := Time.get_ticks_msec() - 900
	_game.set("question_started_msec", question_start)
	_game.call("_on_btn_home_pressed")
	var time_when_opened := float(_game.get("time_left"))
	var elapsed_when_opened := Time.get_ticks_msec() - question_start
	_assert(bool(_game.get("_home_confirm_modal_active")), "home modal guard is active")
	_assert((_game.get_node("HomeConfirmBackdrop") as Control).visible, "full-screen backdrop is visible")
	_assert((_game.get_node("HomeConfirmBackdrop") as Control).mouse_filter == Control.MOUSE_FILTER_STOP, "backdrop intercepts pointer input")
	_assert(bool(_game.get("timer_running")), "timer remains running while modal is open")
	_assert(int(_game.get("question_started_msec")) == question_start, "score clock origin is unchanged on open")
	_game.call("_on_number_pressed", 2)
	_game.call("_on_none_pressed")
	_game.call("_on_clear_pressed")
	_game.call("_on_submit_pressed")
	_game.call("_on_btn_settings_pressed")
	_game.call("_on_btn_home_pressed")
	_assert((_game.get("selected_tiles") as Array) == [1], "background answer and clear do not mutate selection")
	_assert(int(_game.get("current_question")) == 2, "background submit does not advance the question")
	_assert(not (_game.get_node("SettingsPopup") as Control).visible, "background settings action is blocked")
	await get_tree().create_timer(0.12).timeout
	_assert(float(_game.get("time_left")) < time_when_opened, "visible timer continues while confirmation is open")
	OS.delay_msec(20)
	_assert(Time.get_ticks_msec() - int(_game.get("question_started_msec")) >= elapsed_when_opened + 15, "elapsed score clock continues while confirmation is open")
	_game.call("_on_btn_confirm_no_pressed")
	_assert(not bool(_game.get("_home_confirm_modal_active")), "No closes the modal guard")
	_assert(not (_game.get_node("HomeConfirmBackdrop") as Control).visible, "No hides the backdrop")
	_assert(int(_game.get("current_question")) == 2, "No returns to the same question")
	_assert((_game.get("selected_tiles") as Array) == [1], "No preserves the current selection")
	_assert(float(_game.get("time_left")) < time_when_opened, "No does not reset elapsed timer time")
	_assert(int(_game.get("question_started_msec")) == question_start, "No does not reset the score clock")


func _validate_single_normal_timeout() -> void:
	_game.set("is_game_over", false)
	_game.set("is_animating", false)
	_game.set("_time_up_resolution_count", 0)
	_game.set("time_left", 0.02)
	_game.set("timer_running", true)
	_game.call("_on_btn_home_pressed")
	await get_tree().create_timer(0.08).timeout
	_assert(bool(_game.get("is_game_over")), "timeout follows the normal game-over path")
	_assert(bool(_game.get("is_gameover_result")), "timeout shows the normal game-over result")
	_assert(int(_game.get("_time_up_resolution_count")) == 1, "timeout resolves exactly once")
	_assert(not bool(_game.get("_home_confirm_modal_active")), "timeout clears modal state")
	_assert(not (_game.get_node("HomeConfirmBackdrop") as Control).visible, "timeout hides the backdrop")
	_game.call("on_time_up")
	_assert(int(_game.get("_time_up_resolution_count")) == 1, "duplicate timeout call is ignored")


func _finish() -> void:
	SaveData.language_code = _original_language
	SaveData.custom_timer_enabled = _original_timer_enabled
	SaveData.custom_timer_seconds = _original_timer_seconds
	SaveData.custom_question_count = _original_question_count
	SaveData.custom_bgm_yume = _original_bgm_yume
	GameState.current_stage = _original_stage
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
	print("PASS game_home_modal timer_continues=1 input_blocked=1 timeout_single=1 locales=5 fixed_layout=1 pointer_reach=1")
	get_tree().quit(0)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
