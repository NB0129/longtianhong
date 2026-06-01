extends Control

const PATH_BG := "res://assets/bg/bg_custom.webp"

func _ready() -> void:
	if ResourceLoader.exists(PATH_BG):
		$BG.texture = load(PATH_BG)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.45)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	move_child(overlay, 1)

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

	$MainVBox/SecondsBox/SecondsLabel.text = str(SaveData.custom_timer_seconds) + "秒"

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
	$MainVBox/SecondsBox/SecondsLabel.text = str(SaveData.custom_timer_seconds) + "秒"

func _on_plus_pressed() -> void:
	SaveData.custom_timer_seconds = min(990, SaveData.custom_timer_seconds + 10)
	SaveData.save()
	$MainVBox/SecondsBox/SecondsLabel.text = str(SaveData.custom_timer_seconds) + "秒"

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
	get_tree().change_scene_to_file("res://Game.tscn")
