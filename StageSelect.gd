extends Control

@onready var slide_container: Control        = $SlideContainer
@onready var chara_pyoko: TextureRect        = $SlideContainer/CharaPyoko
@onready var chara_ex: TextureRect           = $SlideContainer/CharaEX
@onready var surface_stage_area: Control     = $SlideContainer/SurfaceStageArea
@onready var ex_stage_area: Control          = $SlideContainer/EXStageArea
@onready var surface_select_img: TextureRect = $SlideContainer/SurfaceSelectImg
@onready var ex_select_img: TextureRect      = $SlideContainer/EXSelectImg

const PATH_BG_SURFACE     := "res://assets/bg/bg_sentaku.webp"
const PATH_BG_EX          := "res://assets/bg/bg_exsentaku.webp"
const PATH_PYOKO          := "res://assets/chara/pyoko2.webp"
const PATH_STAGE_SELECT   := "res://assets/bg/StageSelect.webp"
const PATH_EX_SELECT      := "res://assets/bg/exmode2.webp"
const PATH_WAKU           := "res://assets/bg/stagewaku.webp"
const PATH_GAME_BTN       := "res://assets/bg/game.webp"
const PATH_EX_BTN         := "res://assets/bg/EX.webp"
const PATH_TUJO_BTN       := "res://assets/kao/kao_pyoko_def.webp"
const PATH_KI             := "res://assets/bg/tetu.webp"
const PATH_MIKAI          := "res://assets/bg/mikai2.webp"
const PATH_ICON_SETTINGS  := "res://assets/bg/icon_settei.webp"
const PATH_ICON_HOME      := "res://assets/bg/icon_home.webp"

const ROW_H:         float = 70.0
const ROW_GAP:       float = 15.0
const WAKU_W:        float = 208.0
const GAME_W:        float = 48.0
const WAKU_GAME_GAP: float = 4.0

const SURFACE_STAGES: Array = ["tutorial", "stage1", "stage2", "stage3", "custom"]
const SURFACE_NAME_IMAGES: Array = [
	"res://assets/bg/tutorial.webp",
	"res://assets/bg/easy.webp",
	"res://assets/bg/normal.webp",
	"res://assets/bg/hard.webp",
	"res://assets/bg/custom.webp",
]
const SURFACE_ALWAYS_UNLOCKED: Array = ["tutorial", "stage1"]

const EX_STAGES: Array = ["ex_stage1", "ex_stage2", "ex_stage3", "endless", "music_room"]
const EX_NAME_IMAGES: Array = [
	"res://assets/bg/tooeasy.webp",
	"res://assets/bg/Trivial.webp",
	"res://assets/bg/Adequate.webp",
	"res://assets/bg/Endless.webp",
	"res://assets/bg/MusicRoom.webp",
]

const NO_GAME_BTN_STAGES: Array = ["custom", "endless", "music_room"]

var _surface_rows: Dictionary = {}
var _ex_rows: Dictionary = {}
var _is_sliding: bool = false

# ============================================================
# 初期化
# ============================================================
func _ready() -> void:
	AudioManager.play_bgm("bgm_t_sentaku")
	_load_backgrounds()
	_setup_select_images()
	_setup_pyoko()
	_setup_chara_ex()
	_setup_side_change_buttons()
	_setup_settings_home_icons()
	_build_surface_buttons()
	_build_ex_buttons()
	_update_lock_display()

	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume

	var show_ex: bool = GameState.came_from_ex or SaveData.last_mode == "ex"
	GameState.came_from_ex = false
	if show_ex:
		slide_container.position.x = -480.0

func _load_backgrounds() -> void:
	if ResourceLoader.exists(PATH_BG_SURFACE):
		$SlideContainer/SurfaceBG.texture = load(PATH_BG_SURFACE)
	if ResourceLoader.exists(PATH_BG_EX):
		$SlideContainer/EXBG.texture = load(PATH_BG_EX)

func _setup_select_images() -> void:
	if ResourceLoader.exists(PATH_STAGE_SELECT):
		surface_select_img.texture = load(PATH_STAGE_SELECT)
	if ResourceLoader.exists(PATH_EX_SELECT):
		ex_select_img.texture = load(PATH_EX_SELECT)

func _setup_pyoko() -> void:
	if ResourceLoader.exists(PATH_PYOKO):
		chara_pyoko.texture = load(PATH_PYOKO)
	var screen := get_viewport_rect().size
	var h: float = screen.y * 0.67
	var w: float = h * 0.5
	chara_pyoko.size     = Vector2(w, h)
	chara_pyoko.flip_h   = true
	chara_pyoko.position = Vector2(screen.x - w + 50.0, screen.y - h)

func _setup_chara_ex() -> void:
	chara_ex.texture = null
	var screen := get_viewport_rect().size
	var h: float = screen.y * 0.67
	var w: float = h * 0.5
	chara_ex.size     = Vector2(w, h)
	chara_ex.position = Vector2(480.0 + 10.0, screen.y - h)

func _setup_side_change_buttons() -> void:
	var btn_ex   := $SlideContainer/BtnSideChange
	var btn_tujo := $SlideContainer/BtnSideChangeBack
	btn_ex.text   = ""
	btn_tujo.text = ""
	btn_ex.flat   = true
	btn_tujo.flat = true
	if ResourceLoader.exists(PATH_EX_BTN):
		btn_ex.icon = load(PATH_EX_BTN)
	if ResourceLoader.exists(PATH_TUJO_BTN):
		btn_tujo.icon = load(PATH_TUJO_BTN)
	btn_ex.expand_icon      = true
	btn_tujo.expand_icon    = true
	btn_ex.icon_alignment   = HORIZONTAL_ALIGNMENT_CENTER
	btn_tujo.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

# ============================================================
# 設定・ホームボタンのアイコン設定
# ============================================================
func _setup_settings_home_icons() -> void:
	var btn_settings := $BtnSettings
	var btn_home     := $BtnHome
	btn_settings.text = ""
	btn_home.text     = ""
	btn_settings.flat = true
	btn_home.flat     = true
	if ResourceLoader.exists(PATH_ICON_SETTINGS):
		btn_settings.icon = load(PATH_ICON_SETTINGS)
	if ResourceLoader.exists(PATH_ICON_HOME):
		btn_home.icon = load(PATH_ICON_HOME)
	btn_settings.expand_icon      = true
	btn_home.expand_icon          = true
	btn_settings.icon_alignment   = HORIZONTAL_ALIGNMENT_CENTER
	btn_home.icon_alignment       = HORIZONTAL_ALIGNMENT_CENTER

# ============================================================
# ステージボタンの動的生成
# ============================================================
func _build_surface_buttons() -> void:
	for i in range(SURFACE_STAGES.size()):
		var stage: String = SURFACE_STAGES[i]
		var y: float = i * (ROW_H + ROW_GAP)
		var show_game: bool = not (stage in NO_GAME_BTN_STAGES)
		var row_data := _create_stage_row(surface_stage_area, 0.0, y, SURFACE_NAME_IMAGES[i], false, show_game)
		row_data["story_btn"].pressed.connect(_on_story_btn_pressed.bind(stage))
		if show_game:
			row_data["game_btn"].pressed.connect(_on_game_btn_pressed.bind(stage))
		_surface_rows[stage] = row_data

func _build_ex_buttons() -> void:
	for i in range(EX_STAGES.size()):
		var stage: String = EX_STAGES[i]
		var y: float = i * (ROW_H + ROW_GAP)
		var show_game: bool = not (stage in NO_GAME_BTN_STAGES)
		var row_data := _create_stage_row(ex_stage_area, 0.0, y, EX_NAME_IMAGES[i], true, show_game)
		row_data["story_btn"].pressed.connect(_on_story_btn_pressed.bind(stage))
		if show_game:
			row_data["game_btn"].pressed.connect(_on_game_btn_pressed.bind(stage))
		_ex_rows[stage] = row_data

func _create_stage_row(parent: Control, lx: float, ly: float,
		name_img_path: String, is_ex: bool, show_game_btn: bool) -> Dictionary:
	var row := Control.new()
	row.position = Vector2(lx, ly)
	row.size = Vector2(WAKU_W + WAKU_GAME_GAP + GAME_W, ROW_H)
	parent.add_child(row)

	var waku_x: float
	var game_x: float
	var actual_waku_w: float

	if show_game_btn:
		waku_x = GAME_W + WAKU_GAME_GAP if is_ex else 0.0
		game_x = 0.0 if is_ex else WAKU_W + WAKU_GAME_GAP
		actual_waku_w = WAKU_W
	else:
		waku_x = GAME_W + WAKU_GAME_GAP if is_ex else 0.0
		game_x = 0.0
		actual_waku_w = WAKU_W

	var waku := TextureRect.new()
	waku.position = Vector2(waku_x, 0.0)
	waku.size = Vector2(actual_waku_w, ROW_H)
	waku.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	waku.stretch_mode = TextureRect.STRETCH_SCALE
	if ResourceLoader.exists(PATH_WAKU):
		waku.texture = load(PATH_WAKU)
	row.add_child(waku)

	var name_img := TextureRect.new()
	name_img.position = Vector2(waku_x, 0.0)
	name_img.size = Vector2(actual_waku_w, ROW_H)
	name_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	name_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(name_img_path):
		name_img.texture = load(name_img_path)
	row.add_child(name_img)

	var story_btn := Button.new()
	story_btn.position = Vector2(waku_x, 0.0)
	story_btn.size = Vector2(actual_waku_w, ROW_H)
	story_btn.custom_minimum_size = Vector2(actual_waku_w, ROW_H)
	story_btn.flat = true
	story_btn.text = ""
	row.add_child(story_btn)

	var game_btn := Button.new()
	if show_game_btn:
		game_btn.position = Vector2(game_x, 0.0)
		game_btn.size = Vector2(GAME_W, ROW_H)
		game_btn.custom_minimum_size = Vector2(GAME_W, ROW_H)
		game_btn.flat = true
		game_btn.text = ""
		if ResourceLoader.exists(PATH_GAME_BTN):
			game_btn.icon = load(PATH_GAME_BTN)
		game_btn.expand_icon = true
		row.add_child(game_btn)

	var mask := Control.new()
	mask.position = Vector2(0.0, 0.0)
	mask.size = Vector2(WAKU_W + WAKU_GAME_GAP + GAME_W, ROW_H)
	mask.visible = false

	var ki_h: float = 60.0
	var ki_w: float = 260.0
	var ki_y: float = (ROW_H - ki_h) / 2.0
	var ki := TextureRect.new()
	ki.position = Vector2(0.0, ki_y)
	ki.size = Vector2(ki_w, ki_h)
	ki.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ki.stretch_mode = TextureRect.STRETCH_SCALE
	if ResourceLoader.exists(PATH_KI):
		ki.texture = load(PATH_KI)
	mask.add_child(ki)

	var mikai_w: float = (WAKU_W + WAKU_GAME_GAP + GAME_W) * 0.7
	var mikai_h: float = 120.0
	var mikai_x: float = ((WAKU_W + WAKU_GAME_GAP + GAME_W) - mikai_w) / 2.0
	var mikai_y: float = (ROW_H - mikai_h) / 2.0
	var mikai := TextureRect.new()
	mikai.position = Vector2(mikai_x, mikai_y)
	mikai.size = Vector2(mikai_w, mikai_h)
	mikai.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mikai.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(PATH_MIKAI):
		mikai.texture = load(PATH_MIKAI)
	mask.add_child(mikai)

	row.add_child(mask)

	return {"story_btn": story_btn, "game_btn": game_btn, "mask": mask, "row": row}

# ============================================================
# 解放状態の更新
# ============================================================
func _update_lock_display() -> void:
	for stage in SURFACE_STAGES:
		if not _surface_rows.has(stage):
			continue
		var row_data: Dictionary = _surface_rows[stage]
		var locked: bool = not (stage in SURFACE_ALWAYS_UNLOCKED or SaveData.is_unlocked(stage))
		row_data["mask"].visible       = locked
		row_data["story_btn"].disabled = locked
		if row_data["game_btn"] != null and row_data["game_btn"].is_inside_tree():
			row_data["game_btn"].disabled = locked

	var ex_accessible: bool = SaveData.is_unlocked("ex_stage1")
	$SlideContainer/BtnSideChange.visible = ex_accessible

	for stage in EX_STAGES:
		if not _ex_rows.has(stage):
			continue
		var row_data: Dictionary = _ex_rows[stage]
		var locked: bool = not SaveData.is_unlocked(stage)
		row_data["mask"].visible       = locked
		row_data["story_btn"].disabled = locked
		if row_data["game_btn"] != null and row_data["game_btn"].is_inside_tree():
			row_data["game_btn"].disabled = locked

# ============================================================
# デバッグ
# ============================================================
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		SaveData.unlock_stage("stage2")
		SaveData.unlock_stage("stage3")
		SaveData.unlock_stage("custom")
		SaveData.unlock_stage("music_room")
		SaveData.unlock_stage("ex_stage1")
		SaveData.unlock_stage("ex_stage2")
		SaveData.unlock_stage("ex_stage3")
		SaveData.unlock_stage("endless")
		_update_lock_display()
		print("【デバッグ】全ステージ解放")
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		SaveData.reset()
		_update_lock_display()
		print("【デバッグ】セーブデータ初期化")
	if event is InputEventKey and event.pressed and event.keycode == KEY_F4:
		SaveData.unlock_bgm("bgm_yume_main")
		SaveData.unlock_bgm("bgm_yume_jantou")
		SaveData.unlock_bgm("bgm_yume_barabara")
		SaveData.unlock_bgm("bgm_utu_higakureru")
		SaveData.unlock_bgm("bgm_utu_zakozako")
		SaveData.unlock_bgm("bgm_utu_matigai")
		SaveData.unlock_bgm("bgm_utu_nochan")
		SaveData.unlock_bgm("bgm_utu_kotaewo")
		SaveData.unlock_bgm("bgm_utu_syogakusei")
		SaveData.unlock_bgm("bgm_mabo_first_2tunoboketu")
		SaveData.unlock_bgm("bgm_mabo_first_appaku")
		SaveData.unlock_bgm("bgm_mabo_first_nebumi")
		SaveData.unlock_bgm("bgm_mabo_second_kougetu")
		SaveData.unlock_bgm("bgm_mabo_second_ginniro")
		SaveData.unlock_bgm("bgm_mabo_second_inisie")
		SaveData.unlock_bgm("bgm_mabo_mugen")
		SaveData.unlock_bgm("bgm_gameover_mou")
		SaveData.unlock_bgm("bgm_t_sentaku")
		SaveData.unlock_bgm("bgm_t_title")
		print("【デバッグ】全BGM解放")

# ============================================================
# スライド演出
# ============================================================
func _slide_to_ex() -> void:
	if _is_sliding:
		return
	_is_sliding = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(slide_container, "position:x", -480.0, 0.4)
	await tween.finished
	_is_sliding = false

func _slide_to_surface() -> void:
	if _is_sliding:
		return
	_is_sliding = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(slide_container, "position:x", 0.0, 0.4)
	await tween.finished
	_is_sliding = false

# ============================================================
# ボタン処理
# ============================================================
func _on_story_btn_pressed(stage: String) -> void:
	_start_stage(stage)

func _on_game_btn_pressed(stage: String) -> void:
	_start_stage(stage)

func _start_stage(stage: String) -> void:
	print("【デバッグ】_start_stage called: ", stage)
	if stage in SURFACE_STAGES:
		SaveData.last_mode = "surface"
	else:
		SaveData.last_mode = "ex"
	SaveData.save()

	match stage:
		"tutorial", "stage1", "stage2", "stage3":
			GameState.came_from_stage3 = false
			GameState.current_stage = stage
			get_tree().change_scene_to_file("res://Game.tscn")
		"custom":
			get_tree().change_scene_to_file("res://Custom.tscn")
		"ex_stage1", "ex_stage2", "ex_stage3":
			GameState.came_from_stage3 = false
			GameState.current_stage = stage
			get_tree().change_scene_to_file("res://Game.tscn")
		"endless":
			GameState.endless_block = 0
			GameState.endless_total_question = 0
			GameState.current_stage = "endless"
			get_tree().change_scene_to_file("res://Game.tscn")
		"music_room":
			print("【デバッグ】music_room scene change")
			get_tree().change_scene_to_file("res://MusicRoom.tscn")

func _on_btn_side_change_pressed() -> void:
	_slide_to_ex()

func _on_btn_side_change_back_pressed() -> void:
	_slide_to_surface()

func _on_btn_settings_pressed() -> void:
	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume
	$SettingsPopup.visible = true

func _on_btn_settings_close_pressed() -> void:
	$SettingsPopup.visible = false

func _on_bgm_slider_changed(value: float) -> void:
	AudioManager.bgm_volume = value
	AudioManager.bgm_player.volume_db = linear_to_db(value)

func _on_se_slider_changed(value: float) -> void:
	AudioManager.se_volume = value

func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Title.tscn")
