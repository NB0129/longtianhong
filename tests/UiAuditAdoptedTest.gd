extends Control

const ModalFoundation := preload("res://ModalFoundation.gd")
const TITLE_SCENE := preload("res://Title.tscn")
const MUSIC_ROOM_SCENE := preload("res://MusicRoom.tscn")
const STAGE_SELECT_SCENE := preload("res://StageSelect.tscn")

const STATUS_TEXT := {
	"ja": ["選択中｜ちゅーとりある", "再生中｜ちゅーとりある", "一時停止｜ちゅーとりある"],
	"en": ["Selected｜Tutorial", "Playing｜Tutorial", "Paused｜Tutorial"],
	"zh_CN": ["已选择｜教程", "播放中｜教程", "已暂停｜教程"],
	"zh_TW": ["已選擇｜教學", "播放中｜教學", "已暫停｜教學"],
	"ko": ["선택 중｜튜토리얼", "재생 중｜튜토리얼", "일시 정지｜튜토리얼"],
}

const SUPPORT_TITLE_TEXT := {
	"ja": "開発支援",
	"en": "Development Support",
	"zh_CN": "开发支援",
	"zh_TW": "開發支援",
	"ko": "개발 지원",
}

var _failed := false
var _original_language := "ja"
var _background_press_count := 0


func _ready() -> void:
	_original_language = SaveData.language_code
	SaveData.language_code = "ja"
	await _validate_music_room_status_and_list()
	await _validate_title_modal_foundation()
	await _validate_support_heading()
	SaveData.language_code = _original_language
	if AudioManager != null:
		AudioManager.stop_bgm()
	if _failed:
		get_tree().quit(1)
		return
	print("PASS ui_audit_adopted music_status_locales=5 music_rows=21 list_wrap=1 list_scroll=1 title_modal=1 title_touch_48=1 support_title_locales=5 support_title_height=56")
	get_tree().quit(0)


func _validate_music_room_status_and_list() -> void:
	var music := MUSIC_ROOM_SCENE.instantiate() as Control
	music.set_anchors_preset(Control.PRESET_TOP_LEFT)
	music.size = Vector2(480.0, 854.0)
	add_child(music)
	await get_tree().process_frame
	await get_tree().process_frame

	var status := music.get_node_or_null("PlaybackStatusLabel") as Label
	_assert(status != null, "MusicRoom creates the playback status label")
	if status != null:
		_assert(status.position == Vector2(38.0, 442.0), "MusicRoom status keeps position (38,442)")
		_assert(status.size == Vector2(404.0, 28.0), "MusicRoom status keeps size (404,28)")
		_assert(status.get_theme_font_size("font_size") == 18, "MusicRoom status keeps font size 18")
		_assert(status.autowrap_mode == TextServer.AUTOWRAP_OFF and status.clip_text, "MusicRoom status stays on one contained line")

	for locale: String in STATUS_TEXT:
		SaveData.language_code = locale
		music.set("_full_list_selected_index", 0)
		music.set("_player_state", "idle")
		music.set("_current_playing_file", "")
		music.call("_build_full_list")
		music.call("_update_track_name_display")
		await get_tree().process_frame
		_assert(status.text == str(STATUS_TEXT[locale][0]), "%s selected status is localized" % locale)
		music.set("_player_state", "playing")
		music.set("_current_playing_file", "bgm_talk_tutorial")
		music.call("_update_track_name_display")
		_assert(status.text == str(STATUS_TEXT[locale][1]), "%s playing status is localized" % locale)
		music.set("_player_state", "paused")
		music.call("_update_track_name_display")
		_assert(status.text == str(STATUS_TEXT[locale][2]), "%s paused status is localized" % locale)

	SaveData.language_code = "ja"
	music.set("_full_list_selected_index", 0)
	music.set("_player_state", "idle")
	music.set("_current_playing_file", "")
	music.call("_build_full_list")
	music.call("_update_track_name_display")
	await get_tree().process_frame
	await get_tree().process_frame

	var scroll := music.get_node("FullListScroll") as ScrollContainer
	var vbox := music.get_node("FullListScroll/FullListVBox") as VBoxContainer
	var rows := vbox.get_children()
	_assert(rows.size() == 21, "MusicRoom keeps all 21 track rows")
	if rows.size() == 21:
		for row_node in rows:
			var row := row_node as Button
			_assert(row != null and row.focus_mode == Control.FOCUS_ALL, "MusicRoom row is keyboard/controller focusable")
			_assert(row != null and is_equal_approx(row.custom_minimum_size.y, 50.0) and row.size.y >= 50.0, "MusicRoom row keeps its 50px target")
			if row != null:
				var focus_style := row.get_theme_stylebox("focus") as StyleBoxFlat
				_assert(focus_style != null and focus_style.border_width_top >= 3, "MusicRoom row has the common visible focus ring")
		var first := rows[0] as Button
		var last := rows[rows.size() - 1] as Button
		_assert(first.get_node_or_null(first.focus_neighbor_top) == last, "MusicRoom Up wraps first row to last")
		_assert(last.get_node_or_null(last.focus_neighbor_bottom) == first, "MusicRoom Down wraps last row to first")
		first.grab_focus()
		await get_tree().process_frame
		await _push_action("ui_up")
		await get_tree().process_frame
		await get_tree().process_frame
		_assert(get_viewport().gui_get_focus_owner() == last, "real ui_up input wraps focus to the last MusicRoom row")
		_assert(scroll.scroll_vertical > 0, "focused last MusicRoom row is scrolled into view")
		_assert(scroll.get_global_rect().intersects(last.get_global_rect()), "focused last MusicRoom row is visible in the scroll viewport")
		await _push_action("ui_down")
		await get_tree().process_frame
		await get_tree().process_frame
		_assert(get_viewport().gui_get_focus_owner() == first, "real ui_down input wraps focus back to the first MusicRoom row")
		_assert(scroll.get_global_rect().intersects(first.get_global_rect()), "focused first MusicRoom row is visible in the scroll viewport")

		var second := rows[1] as Button
		await _click_control(second)
		_assert(status.text == "選択中｜麻雀山の入り口", "actual row selection updates the selected status and track name")
		await _click_control(music.get_node("PlayerPanel/BtnPlay") as Button)
		_assert(status.text == "再生中｜麻雀山の入り口", "actual Play input updates the playing status and track name")
		await _click_control(music.get_node("PlayerPanel/BtnPause") as Button)
		_assert(status.text == "一時停止｜麻雀山の入り口", "actual Pause input updates the paused status and track name")
		await _click_control(music.get_node("PlayerPanel/BtnStop") as Button)
		_assert(status.text == "選択中｜麻雀山の入り口", "actual Stop input returns to the selected status")

	if AudioManager != null:
		AudioManager.stop_bgm()
	music.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _validate_title_modal_foundation() -> void:
	SaveData.language_code = "ja"
	var title := TITLE_SCENE.instantiate() as Control
	title.set_anchors_preset(Control.PRESET_TOP_LEFT)
	title.size = Vector2(480.0, 854.0)
	add_child(title)
	await get_tree().process_frame
	await get_tree().process_frame

	for path in ["StoryFrame/BtnStory", "InstantFrame/BtnInstant", "BtnSettings", "CreditFrame/BtnCredit"]:
		var button := title.get_node(path) as Button
		_assert(button.focus_mode == Control.FOCUS_ALL, "%s is focusable on Title" % path)
		_assert(button.get_theme_stylebox("focus") is StyleBoxFlat, "%s has a visible common focus style" % path)
	var ranking := title.get_node("RankingFrame/BtnRanking") as Button
	_assert(ranking.focus_mode == Control.FOCUS_ALL, "Title Ranking preserves focus capability when available")

	var settings_button := title.get_node("BtnSettings") as Button
	settings_button.disabled = true
	await _click_control(settings_button)
	_assert(not (title.get_node("SettingsPopup") as Control).visible, "disabled Title control does not react")
	settings_button.disabled = false

	var test_background := Button.new()
	test_background.name = "ModalBackgroundProbe"
	test_background.position = Vector2(2.0, 2.0)
	test_background.size = Vector2(28.0, 28.0)
	test_background.focus_mode = Control.FOCUS_NONE
	test_background.pressed.connect(_on_background_probe_pressed)
	title.add_child(test_background)

	await _click_control(settings_button)
	var settings_panel := title.get_node("SettingsPopup") as Panel
	var settings_overlay := title.get_node("SettingsOverlay") as Control
	_assert(settings_panel.visible and settings_overlay.visible, "Title Settings opens with its backdrop")
	_assert(settings_overlay.mouse_filter == Control.MOUSE_FILTER_STOP, "Title Settings backdrop intercepts pointer input")
	_assert(settings_overlay.get_global_rect().size == Vector2(480.0, 854.0), "Title Settings backdrop covers the 480x854 screen")
	_assert(settings_overlay.z_index < settings_panel.z_index, "Title Settings panel stays above its backdrop")
	_assert(get_viewport().gui_get_focus_owner() == settings_panel.get_node("VBox/BgmSlider"), "Title Settings moves initial focus to BGM")
	_assert_focus_confined(settings_panel)
	await _click_control(test_background)
	_assert(_background_press_count == 0, "Title modal blocks an actual background pointer target")
	if not settings_panel.visible:
		await _click_control(settings_button)

	var settings_controls: Array[Control] = [
		settings_panel.get_node("VBox/BgmSlider") as Control,
		settings_panel.get_node("VBox/SeSlider") as Control,
		settings_panel.get_node("VBox/TileSuitGrid/BtnPinzu") as Control,
		settings_panel.get_node("VBox/TileSuitGrid/BtnSouzu") as Control,
		settings_panel.get_node("VBox/TileSuitGrid/BtnManzu") as Control,
		settings_panel.get_node("VBox/TileSuitGrid/BtnManzu2") as Control,
		settings_panel.get_node("VBox/LanguageGrid/BtnLanguageja") as Control,
		settings_panel.get_node("VBox/LanguageGrid/BtnLanguageen") as Control,
		settings_panel.get_node("VBox/LanguageGrid/BtnLanguagezhCN") as Control,
		settings_panel.get_node("VBox/LanguageGrid/BtnLanguagezhTW") as Control,
		settings_panel.get_node("VBox/LanguageGrid/BtnLanguageko") as Control,
		settings_panel.get_node("VBox/BtnSettingsClose") as Control,
	]
	for control in settings_controls:
		_assert(control.focus_mode == Control.FOCUS_ALL, "%s is focusable in Title Settings" % control.name)
	_assert_language_targets(settings_panel)
	_assert_focus_confined(settings_panel)
	await _push_action("ui_cancel")
	await get_tree().process_frame
	_assert(not settings_panel.visible and not settings_overlay.visible, "Back closes only Title Settings")
	_assert(get_viewport().gui_get_focus_owner() == settings_button, "closing Title Settings restores its invoking focus")

	var credit_button := title.get_node("CreditFrame/BtnCredit") as Button
	await _click_control(credit_button)
	var credit_panel := title.get_node("CreditPopup") as Panel
	var credit_overlay := title.get_node("CreditOverlay") as Control
	var licenses := title.get_node("CreditPopup/VBox/CreditActionRow/BtnLicenses") as Button
	var privacy := title.get_node("CreditPopup/VBox/CreditActionRow/BtnPrivacyPolicy") as Button
	_assert(credit_panel.visible and credit_overlay.visible, "Title Credits opens with its backdrop")
	_assert(credit_overlay.mouse_filter == Control.MOUSE_FILTER_STOP and credit_overlay.get_global_rect().size == Vector2(480.0, 854.0), "Title Credits backdrop blocks the full screen")
	_assert(credit_overlay.z_index < credit_panel.z_index, "Title Credits panel stays above its backdrop")
	_assert(get_viewport().gui_get_focus_owner() == licenses, "Title Credits moves initial focus to Licenses / OSS")
	_assert_focus_confined(credit_panel)

	await _click_control(licenses)
	_assert(bool(title.get("_credit_legal_view_active")), "actual Licenses input opens the legal view")
	_assert(not privacy.visible, "legal view hides the Privacy Policy action")
	_assert(get_viewport().gui_get_focus_owner() == licenses, "legal view keeps focus on a visible legal action")
	_assert_focus_confined(credit_panel)
	await _push_action("ui_cancel")
	await get_tree().process_frame
	_assert(credit_panel.visible and not bool(title.get("_credit_legal_view_active")), "first Back returns only Legal to Credits")
	_assert(privacy.visible, "returning to Credits restores the Privacy Policy action")
	_assert_focus_confined(credit_panel)
	await _push_action("ui_cancel")
	await get_tree().process_frame
	_assert(not credit_panel.visible and not credit_overlay.visible, "second Back closes Credits")
	_assert(get_viewport().gui_get_focus_owner() == credit_button, "closing Credits restores its invoking focus")

	title.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _assert_language_targets(panel: Control) -> void:
	var buttons: Array[Control] = []
	for code in ["ja", "en", "zhCN", "zhTW", "ko"]:
		buttons.append(panel.get_node("VBox/LanguageGrid/BtnLanguage" + code) as Control)
	for button in buttons:
		_assert(button.custom_minimum_size.y >= ModalFoundation.PREFERRED_TOUCH_TARGET, "%s requests a 48px language target" % button.name)
		_assert(button.size.y >= ModalFoundation.PREFERRED_TOUCH_TARGET, "%s has an effective 48px language target" % button.name)
		_assert(panel.get_global_rect().encloses(button.get_global_rect()), "%s stays inside Title Settings" % button.name)
	for first_index in range(buttons.size()):
		for second_index in range(first_index + 1, buttons.size()):
			_assert(not buttons[first_index].get_global_rect().intersects(buttons[second_index].get_global_rect()), "Title language targets do not overlap")


func _validate_support_heading() -> void:
	SaveData.language_code = "ja"
	var stage := STAGE_SELECT_SCENE.instantiate() as Control
	stage.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stage.size = Vector2(480.0, 854.0)
	add_child(stage)
	await get_tree().process_frame
	await get_tree().process_frame
	stage.call("_show_support_popup")
	await get_tree().process_frame
	await get_tree().process_frame

	var panel := stage.get_node("SupportPopup") as Panel
	var title := stage.get_node("SupportPopup/VBox/SupportTitle") as Label
	var body := stage.get_node("SupportPopup/VBox/SupportBody") as Label
	_assert(panel.visible and title.visible, "StageSelect support modal shows its text heading")
	_assert(title.custom_minimum_size.y == 56.0 and title.size.y >= 56.0, "StageSelect support heading uses the adopted 56px height")
	_assert(panel.get_global_rect().encloses(title.get_global_rect()), "StageSelect support heading stays inside its panel")
	_assert(not title.get_global_rect().intersects(body.get_global_rect()), "StageSelect support heading returns space without overlapping the body")
	for locale: String in SUPPORT_TITLE_TEXT:
		SaveData.language_code = locale
		stage.call("_refresh_support_popup_texts")
		await get_tree().process_frame
		_assert(title.text == str(SUPPORT_TITLE_TEXT[locale]), "%s support heading is localized" % locale)
		_assert(not title.text.is_empty() and panel.get_global_rect().encloses(title.get_global_rect()), "%s support heading fallback remains contained" % locale)
	stage.call("_set_support_popup_visible", false)
	stage.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _assert_focus_confined(panel: Control) -> void:
	var controls := ModalFoundation.collect_focusable_controls(panel)
	_assert(not controls.is_empty(), "%s has focusable modal controls" % panel.name)
	for control in controls:
		for path in [control.focus_neighbor_left, control.focus_neighbor_right, control.focus_neighbor_top, control.focus_neighbor_bottom, control.focus_previous, control.focus_next]:
			var target := control.get_node_or_null(path) as Control
			_assert(target != null and panel.is_ancestor_of(target), "%s focus stays inside %s" % [control.name, panel.name])


func _click_control(control: Control) -> void:
	_assert(control != null and control.is_visible_in_tree(), "pointer target is a visible real control")
	if control == null or not control.is_visible_in_tree():
		return
	var point := control.get_global_rect().get_center()
	for is_pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if is_pressed else 0
		event.pressed = is_pressed
		event.position = point
		event.global_position = point
		get_viewport().push_input(event, true)
		await get_tree().process_frame


func _push_action(action: StringName) -> void:
	for is_pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = is_pressed
		get_viewport().push_input(event, true)
		await get_tree().process_frame


func _on_background_probe_pressed() -> void:
	_background_press_count += 1


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
