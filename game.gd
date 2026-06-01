extends Control

# ============================================================
# 牌画像
# ============================================================
var tile_textures: Array = []

# ============================================================
# 牌サイズ定数
# ============================================================
const TILE_W: int       = 64
const TILE_H: int       = 89
const TILE_W_MID: int   = 44
const TILE_H_MID: int   = 61
const TILE_W_SMALL: int = 33
const TILE_H_SMALL: int = 46

# ============================================================
# BGMリスト
# ============================================================
var bgm_list = {
	"stage1":    ["bgm_yume_jantou"],
	"stage2":    ["bgm_utu_higakureru", "bgm_utu_kotaewo", "bgm_utu_syogakusei", "bgm_utu_matigai"],
	"stage3":    ["bgm_mabo_first_appaku"],
	"stage4":    ["bgm_mabo_second_kougetu"],
	"ex_stage1": ["bgm_yume_barabara"],
	"ex_stage2": ["bgm_utu_nochan"],
	"ex_stage3": ["bgm_mabo_first_2tunoboketu"],
	"ex_stage4": ["bgm_mabo_second_inisie"],
}

const ENDLESS_BGM: Array = [
	"bgm_yume_main",           # 0 Easy
	"bgm_utu_zakozako",        # 1 Normal
	"bgm_mabo_first_nebumi",   # 2 Hard
	"bgm_mabo_second_kougetu", # 3 Mirage
	"bgm_yume_barabara",       # 4 Too Easy
	"bgm_utu_nochan",          # 5 Trivial
	"bgm_mabo_second_ginniro", # 6 Adequate
	"bgm_mabo_second_inisie",  # 7 Formidable
	"bgm_mabo_mugen",          # 8+ Endless
]

var bgm_display_names = {
	"bgm_yume_main":               "リーチの歌",
	"bgm_yume_jantou":             "雀頭を探して",
	"bgm_yume_barabara":           "配牌がバラバラ！",
	"bgm_utu_higakureru":          "日が暮れちゃう♡",
	"bgm_utu_zakozako":            "ざこざこおにいちゃん♡",
	"bgm_utu_matigai":             "あれ、間違ってるよ♡",
	"bgm_utu_nochan":              "ノーミスでクリアして♡",
	"bgm_utu_kotaewo":             "答えを教えてあげる♡",
	"bgm_utu_syogakusei":          "小学生れべる♡",
	"bgm_mabo_first_2tunoboketu":  "二つの墓穴",
	"bgm_mabo_first_appaku":       "圧迫問答",
	"bgm_mabo_first_nebumi":       "値踏みの視線",
	"bgm_mabo_second_kougetu":     "紅月の狼",
	"bgm_mabo_second_ginniro":     "銀色の影",
	"bgm_mabo_second_inisie":      "古の英雄",
	"bgm_mabo_mugen":              "無限の決闘",
}

var stage_display_names = {
	"tutorial":  "Tutorial",
	"stage1":    "Easy",
	"stage2":    "Normal",
	"stage3":    "Hard",
	"stage4":    "Mirage",
	"ex_stage1": "Too Easy",
	"ex_stage2": "Trivial",
	"ex_stage3": "Adequate",
	"ex_stage4": "Formidable",
}

const ENDLESS_BLOCK_NAMES: Array = [
	"Easy",       # 0
	"Normal",     # 1
	"Hard",       # 2
	"Mirage",     # 3
	"Too Easy",   # 4
	"Trivial",    # 5
	"Adequate",   # 6
	"Formidable", # 7
	"Endless",    # 8+
]

const ENDLESS_TIME_LIMITS: Array = [
	0.0,   # 0 Easy
	0.0,   # 1 Normal
	0.0,   # 2 Hard
	0.0,   # 3 Mirage
	20.0,  # 4 Too Easy
	20.0,  # 5 Trivial
	20.0,  # 6 Adequate
	20.0,  # 7 Formidable
	20.0,  # 8+ Endless
]

# ============================================================
# 顔画像パス
# ============================================================
const KAO_PYOKO_DEF    := "res://assets/kao/kao_pyoko_def.webp"
const KAO_PYOKO_SEIKAI := [
	"res://assets/kao/kao_pyoko_seikai1.webp",
	"res://assets/kao/kao_pyoko_seikai2.webp",
	"res://assets/kao/kao_pyoko_seikai3.webp",
]
const KAO_PYOKO_MAKE   := [
	"res://assets/kao/kao_pyoko_make1.webp",
	"res://assets/kao/kao_pyoko_make2.webp",
	"res://assets/kao/kao_pyoko_make3.webp",
	"res://assets/kao/kao_pyoko_make4.webp",
]

const KAO_YUME_DEF     := "res://assets/kao/kao_yume_def.webp"
const KAO_YUME_DEF2    := "res://assets/kao/kao_yume_def2.webp"
const KAO_YUME_DEF3    := "res://assets/kao/kao_yume_def3.webp"
const KAO_YUME_KATI    := "res://assets/kao/kao_yume_kati.webp"

const KAO_UTU_DEF      := "res://assets/kao/ututu_waku_1.webp"
const KAO_UTU_DEF2     := "res://assets/kao/ututu_waku_2.webp"
const KAO_UTU_DEF3     := "res://assets/kao/ututu_waku_3.webp"
const KAO_UTU_KATI     := "res://assets/kao/ututu_waku_e1.webp"

const KAO_MABO_DEF     := "res://assets/kao/kao_mabo_def.webp"
const KAO_MABO_DEF2    := "res://assets/kao/kao_mabo_def2.webp"
const KAO_MABO_DEF3    := "res://assets/kao/kao_mabo_def3.webp"
const KAO_MABO_KATI    := "res://assets/kao/kao_mabo_kati.webp"

const SEIKAI_FLASH_DURATION := 0.8

const BTN_HOME_X_NORMAL := 160.0
const BTN_HOME_X_CENTER := 105.0

# ============================================================
# アイコンパス
# ============================================================
const ICON_LAYOUT   := "res://assets/bg/icon_hyouji.webp"
const ICON_SETTINGS := "res://assets/bg/icon_settei.webp"
const ICON_HOME     := "res://assets/bg/icon_home.webp"

const GAMEOVER_IMAGE_PATH := "res://assets/bg/gameover.webp"

# ============================================================
# ゲーム状態変数
# ============================================================
var current_bgm_filename: String = ""
var selected_tiles = []
var correct_tiles = []
var hand_size: int = 13
var total_questions: int = 10
var current_question: int = 0
var popup_state: String = ""
var is_animating: bool = false

var timer_enabled: bool = false
var time_left: float = 20.0
var timer_running: bool = false
var time_limit: float = 20.0

var current_hand: Array = []
var _newly_unlocked_stage: String = ""
var _custom_bgm_connected: bool = false

# ============================================================
# 初期化
# ============================================================
func _ready() -> void:
	for i in range(1, 10):
		var path = "res://assets/tiles/a" + str(i) + "pinz.webp"
		tile_textures.append(load(path))

	hand_size = get_hand_size_for_stage(GameState.current_stage)
	total_questions = 10
	current_question = 0

	if GameState.current_stage == "custom":
		timer_enabled = SaveData.custom_timer_enabled
		time_limit = float(SaveData.custom_timer_seconds)
		if SaveData.custom_question_count == -1:
			total_questions = 999999
		else:
			total_questions = SaveData.custom_question_count
	elif GameState.current_stage == "endless":
		_apply_endless_block_settings()
	elif GameState.current_stage.begins_with("ex_"):
		timer_enabled = true
		time_limit = 20.0
	else:
		timer_enabled = false
		time_limit = 20.0

	_load_stage_bg()
	_setup_face_icons()
	_setup_top_bar_icons()

	play_stage_bgm()
	load_new_question()
	update_question_counter()
	update_debug_display()

	for i in range(1, 10):
		var btn = $Keypad.get_node("Btn" + str(i))
		btn.icon = tile_textures[i - 1]
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.pressed.connect(_on_number_pressed.bind(i))

	$Keypad/BtnNone.pressed.connect(_on_none_pressed)
	$Keypad/BtnClear.pressed.connect(_on_clear_pressed)
	$Keypad/BtnSubmit.pressed.connect(_on_submit_pressed)
	$Keypad/BtnSubmit.disabled = true

	$TopBar/BtnLayout.pressed.connect(_on_btn_layout_pressed)
	$TopBar/BtnSettings.pressed.connect(_on_btn_settings_pressed)

	$HomeConfirmPopup/BtnConfirmYes.pressed.connect(_on_btn_confirm_yes_pressed)
	$HomeConfirmPopup/BtnConfirmNo.pressed.connect(_on_btn_confirm_no_pressed)

	$PopupResult/PopupPanel/BtnRetry.pressed.connect(_on_btn_retry_pressed)
	$PopupResult/PopupPanel/BtnHome.pressed.connect(_on_popup_btn_home_pressed)

	$UnlockPopup/UnlockVBox/BtnUnlockOK.pressed.connect(_on_btn_unlock_ok_pressed)
	$UnlockPopup.visible = false

	$SettingsPopup/VBox/BgmSlider.value_changed.connect(_on_bgm_slider_changed)
	$SettingsPopup/VBox/SeSlider.value_changed.connect(_on_se_slider_changed)
	$SettingsPopup/VBox/BtnSettingsClose.pressed.connect(_on_btn_settings_close_pressed)
	$SettingsPopup.visible = false

	setup_timer_display()

	$HandArea.visible = false
	await play_intro()

	if timer_enabled:
		start_timer()

# ============================================================
# TopBarアイコン設定
# ============================================================
func _setup_top_bar_icons() -> void:
	var btn_layout   := $TopBar/BtnLayout
	var btn_settings := $TopBar/BtnSettings
	var btn_home     := $TopBar/BtnHome

	btn_layout.text = ""
	btn_settings.text = ""
	btn_home.text = ""

	if ResourceLoader.exists(ICON_LAYOUT):
		btn_layout.icon = load(ICON_LAYOUT)
	if ResourceLoader.exists(ICON_SETTINGS):
		btn_settings.icon = load(ICON_SETTINGS)
	if ResourceLoader.exists(ICON_HOME):
		btn_home.icon = load(ICON_HOME)

	btn_layout.expand_icon   = true
	btn_settings.expand_icon = true
	btn_home.expand_icon     = true

# ============================================================
# endlessブロック設定適用
# ============================================================
func _apply_endless_block_settings() -> void:
	var block := GameState.endless_block
	var idx: int = min(block, ENDLESS_TIME_LIMITS.size() - 1)
	var t: float = ENDLESS_TIME_LIMITS[idx] as float
	if t > 0.0:
		timer_enabled = true
		time_limit = t
	else:
		timer_enabled = false
		time_limit = 0.0

# ============================================================
# ゲームオーバー表示リセット
# ============================================================
func _reset_gameover_display() -> void:
	var img := $PopupResult/PopupPanel/GameOverImage
	img.visible = false
	img.position = Vector2(0.0, 8.0)
	img.rotation_degrees = 0.0
	$PopupResult/PopupPanel/CorrectNoneLabel.visible = false
	$PopupResult/PopupPanel/CorrectTilesRow1.visible = false
	$PopupResult/PopupPanel/CorrectTilesRow2.visible = false
	for child in $PopupResult/PopupPanel/CorrectTilesRow1.get_children():
		child.queue_free()
	for child in $PopupResult/PopupPanel/CorrectTilesRow2.get_children():
		child.queue_free()

# ============================================================
# ポップアップのボタン表示切り替え
# ============================================================
func _setup_popup_buttons(state: String) -> void:
	_reset_gameover_display()

	var btn_retry := $PopupResult/PopupPanel/BtnRetry
	var btn_home  := $PopupResult/PopupPanel/BtnHome
	btn_retry.position.y = 210.0
	btn_home.position.y  = 210.0

	if state == "wrong":
		$PopupResult/PopupPanel.position = Vector2(90.0, 320.0)
		$PopupResult/PopupPanel/ResultLabel.visible = false
	elif state == "correct":
		$PopupResult/PopupPanel.position = Vector2(90.0, 220.0)
		$PopupResult/PopupPanel/ResultLabel.visible = true
		$PopupResult/PopupPanel/ResultLabel.position.y = 90.0
	else:
		$PopupResult/PopupPanel.position = Vector2(90.0, 220.0)
		$PopupResult/PopupPanel/ResultLabel.visible = true
		$PopupResult/PopupPanel/ResultLabel.position.y = 40.0

	if state == "clear" and GameState.current_stage != "custom" and GameState.current_stage != "endless" and _newly_unlocked_stage != "":
		btn_retry.visible = false
		btn_home.visible  = true
		btn_home.text     = "OK"
		btn_home.position.x = BTN_HOME_X_CENTER
	elif state == "clear":
		btn_retry.visible = true
		btn_retry.text    = "もう一度"
		btn_home.visible  = true
		btn_home.text     = "ホーム"
		btn_home.position.x = BTN_HOME_X_NORMAL
	elif state == "correct":
		btn_retry.visible = false
		btn_home.visible  = false
	else:
		btn_retry.visible = true
		btn_retry.text    = "もう一度"
		btn_home.visible  = true
		if GameState.is_instant_mode:
			btn_home.text = "タイトルへ"
		else:
			btn_home.text = "ホーム"
		btn_home.position.x = BTN_HOME_X_NORMAL

# ============================================================
# 正解牌を画像で表示
# ============================================================
func _show_correct_tiles(tiles: Array) -> void:
	for child in $PopupResult/PopupPanel/CorrectTilesRow1.get_children():
		child.queue_free()
	for child in $PopupResult/PopupPanel/CorrectTilesRow2.get_children():
		child.queue_free()

	if tiles.is_empty():
		$PopupResult/PopupPanel/CorrectNoneLabel.visible = true
		$PopupResult/PopupPanel/CorrectTilesRow1.visible = false
		$PopupResult/PopupPanel/CorrectTilesRow2.visible = false
		return

	$PopupResult/PopupPanel/CorrectNoneLabel.visible = false

	const SPLIT := 5
	var use_two_rows := tiles.size() > SPLIT
	$PopupResult/PopupPanel/CorrectTilesRow1.visible = true
	$PopupResult/PopupPanel/CorrectTilesRow2.visible = use_two_rows

	for i in range(tiles.size()):
		var tile: int = tiles[i]
		var rect := make_tile_image(tile, TILE_W_SMALL, TILE_H_SMALL)
		if i < SPLIT:
			$PopupResult/PopupPanel/CorrectTilesRow1.add_child(rect)
		else:
			$PopupResult/PopupPanel/CorrectTilesRow2.add_child(rect)

# ============================================================
# ゲームオーバータンブルアニメーション
# ============================================================
func _play_gameover_animation() -> void:
	var img := $PopupResult/PopupPanel/GameOverImage
	if ResourceLoader.exists(GAMEOVER_IMAGE_PATH):
		img.texture = load(GAMEOVER_IMAGE_PATH)
	img.pivot_offset = Vector2(150.0, 37.5)
	img.position = Vector2(-320.0, 8.0)
	img.rotation_degrees = -270.0
	img.visible = true

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(img, "position:x", 0.0, 0.6)
	tween.parallel().tween_property(img, "rotation_degrees", 0.0, 0.6)
	await tween.finished

# ============================================================
# 顔アイコン
# ============================================================
func _setup_face_icons() -> void:
	var face_size := Vector2(144.0, 144.0)
	var vp := get_viewport_rect().size

	$FaceBoss.size = face_size
	$FaceBoss.position = Vector2(10.0, 40.0)

	$FaceMain.size = face_size
	$FaceMain.position = Vector2(vp.x - face_size.x - 10.0, vp.y / 2.0 - face_size.y / 2.0 - 40.0)

	_set_face($FaceMain, KAO_PYOKO_DEF)
	_set_face($FaceBoss, _get_boss_def_path())

func _set_face(node: TextureRect, path: String) -> void:
	if ResourceLoader.exists(path):
		node.texture = load(path)
	else:
		node.texture = null

func _get_effective_stage() -> String:
	if GameState.current_stage == "custom":
		return SaveData.custom_difficulty
	if GameState.current_stage == "endless":
		match GameState.endless_block:
			0: return "stage1"
			1: return "stage2"
			2: return "stage3"
			3: return "stage4"
			4: return "stage1"
			5: return "stage2"
			6: return "stage3"
			_: return "stage4"
	match GameState.current_stage:
		"tutorial":  return "stage1"
		"ex_stage1": return "stage1"
		"ex_stage2": return "stage2"
		"ex_stage3": return "stage3"
		"ex_stage4": return "stage4"
	return GameState.current_stage

func _get_boss_def_path() -> String:
	var effective := _get_effective_stage()
	match effective:
		"stage1": return KAO_YUME_DEF
		"stage2": return KAO_UTU_DEF
		"stage3", "stage4": return KAO_MABO_DEF
		_: return KAO_MABO_DEF

func _get_boss_phase_path() -> String:
	var effective := _get_effective_stage()
	var paths: Array
	match effective:
		"stage1": paths = [KAO_YUME_DEF,  KAO_YUME_DEF2,  KAO_YUME_DEF3]
		"stage2": paths = [KAO_UTU_DEF,   KAO_UTU_DEF2,   KAO_UTU_DEF3]
		_:        paths = [KAO_MABO_DEF,  KAO_MABO_DEF2,  KAO_MABO_DEF3]
	if current_question >= 7:
		return paths[2]
	elif current_question >= 3:
		return paths[1]
	else:
		return paths[0]

func _get_boss_wrong_path() -> String:
	var effective := _get_effective_stage()
	match effective:
		"stage1": return KAO_YUME_KATI
		"stage2": return KAO_UTU_KATI
		_: return KAO_MABO_KATI

func _play_correct_faces(revert: bool = true) -> void:
	var seikai_path: String = KAO_PYOKO_SEIKAI[randi() % KAO_PYOKO_SEIKAI.size()]
	_set_face($FaceMain, seikai_path)
	if revert:
		await get_tree().create_timer(SEIKAI_FLASH_DURATION).timeout
		_set_face($FaceMain, KAO_PYOKO_DEF)
	_set_face($FaceBoss, _get_boss_phase_path())

func _play_wrong_faces() -> void:
	var make_path: String = KAO_PYOKO_MAKE[randi() % KAO_PYOKO_MAKE.size()]
	_set_face($FaceMain, make_path)
	_set_face($FaceBoss, _get_boss_wrong_path())

# ============================================================
# 背景ロード
# ============================================================
func _load_stage_bg() -> void:
	var path := _get_bg_path()
	if path != "" and ResourceLoader.exists(path):
		$BG.texture = load(path)

func _get_bg_path() -> String:
	if GameState.current_stage == "endless":
		match GameState.endless_block:
			0: return "res://assets/bg/bg_yume.webp"
			1: return "res://assets/bg/bg_ututu.webp"
			2: return "res://assets/bg/bg_maboro.webp"
			3: return "res://assets/bg/bg_maboro2.webp"
			4: return "res://assets/bg/bg_yumeex.webp"
			5: return "res://assets/bg/bg_ututuex.webp"
			6: return "res://assets/bg/bg_maboroex.webp"
			_: return "res://assets/bg/bg_maboroex2.webp"
	match GameState.current_stage:
		"tutorial", "stage1": return "res://assets/bg/bg_yume.webp"
		"stage2":              return "res://assets/bg/bg_ututu.webp"
		"stage3":              return "res://assets/bg/bg_maboro.webp"
		"stage4":              return "res://assets/bg/bg_maboro2.webp"
		"ex_stage1":           return "res://assets/bg/bg_yumeex.webp"
		"ex_stage2":           return "res://assets/bg/bg_ututuex.webp"
		"ex_stage3":           return "res://assets/bg/bg_maboroex.webp"
		"ex_stage4":           return "res://assets/bg/bg_maboroex2.webp"
	if GameState.current_stage == "custom":
		match SaveData.custom_difficulty:
			"stage1": return "res://assets/bg/bg_yume.webp"
			"stage2": return "res://assets/bg/bg_ututu.webp"
			"stage3": return "res://assets/bg/bg_maboro.webp"
			"stage4": return "res://assets/bg/bg_maboro2.webp"
	return ""

# ============================================================
# BGM
# ============================================================
func get_custom_bgm_list() -> Array:
	var list: Array = []
	if SaveData.custom_bgm_yume:
		list.append_array(["bgm_yume_jantou"])
	if SaveData.custom_bgm_utu:
		list.append_array(["bgm_utu_higakureru", "bgm_utu_kotaewo", "bgm_utu_syogakusei", "bgm_utu_matigai"])
	if SaveData.custom_bgm_mabo_first:
		list.append_array(["bgm_mabo_first_2tunoboketu", "bgm_mabo_first_appaku"])
	if SaveData.custom_bgm_mabo_second:
		list.append_array(["bgm_mabo_second_kougetu", "bgm_mabo_mugen"])
	if list.is_empty():
		list = ["bgm_yume_jantou"]
	return list

func play_stage_bgm() -> void:
	if GameState.current_stage == "endless":
		var idx: int = min(GameState.endless_block, ENDLESS_BGM.size() - 1)
		current_bgm_filename = ENDLESS_BGM[idx]
		AudioManager.play_bgm(current_bgm_filename)
		SaveData.unlock_bgm(current_bgm_filename)
		return
	if GameState.current_stage == "custom":
		var list: Array = get_custom_bgm_list()
		current_bgm_filename = list[randi() % list.size()]
		AudioManager.play_bgm_once(current_bgm_filename)
		SaveData.unlock_bgm(current_bgm_filename)
		if not _custom_bgm_connected:
			AudioManager.bgm_player.finished.connect(_on_custom_bgm_finished)
			_custom_bgm_connected = true
		return
	if not bgm_list.has(GameState.current_stage):
		return
	var list: Array = bgm_list[GameState.current_stage]
	current_bgm_filename = list[randi() % list.size()]
	AudioManager.play_bgm(current_bgm_filename)
	SaveData.unlock_bgm(current_bgm_filename)

func _on_custom_bgm_finished() -> void:
	if GameState.current_stage != "custom":
		return
	if AudioManager.bgm_player.playing:
		return
	var list: Array = get_custom_bgm_list()
	current_bgm_filename = list[randi() % list.size()]
	AudioManager.play_bgm_once(current_bgm_filename)
	SaveData.unlock_bgm(current_bgm_filename)

# ============================================================
# イントロ
# ============================================================
func get_intro_stage_name() -> String:
	if GameState.current_stage == "endless":
		var idx: int = min(GameState.endless_block, ENDLESS_BLOCK_NAMES.size() - 1)
		return ENDLESS_BLOCK_NAMES[idx]
	if GameState.current_stage == "custom":
		match SaveData.custom_difficulty:
			"stage1": return "Easy"
			"stage2": return "Normal"
			"stage3": return "Hard"
			"stage4": return "Mirage"
	return stage_display_names.get(GameState.current_stage, "")

func play_intro() -> void:
	var panel = $StageIntro/IntroPanel
	var stage_label = $StageIntro/IntroPanel/StageName
	var bgm_label = $StageIntro/IntroPanel/BgmName

	stage_label.text = "難易度　" + get_intro_stage_name()
	bgm_label.text = "♪ " + bgm_display_names.get(current_bgm_filename, "")

	panel.color = Color(0, 0, 0, 0.4)
	panel.modulate.a = 1.0
	panel.visible = true

	await get_tree().create_timer(3.0).timeout

	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	await tween.finished

	panel.visible = false
	await slide_hand_in()

# ============================================================
# タイマー
# ============================================================
func _process(delta: float) -> void:
	if not timer_running:
		return
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		update_timer_display()
		on_time_up()
	else:
		update_timer_display()

func start_timer() -> void:
	time_left = time_limit
	timer_running = true
	update_timer_display()

func stop_timer() -> void:
	timer_running = false

func setup_timer_display() -> void:
	$TimerLabel.visible = timer_enabled

func update_timer_display() -> void:
	if not timer_enabled:
		return
	$TimerLabel.text = "残り：%.1f秒" % time_left

func on_time_up() -> void:
	stop_timer()
	_play_wrong_faces()
	AudioManager.stop_bgm()
	AudioManager.play_bgm("bgm_gameover_mou")
	AudioManager.play_se("se_gameover")
	popup_state = "wrong"
	_setup_popup_buttons(popup_state)
	$PopupResult.visible = true
	_show_correct_tiles(correct_tiles)
	_play_gameover_animation()

# ============================================================
# デバッグ
# ============================================================
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		GameState.debug_mode = not GameState.debug_mode
		update_debug_display()
		print("デバッグモード: ", GameState.debug_mode)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F5:
		# 4枚使い切りデバッグ用：1122333345789（正解1236、3は使い切り）
		current_hand = [1, 1, 2, 2, 3, 3, 3, 3, 4, 5, 7, 8, 9]
		correct_tiles = MahjongLogic.find_waiting_tiles(current_hand)
		display_hand(current_hand)
		update_debug_display()
		print("【デバッグ】強制手牌: ", current_hand, " 正解: ", correct_tiles)

func update_debug_display() -> void:
	if GameState.debug_mode:
		$DebugLabel.visible = true
		if correct_tiles.is_empty():
			$DebugLabel.text = "正解：待ちなし"
		else:
			$DebugLabel.text = "正解：" + str(correct_tiles)
	else:
		$DebugLabel.visible = false

# ============================================================
# ステージ設定
# ============================================================
func get_hand_size_for_stage(stage_name: String) -> int:
	if stage_name == "endless":
		return _get_endless_hand_size()
	if stage_name == "custom":
		match SaveData.custom_difficulty:
			"stage1": return 7
			"stage2": return 10
			_: return 13
	match stage_name:
		"tutorial", "stage1", "ex_stage1": return 7
		"stage2", "ex_stage2":             return 10
		_:                                 return 13

func _get_endless_hand_size() -> int:
	match GameState.endless_block:
		0: return 7
		1: return 10
		2: return 13
		3: return 13
		4: return 7
		5: return 10
		_: return 13

# ============================================================
# 問題生成
# ============================================================
func load_new_question() -> void:
	var sort_hand: bool
	var use_tenpai_only: bool

	if GameState.current_stage == "endless":
		match GameState.endless_block:
			0: sort_hand = true;  use_tenpai_only = true
			1: sort_hand = true;  use_tenpai_only = true
			2: sort_hand = true;  use_tenpai_only = true
			3: sort_hand = false; use_tenpai_only = true
			4: sort_hand = false; use_tenpai_only = true
			5: sort_hand = false; use_tenpai_only = true
			6: sort_hand = true;  use_tenpai_only = false
			7: sort_hand = false; use_tenpai_only = false
			_: sort_hand = false; use_tenpai_only = false
	elif GameState.current_stage.begins_with("ex_"):
		match GameState.current_stage:
			"ex_stage1": sort_hand = false; use_tenpai_only = true
			"ex_stage2": sort_hand = false; use_tenpai_only = true
			"ex_stage3": sort_hand = true;  use_tenpai_only = false
			"ex_stage4": sort_hand = false; use_tenpai_only = false
			_:           sort_hand = false; use_tenpai_only = false
	else:
		var effective_stage := GameState.current_stage
		if GameState.current_stage == "custom":
			effective_stage = SaveData.custom_difficulty
		if GameState.current_stage == "custom":
			sort_hand = SaveData.custom_sort_enabled
		else:
			sort_hand = (effective_stage != "stage4")
		use_tenpai_only = true

	var hand: Array
	if use_tenpai_only:
		hand = MahjongLogic.generate_tenpai_hand(hand_size, 1000, sort_hand)
	else:
		hand = MahjongLogic.generate_hand(hand_size, sort_hand)

	correct_tiles = MahjongLogic.find_waiting_tiles(hand)
	current_hand = hand
	display_hand(hand)
	update_debug_display()

func update_question_counter() -> void:
	if GameState.current_stage == "endless":
		var total := GameState.endless_total_question + current_question + 1
		if total <= 80:
			$QuestionCounter.text = str(total) + " / 80"
		else:
			$QuestionCounter.text = str(total) + " / ∞"
	elif GameState.current_stage == "custom" and SaveData.custom_question_count == -1:
		$QuestionCounter.text = str(current_question + 1) + " / ∞"
	else:
		$QuestionCounter.text = str(current_question + 1) + " / " + str(total_questions)

# ============================================================
# 入力処理
# ============================================================
func _on_number_pressed(number: int) -> void:
	if is_animating:
		return
	if number in selected_tiles:
		return
	AudioManager.play_se("se_tailetap")
	selected_tiles.append(number)
	selected_tiles.sort()
	update_ui()

func _on_none_pressed() -> void:
	if is_animating:
		return
	AudioManager.play_se("se_tailetap")
	selected_tiles = [-1]
	update_ui()

func _on_clear_pressed() -> void:
	if is_animating:
		return
	AudioManager.play_se("se_tailetap")
	selected_tiles = []
	update_ui()

# ============================================================
# 手牌で4枚使い切っている牌のリストを返す
# ============================================================
func _get_exhausted_tiles() -> Array:
	var count: Dictionary = {}
	for tile in current_hand:
		count[tile] = count.get(tile, 0) + 1
	var exhausted: Array = []
	for tile in count:
		if count[tile] >= 4:
			exhausted.append(tile)
	return exhausted

# ============================================================
# 提出・正誤判定
# ============================================================
func _on_submit_pressed() -> void:
	if is_animating:
		return

	AudioManager.play_se("se_btntap")
	stop_timer()

	var exhausted := _get_exhausted_tiles()
	var effective_correct: Array = correct_tiles.filter(func(t): return not (t in exhausted))
	effective_correct.sort()

	var is_correct = false
	if selected_tiles[0] == -1:
		# 「なし」は、正解が空 または 使い切り牌を除いた正解が空なら正解
		is_correct = correct_tiles.is_empty() or effective_correct.is_empty()
	else:
		var sorted_selected = selected_tiles.duplicate()
		var sorted_correct = correct_tiles.duplicate()
		sorted_selected.sort()
		sorted_correct.sort()
		# 完全一致（使い切り牌込みの正解）でも、使い切り牌を除いた正解でも正解
		is_correct = (sorted_selected == sorted_correct) or (sorted_selected == effective_correct)

	if is_correct:
		current_question += 1

		if current_question >= total_questions:
			if GameState.current_stage == "endless":
				_on_endless_block_clear()
				return

			if GameState.current_stage == "stage3":
				SaveData.record_clear("stage3")
				GameState.came_from_stage3 = true
				GameState.current_stage = "stage4"
				get_tree().change_scene_to_file("res://Game.tscn")

			elif GameState.current_stage == "stage4":
				_newly_unlocked_stage = SaveData.record_clear("stage4")
				_play_correct_faces(false)
				AudioManager.stop_bgm()
				AudioManager.play_se("se_clear")
				popup_state = "clear"
				_setup_popup_buttons(popup_state)
				$PopupResult/PopupPanel/ResultLabel.text = "真のクリア\nおめでとう"
				$PopupResult.visible = true

			elif GameState.current_stage == "ex_stage3":
				SaveData.record_clear("ex_stage3")
				GameState.current_stage = "ex_stage4"
				get_tree().change_scene_to_file("res://Game.tscn")

			elif GameState.current_stage == "ex_stage4":
				_newly_unlocked_stage = SaveData.record_clear("ex_stage4")
				_play_correct_faces(false)
				AudioManager.stop_bgm()
				AudioManager.play_se("se_clear")
				popup_state = "clear"
				_setup_popup_buttons(popup_state)
				$PopupResult/PopupPanel/ResultLabel.text = "真のクリア\nおめでとう"
				$PopupResult.visible = true

			elif GameState.current_stage == "custom":
				_play_correct_faces(false)
				AudioManager.stop_bgm()
				AudioManager.play_se("se_clear")
				popup_state = "clear"
				_setup_popup_buttons(popup_state)
				$PopupResult/PopupPanel/ResultLabel.text = "クリア\nおめでとう"
				$PopupResult.visible = true

			else:
				_newly_unlocked_stage = SaveData.record_clear(GameState.current_stage)
				_play_correct_faces(false)
				AudioManager.stop_bgm()
				AudioManager.play_se("se_clear")
				popup_state = "clear"
				_setup_popup_buttons(popup_state)
				$PopupResult/PopupPanel/ResultLabel.text = "クリア\nおめでとう"
				$PopupResult.visible = true
		else:
			popup_state = "correct"
			_setup_popup_buttons(popup_state)
			play_correct_sequence()
	else:
		_play_wrong_faces()
		AudioManager.stop_bgm()
		AudioManager.play_bgm("bgm_gameover_mou")
		AudioManager.play_se("se_gameover")
		popup_state = "wrong"
		_setup_popup_buttons(popup_state)
		$PopupResult.visible = true
		_show_correct_tiles(correct_tiles)
		_play_gameover_animation()

# ============================================================
# endlessブロッククリア処理
# ============================================================
func _on_endless_block_clear() -> void:
	GameState.endless_total_question += total_questions
	GameState.endless_block += 1

	# block 9 以降はEndlessループ継続。シーン再読み込み・難易度表示なし
	if GameState.endless_block >= 9:
		current_question = 0
		popup_state = "correct"
		_setup_popup_buttons(popup_state)
		play_correct_sequence()
		return

	get_tree().change_scene_to_file("res://Game.tscn")

# ============================================================
# 正解演出シーケンス
# ============================================================
func play_correct_sequence() -> void:
	is_animating = true
	selected_tiles = []
	update_ui()

	AudioManager.play_se("se_seikai")
	$PopupResult/PopupPanel/ResultLabel.text = "正解！"
	$PopupResult.visible = true

	_play_correct_faces()

	await get_tree().create_timer(1.0).timeout

	$PopupResult.visible = false
	await slide_hand_out()
	load_new_question()
	update_question_counter()
	await slide_hand_in()

	is_animating = false

	if timer_enabled:
		start_timer()

# ============================================================
# 手牌アニメーション
# ============================================================
func slide_hand_out() -> void:
	var hand_area = $HandArea
	var start_x = hand_area.position.x
	var end_x = start_x - get_viewport_rect().size.x
	var tween = create_tween()
	tween.tween_property(hand_area, "position:x", end_x, 0.3)
	await tween.finished
	hand_area.position.x = start_x

func slide_hand_in() -> void:
	var hand_area = $HandArea
	var home_x = 0.0
	var start_x = home_x + get_viewport_rect().size.x
	hand_area.position.x = start_x
	hand_area.visible = true
	var tween = create_tween()
	tween.tween_property(hand_area, "position:x", home_x, 0.3)
	await tween.finished

# ============================================================
# UI更新
# ============================================================
func update_ui() -> void:
	if selected_tiles.is_empty():
		$SelectedPanel.text = "選択中："
	elif selected_tiles[0] == -1:
		$SelectedPanel.text = "選択中：なし"
	else:
		$SelectedPanel.text = "選択中：" + str(selected_tiles)

	$Keypad/BtnSubmit.disabled = selected_tiles.is_empty()

	var has_number = not selected_tiles.is_empty() and selected_tiles[0] != -1
	$Keypad/BtnNone.disabled = has_number

	var has_none = not selected_tiles.is_empty() and selected_tiles[0] == -1
	for i in range(1, 10):
		var btn = $Keypad.get_node("Btn" + str(i))
		btn.disabled = has_none
		if i in selected_tiles:
			btn.modulate = Color(1.8, 1.4, 0.6)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)

# ============================================================
# 手牌表示
# ============================================================
func display_hand(hand: Array) -> void:
	for child in $HandArea/TileBoxRow1.get_children():
		child.queue_free()
	for child in $HandArea/TileBoxRow2.get_children():
		child.queue_free()

	var effective_stage := _get_effective_stage()
	var is_late_stage = (effective_stage == "stage3" or effective_stage == "stage4")
	var two_row = is_late_stage and GameState.two_row_layout
	var small_size = is_late_stage and not GameState.two_row_layout

	var tile_w: int
	var tile_h: int
	if small_size:
		tile_w = TILE_W_SMALL
		tile_h = TILE_H_SMALL
	elif effective_stage == "stage2":
		tile_w = TILE_W_MID
		tile_h = TILE_H_MID
	else:
		tile_w = TILE_W
		tile_h = TILE_H

	if two_row:
		var split_point = (hand.size() + 1) / 2
		$HandArea/TileBoxRow2.visible = true
		for i in range(hand.size()):
			var tile = hand[i]
			var rect = make_tile_image(tile, tile_w, tile_h)
			if i < split_point:
				$HandArea/TileBoxRow1.add_child(rect)
			else:
				$HandArea/TileBoxRow2.add_child(rect)
	else:
		$HandArea/TileBoxRow2.visible = false
		for tile in hand:
			var rect = make_tile_image(tile, tile_w, tile_h)
			$HandArea/TileBoxRow1.add_child(rect)

func make_tile_image(tile: int, w: int, h: int) -> TextureRect:
	var rect = TextureRect.new()
	rect.texture = tile_textures[tile - 1]
	rect.custom_minimum_size = Vector2(w, h)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	print("牌サイズ: w=", w, " h=", h)
	return rect

# ============================================================
# 「もう一度」ボタン
# ============================================================
func _on_btn_retry_pressed() -> void:
	$PopupResult.visible = false
	selected_tiles = []

	if GameState.current_stage == "ex_stage4":
		if popup_state == "wrong":
			GameState.current_stage = "ex_stage3"
		get_tree().change_scene_to_file("res://Game.tscn")
		return

	if popup_state == "clear":
		if GameState.current_stage == "endless":
			GameState.endless_block = 0
			GameState.endless_total_question = 0
			get_tree().change_scene_to_file("res://Game.tscn")
			return
		current_question = 0
		_newly_unlocked_stage = ""
		load_new_question()
		play_stage_bgm()
		update_question_counter()
		update_ui()
		_set_face($FaceMain, KAO_PYOKO_DEF)
		_set_face($FaceBoss, _get_boss_def_path())
		$HandArea.visible = false
		await play_intro()
		if timer_enabled:
			start_timer()
		return

	if GameState.current_stage == "endless":
		GameState.endless_block = 0
		GameState.endless_total_question = 0
		get_tree().change_scene_to_file("res://Game.tscn")
		return

	if GameState.current_stage == "stage4":
		GameState.came_from_stage3 = false
		GameState.current_stage = "stage3"
		get_tree().change_scene_to_file("res://Game.tscn")
		return

	current_question = 0
	load_new_question()
	play_stage_bgm()
	update_question_counter()
	update_ui()
	_set_face($FaceMain, KAO_PYOKO_DEF)
	_set_face($FaceBoss, _get_boss_def_path())
	$HandArea.visible = false
	await play_intro()
	if timer_enabled:
		start_timer()

# ============================================================
# 「ホーム」ボタン
# ============================================================
func _on_popup_btn_home_pressed() -> void:
	$PopupResult.visible = false

	# いきなりゲームモードのゲームオーバー→タイトルへ
	if GameState.is_instant_mode and popup_state == "wrong":
		GameState.is_instant_mode = false
		get_tree().change_scene_to_file("res://Title.tscn")
		return

	if popup_state == "clear" and GameState.current_stage != "custom" and GameState.current_stage != "endless" and _newly_unlocked_stage != "":
		_show_unlock_popup(_newly_unlocked_stage)
	else:
		if GameState.current_stage.begins_with("ex_") or GameState.current_stage == "endless":
			GameState.came_from_ex = true
		get_tree().change_scene_to_file("res://StageSelect.tscn")

# ============================================================
# 解放ポップアップ
# ============================================================
func _show_unlock_popup(stage_name: String) -> void:
	var message = ""
	match stage_name:
		"stage2":    message = "難易度 Normal が解放された！"
		"stage3":    message = "難易度 Hard が解放された！"
		"custom":    message = "EXモード と カスタムが解放された！"
		"ex_stage2": message = "難易度 Trivial が解放された！"
		"ex_stage3": message = "難易度 Adequate が解放された！"
		"ex_stage4": message = "Endless と 音楽室 が解放された！"
	$UnlockPopup/UnlockVBox/UnlockLabel.text = message
	AudioManager.play_se("se_fanfa")
	$UnlockPopup.visible = true

func _on_btn_unlock_ok_pressed() -> void:
	$UnlockPopup.visible = false
	if GameState.current_stage.begins_with("ex_"):
		GameState.came_from_ex = true
	get_tree().change_scene_to_file("res://StageSelect.tscn")

# ============================================================
# レイアウト切り替え
# ============================================================
func _on_btn_layout_pressed() -> void:
	var effective_stage := _get_effective_stage()
	if effective_stage != "stage3" and effective_stage != "stage4":
		print("レイアウト切り替えはHard・Mirage相当難易度でのみ使えます")
		return
	GameState.two_row_layout = not GameState.two_row_layout
	display_hand(current_hand)

# ============================================================
# 設定ボタン
# ============================================================
func _on_btn_settings_pressed() -> void:
	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume
	$SettingsPopup.visible = true

func _on_bgm_slider_changed(value: float) -> void:
	AudioManager.bgm_volume = value
	AudioManager.bgm_player.volume_db = linear_to_db(value)

func _on_se_slider_changed(value: float) -> void:
	AudioManager.se_volume = value

func _on_btn_settings_close_pressed() -> void:
	$SettingsPopup.visible = false

# ============================================================
# TopBarのホームボタン
# ============================================================
func _on_btn_home_pressed() -> void:
	stop_timer()
	$HomeConfirmPopup.visible = true

func _on_btn_confirm_yes_pressed() -> void:
	GameState.came_from_stage3 = false
	if GameState.is_instant_mode:
		GameState.is_instant_mode = false
		get_tree().change_scene_to_file("res://Title.tscn")
		return
	if GameState.current_stage.begins_with("ex_") or GameState.current_stage == "endless":
		GameState.came_from_ex = true
	get_tree().change_scene_to_file("res://StageSelect.tscn")

func _on_btn_confirm_no_pressed() -> void:
	$HomeConfirmPopup.visible = false
	if timer_enabled and not $PopupResult.visible and not is_animating:
		timer_running = true
