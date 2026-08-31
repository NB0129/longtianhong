extends Control

const GAME_SCENE := preload("res://game.tscn")
const TITLE_SCENE := preload("res://title.tscn")
const VIEWPORT_SIZE := Vector2i(480, 854)
const OUTPUT_DIR := "res://artifacts/ui_audit_capture_r05_answer_nav_visual_restore_20260831"
const RESULT_BACK_FRAME := "res://assets/ui/button_families_r02/result_back_compact_r02_170x62.png"
const MODAL_CONFIRM_FRAME := "res://assets/ui/button_families_r02/confirm_compact_r02_112x48.png"
const MODAL_CLOSE_FRAME := "res://assets/ui/button_families_r02/close_compact_r02_130x54.png"

var _failed := false
var _captures: Array[Dictionary] = []
var _game: Control = null
var _title: Control = null
var _original_state := {}
var _answer_top_bar_prestate := {}


func _enter_tree() -> void:
	get_window().size = VIEWPORT_SIZE
	get_window().content_scale_size = VIEWPORT_SIZE


func _ready() -> void:
	_snapshot_state()
	SaveData.language_code = "ja"
	LocaleFonts.call("_apply_locale", "ja")
	GameState.current_stage = "custom"
	GameState.is_instant_mode = false
	SaveData.custom_timer_enabled = false
	SaveData.custom_timer_seconds = 9
	SaveData.custom_question_count = 10
	SaveData.custom_bgm_yume = true

	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(output_absolute)
	_assert(mkdir_error == OK or mkdir_error == ERR_ALREADY_EXISTS, "capture output directory is available")

	print("RENDER display=%s method=%s driver=%s adapter=%s" % [
		DisplayServer.get_name(),
		_rendering_server_value("get_current_rendering_method"),
		_rendering_server_value("get_current_rendering_driver_name"),
		_rendering_server_value("get_video_adapter_name"),
	])

	await _prepare_game()
	if _game != null:
		await _capture_result_back()
		await _capture_home_confirm()
		await _capture_game_settings()
	await _remove_scene(_game)
	_game = null
	await _prepare_title()
	if _title != null:
		await _capture_title_credits()
	await _remove_scene(_title)
	_title = null
	await _finish()


func _snapshot_state() -> void:
	_original_state = {
		"language": SaveData.language_code,
		"stage": GameState.current_stage,
		"instant": GameState.is_instant_mode,
		"timer_enabled": SaveData.custom_timer_enabled,
		"timer_seconds": SaveData.custom_timer_seconds,
		"question_count": SaveData.custom_question_count,
		"bgm_yume": SaveData.custom_bgm_yume,
	}


func _prepare_game() -> void:
	_game = GAME_SCENE.instantiate() as Control
	_assert(_game != null, "actual game scene instantiates")
	if _game == null:
		return
	add_child(_game)
	await _settle(3)
	var intro := _game.get_node_or_null("StageIntro/IntroPanel") as Control
	if intro != null:
		intro.visible = false
	_game.set("is_animating", false)
	_game.set("timer_running", false)
	_game.set("timer_enabled", false)
	_game.set("is_game_over", false)
	await _settle(2)


func _capture_result_back() -> void:
	_game.set("popup_state", "clear")
	_game.set("is_gameover_result", true)
	_game.set("is_result_answer_view", false)
	_game.call("_setup_popup_buttons", "clear")
	_game.call("_move_clear_buttons_to_result_layer")
	(_game.get_node("PopupResult") as Control).visible = true
	var top_home := _game.get_node("TopBar/BtnHome") as Button
	var top_settings := _game.get_node("TopBar/BtnSettings") as Button
	_answer_top_bar_prestate = {
		"BtnHome": _button_visual_state(top_home),
		"BtnSettings": _button_visual_state(top_settings),
	}
	_game.call("_show_answer_view_from_result")
	await _settle(3)

	var button := _game.get_node_or_null("PopupResult/BtnBackToResult") as Button
	_assert_button_family(
		button,
		Vector2(255.0, 93.0),
		Rect2(0.0, 0.0, 255.0, 93.0),
		"戻る",
		RESULT_BACK_FRAME,
		"result_back"
	)
	if button != null:
		_assert(button.position == Vector2(112.5, 751.0), "Result Back keeps its centered position (112.5,751)")
		_assert(Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE)).encloses(button.get_global_rect()), "Result Back stays fully inside the 480x854 viewport")
		var label := button.get_node("ButtonFamilyText") as Label
		_assert(label.get_meta("button_family_ink_scale", Vector2.ZERO) == Vector2(1.5, 1.5), "Result Back runtime text scales with its frame by 1.5")
		for nav_button in [top_home, top_settings]:
			_assert(not nav_button.is_visible_in_tree(), "Answer view does not draw %s" % nav_button.name)
			_assert(nav_button.disabled, "Answer view blocks pointer activation for %s" % nav_button.name)
			_assert(nav_button.focus_mode == Control.FOCUS_NONE, "Answer view removes %s from focus" % nav_button.name)
			_assert(not (nav_button.is_visible_in_tree() and button.get_global_rect().intersects(nav_button.get_global_rect())), "Result Back has no visible overlap with %s" % nav_button.name)
		button.grab_focus()
	await _save_capture("01_result_answer_back_ja_480x854.png", "result_back")


func _capture_home_confirm() -> void:
	if bool(_game.get("is_result_answer_view")):
		_game.call("_show_result_view_from_answer")
	await get_tree().create_timer(0.13).timeout
	var top_home := _game.get_node("TopBar/BtnHome") as Button
	var top_settings := _game.get_node("TopBar/BtnSettings") as Button
	_assert_restored_top_bar_button(top_home, _answer_top_bar_prestate["BtnHome"] as Dictionary)
	_assert_restored_top_bar_button(top_settings, _answer_top_bar_prestate["BtnSettings"] as Dictionary)
	_assert(not bool(_game.get("is_result_answer_view")), "Answer return clears the answer-view flag")
	_assert((_game.get("_answer_view_top_bar_states") as Dictionary).is_empty(), "Answer return clears saved TopBar state")
	(_game.get_node("PopupResult") as Control).visible = false
	var result_back := _game.get_node_or_null("PopupResult/BtnBackToResult") as Button
	if result_back != null:
		result_back.visible = false
	_game.set("is_game_over", false)
	_game.call("_on_btn_home_pressed")
	await _settle(3)

	var backdrop := _game.get_node("HomeConfirmBackdrop") as Control
	var popup := _game.get_node("HomeConfirmPopup") as Panel
	var yes := popup.get_node("BtnConfirmYes") as Button
	var no := popup.get_node("BtnConfirmNo") as Button
	_assert(backdrop.visible and popup.visible, "production Home action opens backdrop and confirmation popup")
	_assert(backdrop.mouse_filter == Control.MOUSE_FILTER_STOP, "Home backdrop blocks background input")
	_assert_button_family(yes, Vector2(112.0, 48.0), Rect2(0.0, 0.0, 112.0, 48.0), "はい", MODAL_CONFIRM_FRAME, "confirm_yes")
	_assert_button_family(no, Vector2(112.0, 48.0), Rect2(0.0, 0.0, 112.0, 48.0), "いいえ", MODAL_CONFIRM_FRAME, "confirm_no")
	no.grab_focus()
	await _save_capture("02_game_home_confirm_ja_480x854.png", "home_confirm")


func _capture_game_settings() -> void:
	_game.call("_close_home_confirm_modal", false)
	_game.set("timer_enabled", false)
	_game.call("_on_btn_settings_pressed")
	await _settle(3)

	var backdrop := _game.get_node("SettingsBackdrop") as Control
	var popup := _game.get_node("SettingsPopup") as Panel
	var vbox := popup.get_node("VBox") as VBoxContainer
	var bgm_label := vbox.get_node("LabelBgm") as Label
	var close_button := popup.get_node("VBox/BtnSettingsClose") as Button
	_assert(backdrop.visible and popup.visible, "production game Settings action opens backdrop and popup")
	_assert(backdrop.mouse_filter == Control.MOUSE_FILTER_STOP, "Settings backdrop blocks background input")
	_assert(Rect2(popup.position, popup.size) == Rect2(20.0, 17.0, 440.0, 820.0), "Settings popup uses the owner-adopted 440x820 geometry")
	_assert(Rect2(vbox.position, vbox.size) == Rect2(58.0, 160.0, 332.0, 590.0), "Settings VBox uses the corrected 58/160/-50/-70 offsets")
	_assert(popup.get_global_rect().encloses(bgm_label.get_global_rect()), "Settings BGM label control is contained by the popup")
	_assert(bgm_label.get_global_rect().position.y >= popup.get_global_rect().position.y + 160.0, "Settings BGM label keeps 8px beyond the inner cream top")
	_assert_button_family(
		close_button,
		Vector2(130.0, 70.0),
		Rect2(0.0, 8.0, 130.0, 54.0),
		"閉じる",
		MODAL_CLOSE_FRAME,
		"settings_close"
	)
	var close_art := close_button.get_node("ButtonFamilyArt") as TextureRect
	var art_bottom := close_button.get_global_rect().position.y + close_art.position.y + close_art.size.y
	_assert(is_equal_approx(popup.get_global_rect().end.y - art_bottom, 78.0), "Settings Close art keeps 78px of lower popup space")
	close_button.grab_focus()
	await _save_capture("03_game_settings_close_ja_480x854.png", "game_settings_close")


func _prepare_title() -> void:
	_title = TITLE_SCENE.instantiate() as Control
	_assert(_title != null, "actual title scene instantiates")
	if _title == null:
		return
	add_child(_title)
	await _settle(4)


func _capture_title_credits() -> void:
	_title.call("_on_btn_credit_pressed")
	await _settle(3)

	var backdrop := _title.get_node("CreditOverlay") as Control
	var popup := _title.get_node("CreditPopup") as Panel
	var close_button := popup.get_node("VBox/BtnCreditClose") as Button
	_assert(backdrop.visible and popup.visible, "production Credits action opens backdrop and popup")
	_assert(backdrop.mouse_filter == Control.MOUSE_FILTER_STOP, "Credits backdrop blocks background input")
	_assert_button_family(
		close_button,
		Vector2(130.0, 70.0),
		Rect2(0.0, 8.0, 130.0, 54.0),
		"閉じる",
		MODAL_CLOSE_FRAME,
		"credit_close"
	)
	close_button.grab_focus()
	await _save_capture("04_title_credits_close_ja_480x854.png", "title_credits_close")


func _button_visual_state(button: Button) -> Dictionary:
	return {
		"visible": button.visible,
		"disabled": button.disabled,
		"focus_mode": button.focus_mode,
		"modulate": button.modulate,
	}


func _assert_restored_top_bar_button(button: Button, expected: Dictionary) -> void:
	_assert(button.visible == bool(expected["visible"]), "%s restores visible state" % button.name)
	_assert(button.disabled == bool(expected["disabled"]), "%s restores disabled state" % button.name)
	_assert(button.focus_mode == int(expected["focus_mode"]), "%s restores focus mode" % button.name)
	if button.visible:
		_assert(button.scale == Vector2.ONE, "%s feedback scale returns to one" % button.name)
		_assert(button.modulate.is_equal_approx(expected["modulate"] as Color), "%s feedback modulate returns to its pre-Answer rest state" % button.name)


func _assert_button_family(
	button: Button,
	expected_hitbox: Vector2,
	expected_art_rect: Rect2,
	expected_text: String,
	expected_texture_path: String,
	expected_role: String
) -> void:
	_assert(button != null, "%s button exists" % expected_role)
	if button == null:
		return
	_assert(button.is_visible_in_tree(), "%s button is visibly rendered" % expected_role)
	_assert(button.custom_minimum_size == expected_hitbox, "%s minimum hitbox is %s" % [expected_role, expected_hitbox])
	_assert(button.size == expected_hitbox, "%s effective hitbox is %s" % [expected_role, expected_hitbox])
	_assert(bool(button.get_meta("button_family_runtime_text", false)), "%s uses ButtonFamilyRuntime" % expected_role)
	_assert(str(button.get_meta("button_family_variant", "")) == expected_role, "%s retains its runtime role" % expected_role)
	var art := button.get_node_or_null("ButtonFamilyArt") as TextureRect
	var label := button.get_node_or_null("ButtonFamilyText") as Label
	_assert(art != null and art.texture != null, "%s has adopted frame art" % expected_role)
	if art != null and art.texture != null:
		_assert(art.texture.resource_path == expected_texture_path, "%s renders the adopted R02 frame" % expected_role)
		_assert(Rect2(art.position, art.size) == expected_art_rect, "%s art rectangle is %s" % [expected_role, expected_art_rect])
	_assert(label != null and label.text == expected_text, "%s renders Japanese text %s" % [expected_role, expected_text])


func _save_capture(file_name: String, state_name: String) -> void:
	await _settle(2)
	var image := get_viewport().get_texture().get_image()
	_assert(image != null and not image.is_empty(), "%s viewport returns rendered pixels" % state_name)
	if image == null or image.is_empty():
		return
	_assert(image.get_size() == VIEWPORT_SIZE, "%s viewport is exactly 480x854" % state_name)
	if image.get_size() != VIEWPORT_SIZE:
		return
	var absolute_path := ProjectSettings.globalize_path(OUTPUT_DIR + "/" + file_name)
	_assert(not FileAccess.file_exists(absolute_path), "%s does not overwrite prior evidence" % file_name)
	if FileAccess.file_exists(absolute_path):
		return
	var save_error := image.save_png(absolute_path)
	_assert(save_error == OK, "%s saves as PNG" % state_name)
	if save_error != OK:
		return
	var record := {
		"state": state_name,
		"locale": "ja",
		"path": absolute_path,
		"width": image.get_width(),
		"height": image.get_height(),
		"bytes": FileAccess.get_file_as_bytes(absolute_path).size(),
		"sha256": FileAccess.get_sha256(absolute_path).to_upper(),
	}
	_captures.append(record)
	print("CAPTURE " + JSON.stringify(record))


func _settle(frame_count: int = 3) -> void:
	for _index in range(frame_count):
		await get_tree().process_frame
	RenderingServer.force_draw(false)
	await get_tree().process_frame


func _rendering_server_value(method_name: StringName) -> String:
	if not RenderingServer.has_method(method_name):
		return "unavailable"
	return str(RenderingServer.call(method_name))


func _remove_scene(scene: Node) -> void:
	if scene != null and is_instance_valid(scene):
		scene.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame


func _finish() -> void:
	SaveData.language_code = str(_original_state["language"])
	LocaleFonts.call("_apply_locale", SaveData.language_code)
	GameState.current_stage = str(_original_state["stage"])
	GameState.is_instant_mode = bool(_original_state["instant"])
	SaveData.custom_timer_enabled = bool(_original_state["timer_enabled"])
	SaveData.custom_timer_seconds = int(_original_state["timer_seconds"])
	SaveData.custom_question_count = int(_original_state["question_count"])
	SaveData.custom_bgm_yume = bool(_original_state["bgm_yume"])
	if AudioManager != null:
		AudioManager.stop_bgm()
	_assert(_captures.size() == 4, "all four requested runtime states were captured")
	if _failed:
		print("FAIL r02_runtime_visual_capture captures=%d" % _captures.size())
		get_tree().quit(1)
		return
	print("PASS r02_runtime_visual_capture captures=4 locale=ja viewport=480x854 product_change=0 fallback=0")
	get_tree().quit(0)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
