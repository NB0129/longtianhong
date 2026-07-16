extends Control

const ButtonFeedback := preload("res://ButtonFeedback.gd")

const PATH_BG := "res://assets/bg/custom_room_bg_generated.webp"
const PATH_TITLE := "res://assets/bg/custom_room_title.webp"
const PATH_PANEL := "res://assets/bg/custom_room_panel.webp"
const PATH_BTN_BACK := "res://assets/bg/custom_btn_back.webp"
const PATH_BTN_START := "res://assets/bg/custom_btn_start.webp"
const LOCALIZED_CUSTOM_ROOM_DIR := "res://assets/language/normalized/%s/custom_room/"

const PANEL_COLOR := Color(1.0, 0.95, 0.78, 0.58)
const LINE_CYAN := Color(0.60, 0.84, 0.66, 0.55)
const LINE_GOLD := Color(0.96, 0.66, 0.18, 0.75)
const TEXT_MAIN := Color(0.28, 0.18, 0.10)
const TEXT_SUB := Color(0.10, 0.38, 0.32)

const CUSTOM_TEXT := {
	"ja": {
		"difficulty": "難易度",
		"easy": "7枚",
		"normal": "10枚",
		"hard": "13枚",
		"sort": "理牌",
		"timer": "タイム",
		"question_count": "問題数",
		"seconds": "秒数：",
		"on": "あり",
		"off": "なし",
		"infinite": "∞",
		"bgm_yume": "幽夢",
		"bgm_utu": "現棘",
		"bgm_mabo_a": "まぼろし1",
		"bgm_mabo_b": "まぼろし2",
		"seconds_format": "%d秒",
	},
	"en": {
		"difficulty": "Difficulty",
		"easy": "7 tiles",
		"normal": "10 tiles",
		"hard": "13 tiles",
		"sort": "Sort hand",
		"timer": "Timer",
		"question_count": "Questions",
		"seconds": "Seconds:",
		"on": "On",
		"off": "Off",
		"infinite": "∞",
		"bgm_yume": "Yume",
		"bgm_utu": "Ututsu",
		"bgm_mabo_a": "Maboroshi 1",
		"bgm_mabo_b": "Maboroshi 2",
		"seconds_format": "%d sec",
	},
	"zh_CN": {
		"difficulty": "难度",
		"easy": "7张",
		"normal": "10张",
		"hard": "13张",
		"sort": "理牌",
		"timer": "计时",
		"question_count": "题数",
		"seconds": "秒数：",
		"on": "开",
		"off": "关",
		"infinite": "∞",
		"bgm_yume": "幽梦",
		"bgm_utu": "现棘",
		"bgm_mabo_a": "幻胧1",
		"bgm_mabo_b": "幻胧2",
		"seconds_format": "%d秒",
	},
	"zh_TW": {
		"difficulty": "難度",
		"easy": "7張",
		"normal": "10張",
		"hard": "13張",
		"sort": "理牌",
		"timer": "計時",
		"question_count": "題數",
		"seconds": "秒數：",
		"on": "開",
		"off": "關",
		"infinite": "∞",
		"bgm_yume": "幽夢",
		"bgm_utu": "現棘",
		"bgm_mabo_a": "幻朧1",
		"bgm_mabo_b": "幻朧2",
		"seconds_format": "%d秒",
	},
	"ko": {
		"difficulty": "난이도",
		"easy": "7장",
		"normal": "10장",
		"hard": "13장",
		"sort": "패 정렬",
		"timer": "타이머",
		"question_count": "문제 수",
		"seconds": "초:",
		"on": "있음",
		"off": "없음",
		"infinite": "∞",
		"bgm_yume": "유메",
		"bgm_utu": "우츠츠",
		"bgm_mabo_a": "마보로시 1",
		"bgm_mabo_b": "마보로시 2",
		"seconds_format": "%d초",
	},
}

func _ready() -> void:
	if ResourceLoader.exists(PATH_BG):
		$BG.texture = load(PATH_BG)
	$BG.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$BG.stretch_mode = TextureRect.STRETCH_SCALE

	var overlay := ColorRect.new()
	overlay.color = Color(1.0, 0.95, 0.78, 0.06)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	move_child(overlay, 1)

	_setup_generated_ui()

	var diff_group := ButtonGroup.new()
	$MainVBox/DiffBox/BtnEasy.button_group   = diff_group
	$MainVBox/DiffBox/BtnNormal.button_group = diff_group
	$MainVBox/DiffBox/BtnHard.button_group   = diff_group

	var sort_group := ButtonGroup.new()
	$MainVBox/SortBox/BtnSortOn.button_group  = sort_group
	$MainVBox/SortBox/BtnSortOff.button_group = sort_group

	var timer_group := ButtonGroup.new()
	$MainVBox/TimerBox/BtnTimerOff.button_group = timer_group
	$MainVBox/TimerBox/BtnTimerOn.button_group  = timer_group

	var count_group := ButtonGroup.new()
	$MainVBox/CountBox/Btn10.button_group  = count_group
	$MainVBox/CountBox/Btn20.button_group  = count_group
	$MainVBox/CountBox/Btn30.button_group  = count_group
	$MainVBox/CountBox/BtnInf.button_group = count_group

	$MainVBox/DiffBox/BtnEasy.pressed.connect(_on_difficulty_changed)
	$MainVBox/DiffBox/BtnNormal.pressed.connect(_on_difficulty_changed)
	$MainVBox/DiffBox/BtnHard.pressed.connect(_on_difficulty_changed)

	$MainVBox/SortBox/BtnSortOn.pressed.connect(_on_sort_changed)
	$MainVBox/SortBox/BtnSortOff.pressed.connect(_on_sort_changed)

	$MainVBox/TimerBox/BtnTimerOff.pressed.connect(_on_timer_changed)
	$MainVBox/TimerBox/BtnTimerOn.pressed.connect(_on_timer_changed)

	$MainVBox/SecondsBox/BtnMinus.pressed.connect(_on_minus_pressed)
	$MainVBox/SecondsBox/BtnPlus.pressed.connect(_on_plus_pressed)

	$MainVBox/CountBox/Btn10.pressed.connect(_on_count_changed)
	$MainVBox/CountBox/Btn20.pressed.connect(_on_count_changed)
	$MainVBox/CountBox/Btn30.pressed.connect(_on_count_changed)
	$MainVBox/CountBox/BtnInf.pressed.connect(_on_count_changed)

	$MainVBox/BgmGrid/CheckYume.toggled.connect(_on_bgm_changed)
	$MainVBox/BgmGrid/CheckUtu.toggled.connect(_on_bgm_changed)
	$MainVBox/BgmGrid/CheckMaboA.toggled.connect(_on_bgm_changed)
	$MainVBox/BgmGrid/CheckMaboB.toggled.connect(_on_bgm_changed)

	$BottomBox/BtnBack.pressed.connect(_on_btn_back_pressed)
	$BottomBox/BtnStart.pressed.connect(_on_btn_start_pressed)

	load_settings()
	_apply_text_language()
	ButtonFeedback.install(self)

func _setup_generated_ui() -> void:
	_add_texture_layer("CustomTitleImage", _localized_custom_room_path("custom_room_title.webp", PATH_TITLE), Vector2(24.0, 20.0), Vector2(432.0, 112.0))
	_add_texture_layer("MainPanelBacking", PATH_PANEL, Vector2(32.0, 146.0), Vector2(416.0, 560.0))

	$MainVBox.set_anchors_preset(Control.PRESET_TOP_LEFT)
	$MainVBox.position = Vector2(70.0, 212.0)
	$MainVBox.size = Vector2(340.0, 426.0)
	$MainVBox.add_theme_constant_override("separation", 4)

	_style_section_label($MainVBox/DiffLabel)
	$MainVBox/DiffLabel.custom_minimum_size = Vector2(0.0, 30.0)
	$MainVBox/DiffLabel.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_style_section_label($MainVBox/SortLabel)
	_style_section_label($MainVBox/TimerLabel)
	_style_section_label($MainVBox/CountLabel)
	_style_section_label($MainVBox/BgmLabel)
	_style_seconds_label($MainVBox/SecondsBox/SecondsHeadLabel)
	_style_seconds_label($MainVBox/SecondsBox/SecondsLabel)

	for box in [
		$MainVBox/DiffBox,
		$MainVBox/SortBox,
		$MainVBox/TimerBox,
		$MainVBox/SecondsBox,
		$MainVBox/CountBox,
	]:
		box.add_theme_constant_override("separation", 8)

	$MainVBox/SecondsBox.add_theme_constant_override("separation", 7)
	$MainVBox/CountBox.add_theme_constant_override("separation", 6)
	$MainVBox/BgmGrid.add_theme_constant_override("h_separation", 10)
	$MainVBox/BgmGrid.add_theme_constant_override("v_separation", 3)

	for button in [
		$MainVBox/DiffBox/BtnEasy,
		$MainVBox/DiffBox/BtnNormal,
		$MainVBox/DiffBox/BtnHard,
		$MainVBox/SortBox/BtnSortOn,
		$MainVBox/SortBox/BtnSortOff,
		$MainVBox/TimerBox/BtnTimerOff,
		$MainVBox/TimerBox/BtnTimerOn,
		$MainVBox/SecondsBox/BtnMinus,
		$MainVBox/SecondsBox/BtnPlus,
		$MainVBox/CountBox/Btn10,
		$MainVBox/CountBox/Btn20,
		$MainVBox/CountBox/Btn30,
		$MainVBox/CountBox/BtnInf,
	]:
		_style_option_button(button)

	for check in [
		$MainVBox/BgmGrid/CheckYume,
		$MainVBox/BgmGrid/CheckUtu,
		$MainVBox/BgmGrid/CheckMaboA,
		$MainVBox/BgmGrid/CheckMaboB,
	]:
		_style_bgm_check(check)

	$BottomBox.set_anchors_preset(Control.PRESET_TOP_LEFT)
	$BottomBox.position = Vector2(36.0, 752.0)
	$BottomBox.size = Vector2(412.0, 62.0)
	$BottomBox.add_theme_constant_override("separation", 32)
	$BottomBox.alignment = BoxContainer.ALIGNMENT_CENTER
	_style_command_button($BottomBox/BtnBack, _localized_custom_room_path("custom_btn_back.webp", PATH_BTN_BACK), Vector2(154.0, 54.0), false)
	_style_command_button($BottomBox/BtnStart, _localized_custom_room_path("custom_btn_start.webp", PATH_BTN_START), Vector2(204.0, 54.0), true)

func _localized_custom_room_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if locale == "ja":
		return fallback_path
	var localized_path := (LOCALIZED_CUSTOM_ROOM_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _custom_text(key: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var texts: Dictionary = CUSTOM_TEXT.get(locale, CUSTOM_TEXT["ja"])
	return str(texts.get(key, CUSTOM_TEXT["ja"].get(key, "")))

func _custom_seconds_text(seconds: int) -> String:
	return _custom_text("seconds_format") % seconds

func _apply_text_language() -> void:
	$MainVBox/DiffLabel.text = _custom_text("difficulty")
	$MainVBox/DiffBox/BtnEasy.text = _custom_text("easy")
	$MainVBox/DiffBox/BtnNormal.text = _custom_text("normal")
	$MainVBox/DiffBox/BtnHard.text = _custom_text("hard")
	$MainVBox/SortLabel.text = _custom_text("sort")
	$MainVBox/SortBox/BtnSortOn.text = _custom_text("on")
	$MainVBox/SortBox/BtnSortOff.text = _custom_text("off")
	$MainVBox/TimerLabel.text = _custom_text("timer")
	$MainVBox/TimerBox/BtnTimerOff.text = _custom_text("off")
	$MainVBox/TimerBox/BtnTimerOn.text = _custom_text("on")
	$MainVBox/SecondsBox/SecondsHeadLabel.text = _custom_text("seconds")
	$MainVBox/SecondsBox/SecondsLabel.text = _custom_seconds_text(SaveData.custom_timer_seconds)
	$MainVBox/CountLabel.text = _custom_text("question_count")
	$MainVBox/CountBox/BtnInf.text = _custom_text("infinite")
	$MainVBox/BgmGrid/CheckYume.text = _custom_text("bgm_yume")
	$MainVBox/BgmGrid/CheckUtu.text = _custom_text("bgm_utu")
	$MainVBox/BgmGrid/CheckMaboA.text = _custom_text("bgm_mabo_a")
	$MainVBox/BgmGrid/CheckMaboB.text = _custom_text("bgm_mabo_b")

func _add_texture_layer(name: String, path: String, position: Vector2, size: Vector2) -> TextureRect:
	var rect: TextureRect = get_node_or_null(name) as TextureRect
	if rect == null:
		rect = TextureRect.new()
		rect.name = name
		add_child(rect)
		move_child(rect, 2)
	if ResourceLoader.exists(path):
		rect.texture = load(path)
	rect.position = position
	rect.size = size
	rect.custom_minimum_size = size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.clip_contents = true
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _add_panel_backing(name: String, position: Vector2, size: Vector2) -> Panel:
	var panel: Panel = get_node_or_null(name) as Panel
	if panel == null:
		panel = Panel.new()
		panel.name = name
		add_child(panel)
		move_child(panel, 2)
	panel.position = position
	panel.size = size
	if ResourceLoader.exists(PATH_PANEL):
		panel.add_theme_stylebox_override("panel", _make_texture_style(PATH_PANEL, 42.0))
	else:
		var style := StyleBoxFlat.new()
		style.bg_color = PANEL_COLOR
		style.border_color = LINE_GOLD
		style.set_border_width_all(1)
		style.set_corner_radius_all(8)
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.20)
		style.shadow_size = 8
		panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel

func _style_section_label(label: Label) -> void:
	label.custom_minimum_size = Vector2(0.0, 22.0)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", TEXT_SUB)
	label.add_theme_color_override("font_shadow_color", Color(1.0, 0.98, 0.86, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)

func _style_seconds_label(label: Label) -> void:
	label.custom_minimum_size = Vector2(0.0, 34.0)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", TEXT_MAIN)
	label.add_theme_color_override("font_shadow_color", Color(1.0, 0.98, 0.86, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)

func _style_option_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(78.0, 34.0)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_stylebox_override("normal", _make_button_style(Color(1.0, 0.96, 0.80, 0.72), LINE_CYAN))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.90, 1.0, 0.86, 0.84), LINE_CYAN))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.96, 0.75, 0.24, 0.88), LINE_GOLD))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.90, 1.0, 0.86, 0.84), LINE_CYAN))
	button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.72, 0.70, 0.62, 0.42), Color(0.5, 0.45, 0.34, 0.3)))
	button.add_theme_color_override("font_color", TEXT_MAIN)
	button.add_theme_color_override("font_hover_color", TEXT_MAIN)
	button.add_theme_color_override("font_pressed_color", Color(0.45, 0.24, 0.04))
	button.add_theme_color_override("font_focus_color", TEXT_MAIN)
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.58, 0.62))

func _style_command_button(button: Button, image_path: String, size: Vector2, primary: bool) -> void:
	button.text = ""
	button.custom_minimum_size = size
	button.flat = true
	var clear := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", clear)
	button.add_theme_stylebox_override("hover", clear)
	button.add_theme_stylebox_override("pressed", clear)
	button.add_theme_stylebox_override("focus", clear)
	_set_button_art(button, image_path)

func _set_button_art(button: Button, path: String) -> void:
	button.icon = null
	button.expand_icon = false
	var art: TextureRect = button.get_node_or_null("AspectArt") as TextureRect
	if art == null:
		art = TextureRect.new()
		art.name = "AspectArt"
		button.add_child(art)
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.offset_left = 0.0
	art.offset_top = 0.0
	art.offset_right = 0.0
	art.offset_bottom = 0.0
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.clip_contents = true
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(path):
		art.texture = load(path)

func _style_bgm_check(check: CheckBox) -> void:
	check.custom_minimum_size = Vector2(152.0, 30.0)
	check.add_theme_font_size_override("font_size", 18)
	check.add_theme_color_override("font_color", TEXT_MAIN)
	check.add_theme_color_override("font_hover_color", TEXT_MAIN)
	check.add_theme_color_override("font_pressed_color", Color(0.45, 0.24, 0.04))
	check.add_theme_color_override("font_focus_color", TEXT_MAIN)
	check.add_theme_color_override("font_shadow_color", Color(1.0, 0.98, 0.86, 0.75))
	check.add_theme_constant_override("shadow_offset_x", 1)
	check.add_theme_constant_override("shadow_offset_y", 1)

func _make_texture_style(texture_path: String, margin: float) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	if ResourceLoader.exists(texture_path):
		style.texture = load(texture_path)
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	return style

func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin(SIDE_LEFT, 12.0)
	style.set_content_margin(SIDE_TOP, 5.0)
	style.set_content_margin(SIDE_RIGHT, 12.0)
	style.set_content_margin(SIDE_BOTTOM, 5.0)
	return style

func load_settings() -> void:
	match SaveData.custom_difficulty:
		"stage1": $MainVBox/DiffBox/BtnEasy.button_pressed   = true
		"stage2": $MainVBox/DiffBox/BtnNormal.button_pressed = true
		"stage3": $MainVBox/DiffBox/BtnHard.button_pressed   = true
		_:        $MainVBox/DiffBox/BtnHard.button_pressed   = true

	if SaveData.custom_sort_enabled:
		$MainVBox/SortBox/BtnSortOn.button_pressed  = true
	else:
		$MainVBox/SortBox/BtnSortOff.button_pressed = true

	if SaveData.custom_timer_enabled:
		$MainVBox/TimerBox/BtnTimerOn.button_pressed  = true
	else:
		$MainVBox/TimerBox/BtnTimerOff.button_pressed = true

	$MainVBox/SecondsBox/SecondsLabel.text = _custom_seconds_text(SaveData.custom_timer_seconds)

	match SaveData.custom_question_count:
		10: $MainVBox/CountBox/Btn10.button_pressed  = true
		20: $MainVBox/CountBox/Btn20.button_pressed  = true
		30: $MainVBox/CountBox/Btn30.button_pressed  = true
		-1: $MainVBox/CountBox/BtnInf.button_pressed = true
		_:  $MainVBox/CountBox/Btn10.button_pressed  = true

	$MainVBox/BgmGrid/CheckYume.set_pressed_no_signal(SaveData.custom_bgm_yume)
	$MainVBox/BgmGrid/CheckUtu.set_pressed_no_signal(SaveData.custom_bgm_utu)
	$MainVBox/BgmGrid/CheckMaboA.set_pressed_no_signal(SaveData.custom_bgm_mabo_first)
	$MainVBox/BgmGrid/CheckMaboB.set_pressed_no_signal(SaveData.custom_bgm_mabo_second)

	update_seconds_stepper()

func update_seconds_stepper() -> void:
	var timer_on := SaveData.custom_timer_enabled
	$MainVBox/SecondsBox/BtnMinus.disabled = not timer_on
	$MainVBox/SecondsBox/BtnPlus.disabled  = not timer_on
	$MainVBox/SecondsBox/SecondsLabel.modulate.a = 1.0 if timer_on else 0.4

func _on_difficulty_changed() -> void:
	if $MainVBox/DiffBox/BtnEasy.button_pressed:
		SaveData.custom_difficulty = "stage1"
	elif $MainVBox/DiffBox/BtnNormal.button_pressed:
		SaveData.custom_difficulty = "stage2"
	elif $MainVBox/DiffBox/BtnHard.button_pressed:
		SaveData.custom_difficulty = "stage3"
	SaveData.save()

func _on_sort_changed() -> void:
	SaveData.custom_sort_enabled = $MainVBox/SortBox/BtnSortOn.button_pressed
	SaveData.save()

func _on_timer_changed() -> void:
	SaveData.custom_timer_enabled = $MainVBox/TimerBox/BtnTimerOn.button_pressed
	SaveData.save()
	update_seconds_stepper()

func _on_minus_pressed() -> void:
	SaveData.custom_timer_seconds = max(10, SaveData.custom_timer_seconds - 10)
	SaveData.save()
	$MainVBox/SecondsBox/SecondsLabel.text = _custom_seconds_text(SaveData.custom_timer_seconds)

func _on_plus_pressed() -> void:
	SaveData.custom_timer_seconds = min(990, SaveData.custom_timer_seconds + 10)
	SaveData.save()
	$MainVBox/SecondsBox/SecondsLabel.text = _custom_seconds_text(SaveData.custom_timer_seconds)

func _on_count_changed() -> void:
	if $MainVBox/CountBox/Btn10.button_pressed:
		SaveData.custom_question_count = 10
	elif $MainVBox/CountBox/Btn20.button_pressed:
		SaveData.custom_question_count = 20
	elif $MainVBox/CountBox/Btn30.button_pressed:
		SaveData.custom_question_count = 30
	elif $MainVBox/CountBox/BtnInf.button_pressed:
		SaveData.custom_question_count = -1
	SaveData.save()

func _on_bgm_changed(_pressed: bool) -> void:
	SaveData.custom_bgm_yume        = $MainVBox/BgmGrid/CheckYume.button_pressed
	SaveData.custom_bgm_utu         = $MainVBox/BgmGrid/CheckUtu.button_pressed
	SaveData.custom_bgm_mabo_first  = $MainVBox/BgmGrid/CheckMaboA.button_pressed
	SaveData.custom_bgm_mabo_second = $MainVBox/BgmGrid/CheckMaboB.button_pressed
	SaveData.save()

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://StageSelect.tscn")

func _on_btn_start_pressed() -> void:
	if not SaveData.custom_bgm_yume and not SaveData.custom_bgm_utu \
	and not SaveData.custom_bgm_mabo_first and not SaveData.custom_bgm_mabo_second:
		print("BGMを1つ以上選んでください")
		return
	GameState.came_from_stage3 = false
	GameState.current_stage = "custom"
	get_tree().change_scene_to_file("res://game.tscn")
