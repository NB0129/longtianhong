extends Node

const ModalFoundation := preload("res://ModalFoundation.gd")
const ButtonFeedback := preload("res://ButtonFeedback.gd")
const PopupSkin := preload("res://PopupSkin.gd")
const STAGE_SELECT_SCENE := preload("res://StageSelect.tscn")
const GAME_SCENE := preload("res://game.tscn")
const MUSIC_ROOM_SCENE := preload("res://MusicRoom.tscn")
const CUSTOM_SCENE := preload("res://custom.tscn")

var _failures := 0


func _ready() -> void:
	await _validate_modal_blocking_focus_and_restore()
	await _validate_settings_touch_targets()
	_validate_scene_backdrops()
	_validate_music_transport_targets()
	await _validate_custom_targets()
	await _validate_fixed_baseline_positions()
	_validate_button_feedback_focus_policy()
	if _failures == 0:
		print("PASS ui_foundation backdrop=1 focus_confined=1 focus_restored=1 touch_48=1 overlap=0 fixed_positions=1")
	get_tree().quit(0 if _failures == 0 else 1)


func _validate_modal_blocking_focus_and_restore() -> void:
	var host := Control.new()
	host.name = "ModalHost"
	host.size = Vector2(480.0, 854.0)
	add_child(host)
	var invoker := Button.new()
	invoker.name = "Invoker"
	invoker.focus_mode = Control.FOCUS_ALL
	invoker.position = Vector2(20.0, 760.0)
	invoker.size = Vector2(100.0, 60.0)
	host.add_child(invoker)
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.visible = false
	host.add_child(backdrop)
	var panel := Panel.new()
	panel.name = "Panel"
	panel.visible = false
	panel.position = Vector2(60.0, 180.0)
	panel.size = Vector2(360.0, 420.0)
	host.add_child(panel)
	var first := Button.new()
	first.name = "First"
	first.focus_mode = Control.FOCUS_ALL
	first.position = Vector2(40.0, 80.0)
	first.size = Vector2(280.0, 60.0)
	panel.add_child(first)
	var second := Button.new()
	second.name = "Second"
	second.focus_mode = Control.FOCUS_ALL
	second.position = Vector2(40.0, 180.0)
	second.size = Vector2(280.0, 60.0)
	panel.add_child(second)
	await get_tree().process_frame
	invoker.grab_focus()
	ModalFoundation.open_modal(backdrop, panel, invoker, second, 20)
	await get_tree().process_frame
	_assert(backdrop.visible and panel.visible, "opening a modal reveals backdrop and panel")
	_assert(backdrop.mouse_filter == Control.MOUSE_FILTER_STOP, "modal backdrop intercepts pointer input")
	_assert(backdrop.get_global_rect().size == host.size, "modal backdrop covers the full 480x854 host")
	_assert(get_viewport().gui_get_focus_owner() == second, "opening a modal moves focus to its preferred control")
	_assert_focus_paths_stay_inside(panel, [first, second])
	ModalFoundation.close_modal(backdrop, panel, true)
	await get_tree().process_frame
	_assert(not backdrop.visible and not panel.visible, "closing a modal hides backdrop and panel")
	_assert(get_viewport().gui_get_focus_owner() == invoker, "closing a modal restores focus to its invoker")
	host.queue_free()
	await get_tree().process_frame


func _validate_settings_touch_targets() -> void:
	var stage := STAGE_SELECT_SCENE.instantiate() as Control
	stage.set_script(null)
	(stage.get_node("SettingsPopup/VBox/TileSuitGrid") as Node).set_script(null)
	stage.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stage.size = Vector2(480.0, 854.0)
	add_child(stage)
	var panel := stage.get_node("SettingsPopup") as Panel
	var backdrop := stage.get_node("SettingsBackdrop") as ColorRect
	PopupSkin.ensure_settings_language_controls(panel, Callable())
	PopupSkin.apply_settings_popup(panel)
	PopupSkin.refresh_settings_language(panel)
	ModalFoundation.open_modal(backdrop, panel, stage.get_node("BtnSettings") as Control, panel.get_node("VBox/BgmSlider") as Control, 40)
	await get_tree().process_frame
	await get_tree().process_frame
	var controls: Array[Control] = [
		panel.get_node("VBox/BgmSlider") as Control,
		panel.get_node("VBox/SeSlider") as Control,
		panel.get_node("VBox/TileSuitGrid/BtnPinzu") as Control,
		panel.get_node("VBox/TileSuitGrid/BtnSouzu") as Control,
		panel.get_node("VBox/TileSuitGrid/BtnManzu") as Control,
		panel.get_node("VBox/TileSuitGrid/BtnManzu2") as Control,
		panel.get_node("VBox/LanguageGrid/BtnLanguageja") as Control,
		panel.get_node("VBox/LanguageGrid/BtnLanguageen") as Control,
		panel.get_node("VBox/LanguageGrid/BtnLanguagezhCN") as Control,
		panel.get_node("VBox/LanguageGrid/BtnLanguagezhTW") as Control,
		panel.get_node("VBox/LanguageGrid/BtnLanguageko") as Control,
	]
	for control in controls:
		_assert(control.size.y >= ModalFoundation.MINIMUM_TOUCH_TARGET, "%s effective target is never below 44px" % control.name)
		_assert(control.custom_minimum_size.y >= ModalFoundation.PREFERRED_TOUCH_TARGET, "%s requests the preferred 48px target" % control.name)
	_assert_non_overlapping(controls, "settings controls")
	_assert_controls_inside(panel, controls, "settings controls stay inside the panel")
	_assert_focus_paths_stay_inside(panel, ModalFoundation.collect_focusable_controls(panel))
	ModalFoundation.close_modal(backdrop, panel, true)
	stage.queue_free()
	await get_tree().process_frame


func _validate_scene_backdrops() -> void:
	for packed_scene in [GAME_SCENE, MUSIC_ROOM_SCENE]:
		var root := (packed_scene as PackedScene).instantiate()
		var backdrop := root.get_node_or_null("SettingsBackdrop") as Control
		var panel := root.get_node_or_null("SettingsPopup") as Control
		_assert(backdrop != null and panel != null, "%s has a settings backdrop and panel" % root.name)
		if backdrop != null and panel != null:
			_assert(backdrop.mouse_filter == Control.MOUSE_FILTER_STOP, "%s settings backdrop intercepts pointer input" % root.name)
			_assert(backdrop.z_index < panel.z_index, "%s settings panel is above its backdrop" % root.name)
		root.free()


func _validate_music_transport_targets() -> void:
	var music := MUSIC_ROOM_SCENE.instantiate() as Control
	var buttons: Array[Button] = [
		music.get_node("PlayerPanel/BtnPlay") as Button,
		music.get_node("PlayerPanel/BtnPause") as Button,
		music.get_node("PlayerPanel/BtnStop") as Button,
	]
	var positions := [Vector2(26.0, 19.0), Vector2(166.0, 19.0), Vector2(306.0, 19.0)]
	for index in range(buttons.size()):
		music.call("_setup_image_button", buttons[index], "", positions[index], Vector2(124.0, 38.0))
		_assert(buttons[index].size.y >= ModalFoundation.PREFERRED_TOUCH_TARGET, "%s transport target is 48px" % buttons[index].name)
		var art := buttons[index].get_node("AspectArt") as TextureRect
		_assert(art.size == Vector2(124.0, 38.0), "%s keeps its visible art at the original size" % buttons[index].name)
	_assert_non_overlapping_local(buttons, "MusicRoom transport controls")
	music.free()


func _validate_custom_targets() -> void:
	var custom := CUSTOM_SCENE.instantiate() as Control
	var option_paths := [
		"MainVBox/DiffBox/BtnEasy", "MainVBox/DiffBox/BtnNormal", "MainVBox/DiffBox/BtnHard",
		"MainVBox/SortBox/BtnSortOn", "MainVBox/SortBox/BtnSortOff",
		"MainVBox/TimerBox/BtnTimerOff", "MainVBox/TimerBox/BtnTimerOn",
		"MainVBox/SecondsBox/BtnMinus", "MainVBox/SecondsBox/BtnPlus",
		"MainVBox/CountBox/Btn10", "MainVBox/CountBox/Btn20", "MainVBox/CountBox/Btn30", "MainVBox/CountBox/BtnInf",
	]
	var controls: Array[Control] = []
	for path in option_paths:
		var button := custom.get_node(path) as Button
		custom.call("_style_option_button", button)
		controls.append(button)
	for path in ["MainVBox/BgmGrid/CheckYume", "MainVBox/BgmGrid/CheckUtu", "MainVBox/BgmGrid/CheckMaboA", "MainVBox/BgmGrid/CheckMaboB"]:
		var check := custom.get_node(path) as CheckBox
		custom.call("_style_bgm_check", check)
		controls.append(check)
	custom.set_script(null)
	custom.set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom.size = Vector2(480.0, 854.0)
	add_child(custom)
	await get_tree().process_frame
	await get_tree().process_frame
	for control in controls:
		_assert(control.size.y >= ModalFoundation.PREFERRED_TOUCH_TARGET, "%s Custom target is 48px" % control.name)
	_assert_non_overlapping(controls, "Custom small controls")
	custom.queue_free()
	await get_tree().process_frame


func _validate_button_feedback_focus_policy() -> void:
	var root := Control.new()
	add_child(root)
	var focusable := Button.new()
	focusable.focus_mode = Control.FOCUS_ALL
	focusable.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	root.add_child(focusable)
	var intentional_none := Button.new()
	intentional_none.focus_mode = Control.FOCUS_NONE
	root.add_child(intentional_none)
	ButtonFeedback.install(root)
	_assert(focusable.focus_mode == Control.FOCUS_ALL, "ButtonFeedback preserves a focusable button")
	_assert(focusable.get_theme_stylebox("focus") is StyleBoxFlat, "ButtonFeedback replaces an empty focus style with a visible common ring")
	_assert(intentional_none.focus_mode == Control.FOCUS_NONE, "ButtonFeedback preserves an intentional FOCUS_NONE")
	root.queue_free()


func _validate_fixed_baseline_positions() -> void:
	var stage := STAGE_SELECT_SCENE.instantiate() as Control
	stage.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stage.size = Vector2(480.0, 854.0)
	add_child(stage)
	await get_tree().process_frame
	_assert((stage.get_node("BtnSideChange") as Control).position == Vector2(24.0, 772.0), "StageSelect side-change returns to (24,772)")
	_assert((stage.get_node("BtnHome") as Control).position == Vector2(308.0, 762.0), "StageSelect Home returns to (308,762)")
	_assert((stage.get_node("BtnSettings") as Control).position == Vector2(388.0, 762.0), "StageSelect Settings returns to (388,762)")
	stage.queue_free()
	await get_tree().process_frame

	var custom := CUSTOM_SCENE.instantiate() as Control
	custom.set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom.size = Vector2(480.0, 854.0)
	add_child(custom)
	await get_tree().process_frame
	_assert((custom.get_node("BottomBox") as Control).position == Vector2(36.0, 752.0), "Custom BottomBox returns to (36,752)")
	custom.queue_free()
	await get_tree().process_frame

	var music := MUSIC_ROOM_SCENE.instantiate() as Control
	music.set_anchors_preset(Control.PRESET_TOP_LEFT)
	music.size = Vector2(480.0, 854.0)
	add_child(music)
	await get_tree().process_frame
	_assert((music.get_node("BtnBack") as Control).position == Vector2(314.0, 752.0), "MusicRoom Back returns to (314,752)")
	_assert((music.get_node("BtnSettings") as Control).position == Vector2(390.0, 752.0), "MusicRoom Settings returns to (390,752)")
	music.queue_free()
	await get_tree().process_frame
	if AudioManager != null:
		AudioManager.stop_bgm()


func _assert_focus_paths_stay_inside(panel: Control, controls: Array[Control]) -> void:
	for control in controls:
		for path in [control.focus_neighbor_left, control.focus_neighbor_right, control.focus_neighbor_top, control.focus_neighbor_bottom, control.focus_next, control.focus_previous]:
			var target := control.get_node_or_null(path) as Control
			_assert(target != null and panel.is_ancestor_of(target), "%s focus navigation stays inside the active modal" % control.name)


func _assert_non_overlapping(controls: Array[Control], label: String) -> void:
	for first_index in range(controls.size()):
		for second_index in range(first_index + 1, controls.size()):
			_assert(not controls[first_index].get_global_rect().intersects(controls[second_index].get_global_rect()), "%s do not overlap: %s / %s" % [label, controls[first_index].name, controls[second_index].name])


func _assert_non_overlapping_local(controls: Array[Button], label: String) -> void:
	for first_index in range(controls.size()):
		for second_index in range(first_index + 1, controls.size()):
			var first_rect := Rect2(controls[first_index].position, controls[first_index].size)
			var second_rect := Rect2(controls[second_index].position, controls[second_index].size)
			_assert(not first_rect.intersects(second_rect), "%s do not overlap" % label)


func _assert_controls_inside(panel: Control, controls: Array[Control], label: String) -> void:
	var panel_rect := panel.get_global_rect()
	for control in controls:
		var rect := control.get_global_rect()
		_assert(panel_rect.encloses(rect), "%s: %s remains inside the panel" % [label, control.name])


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error(message)
