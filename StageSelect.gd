extends Control

const PopupSkin := preload("res://PopupSkin.gd")
const ButtonFeedback := preload("res://ButtonFeedback.gd")

@onready var slide_container: Control        = $SlideContainer
@onready var chara_pyoko: TextureRect        = $SlideContainer/CharaPyoko
@onready var chara_ex: TextureRect           = $SlideContainer/CharaEX
@onready var surface_stage_area: Control     = $SlideContainer/SurfaceStageArea
@onready var ex_stage_area: Control          = $SlideContainer/EXStageArea
@onready var surface_select_img: TextureRect = $SlideContainer/SurfaceSelectImg
@onready var ex_select_img: TextureRect      = $SlideContainer/EXSelectImg
@onready var side_change_button: Button      = $BtnSideChange

const PATH_BG_SURFACE     := "res://assets/bg/stage_bg_surface_refined.webp"
const PATH_BG_EX          := "res://assets/bg/stage_bg_ex_refined.webp"
const PATH_PYOKO          := "res://assets/chara/pyoko2.webp"
const PATH_STAGE_SELECT   := "res://assets/bg/menu_header_stage_select.webp"
const PATH_EX_SELECT      := "res://assets/bg/menu_header_ex_mode.webp"
const PATH_WAKU           := "res://assets/bg/stagewaku.webp"
const PATH_GAME_BTN       := "res://assets/bg/game.webp"
const PATH_EX_BTN         := "res://assets/bg/menu_btn_to_ex.webp"
const PATH_SURFACE_BTN    := "res://assets/bg/menu_btn_to_surface.webp"
const PATH_KI             := "res://assets/bg/tetu.webp"
const PATH_MIKAI          := "res://assets/bg/mikai2.webp"
const PATH_ICON_SETTINGS  := "res://assets/bg/music_icon_settings_ui.webp"
const PATH_ICON_HOME      := "res://assets/bg/music_icon_home_ui.webp"
const PATH_SUPPORT_BTN    := "res://assets/bg/menu_btn_support.webp"
const PATH_SCORE_PLATE    := "res://assets/bg/menu_score_plate.webp"
const LOCALIZED_STAGE_SELECT_DIR := "res://assets/language/normalized/%s/stage_select/"

const ROW_H:         float = 70.0
const EX_ROW_H:      float = 72.0
const SURFACE_ROW_H: float = 86.0
const ROW_GAP:       float = 16.0
const SURFACE_BUTTON_W: float = 270.0
const EX_BUTTON_W:      float = 252.0
const WAKU_W:        float = 208.0
const GAME_W:        float = 48.0
const WAKU_GAME_GAP: float = 4.0
const HIGH_SCORE_DIGITS: int = 7
const HIGH_SCORE_DIGIT_H: float = 24.0
const HIGH_SCORE_DIGIT_SLOT_W: float = 18.0
const HIGH_SCORE_BG_PAD_X: float = 12.0
const HIGH_SCORE_BG_PAD_Y: float = 8.0
const HIGH_SCORE_PLATE_SIZE: Vector2 = Vector2(154.0, 42.0)
const SURFACE_BUTTON_X: float = 28.0
const SURFACE_SCORE_X: float = 302.0
const EX_SCORE_X: float = 34.0
const EX_BUTTON_X: float = 202.0
const EX_BG_X: float = 481.0
const EX_SLIDE_X: float = -EX_BG_X
const PAGE_SIZE: Vector2 = Vector2(480.0, 854.0)
const SWIPE_MIN_X: float = 90.0
const SWIPE_MAX_Y: float = 96.0
const SWIPE_AXIS_RATIO: float = 1.35

const SURFACE_STAGES: Array = ["tutorial", "stage1", "stage2", "stage3", "custom"]
const SURFACE_NAME_IMAGES: Array = [
	"res://assets/bg/menu_btn_tutorial.webp",
	"res://assets/bg/menu_btn_easy.webp",
	"res://assets/bg/menu_btn_normal.webp",
	"res://assets/bg/menu_btn_hard.webp",
	"res://assets/bg/menu_btn_custom.webp",
]
const SURFACE_ALWAYS_UNLOCKED: Array = ["tutorial", "stage1"]

const EX_STAGES: Array = ["ex_stage1", "ex_stage2", "ex_stage3", "endless", "music_room"]
const EX_NAME_IMAGES: Array[String] = [
	"res://assets/bg/menu_btn_ex_too_easy.webp",
	"res://assets/bg/menu_btn_ex_abnormal.webp",
	"res://assets/bg/menu_btn_ex_very_hard.webp",
	"res://assets/bg/menu_btn_ex_endless.webp",
	"res://assets/bg/menu_btn_ex_music_room.webp",
]

const NO_GAME_BTN_STAGES: Array = ["custom", "endless", "music_room"]
const STAGE_TALK_SCENE_IDS: Dictionary = {
	"tutorial": "tutorial_intro",
	"stage1": "stage1_intro",
	"stage2": "stage2_intro",
	"stage3": "stage3_intro",
	"ex_stage1": "ex_stage1_intro",
	"ex_stage2": "ex_stage2_intro",
	"ex_stage3": "ex_stage3_intro",
}

var _surface_rows: Dictionary = {}
var _ex_rows: Dictionary = {}
var _is_sliding: bool = false
var _support_popup: Panel = null
var _support_message_label: Label = null
var _support_buy_button: Button = null
var _support_restore_button: Button = null
var _showing_ex: bool = false
var _swipe_tracking: bool = false
var _swipe_start: Vector2 = Vector2.ZERO
var _swipe_triggered: bool = false

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
	_create_support_popup()
	_connect_support_purchase_signals()
	SupportPurchase.refresh_entitlements()
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	_build_surface_buttons()
	_build_ex_buttons()
	_update_lock_display()
	ButtonFeedback.install(self)

	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume

	var show_ex: bool = GameState.came_from_ex or SaveData.last_mode == "ex"
	GameState.came_from_ex = false
	if show_ex:
		slide_container.position.x = EX_SLIDE_X
	_showing_ex = show_ex
	_update_side_change_icon()

func _load_backgrounds() -> void:
	if ResourceLoader.exists(PATH_BG_SURFACE):
		$SlideContainer/SurfaceBG.texture = load(PATH_BG_SURFACE)
	if ResourceLoader.exists(PATH_BG_EX):
		$SlideContainer/EXBG.texture = load(PATH_BG_EX)
	_fit_page_background($SlideContainer/SurfaceBG, 0.0)
	_fit_page_background($SlideContainer/EXBG, EX_BG_X)

func _fit_page_background(bg: TextureRect, x: float) -> void:
	bg.position = Vector2(x, 0.0)
	bg.size = PAGE_SIZE
	bg.custom_minimum_size = PAGE_SIZE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE

func _setup_select_images() -> void:
	var stage_select_path := _localized_stage_select_path(PATH_STAGE_SELECT)
	var ex_select_path := _localized_stage_select_path(PATH_EX_SELECT)
	if ResourceLoader.exists(stage_select_path):
		surface_select_img.texture = load(stage_select_path)
	if ResourceLoader.exists(ex_select_path):
		ex_select_img.texture = load(ex_select_path)
	var header_size := Vector2(408.0, 116.0)
	surface_select_img.position = Vector2(36.0, 55.0)
	surface_select_img.size = header_size
	surface_select_img.custom_minimum_size = header_size
	surface_select_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ex_select_img.position = Vector2(EX_BG_X + 36.0, 55.0)
	ex_select_img.size = header_size
	ex_select_img.custom_minimum_size = header_size
	ex_select_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _setup_pyoko() -> void:
	chara_pyoko.visible = false
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
	var btn_ex: Button = side_change_button
	var icon_size: Vector2 = Vector2(210.0, 58.0)
	btn_ex.text = ""
	btn_ex.flat = true
	btn_ex.custom_minimum_size = icon_size
	btn_ex.size = icon_size
	btn_ex.position = Vector2(24.0, 772.0)
	btn_ex.expand_icon = true
	btn_ex.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_update_side_change_icon()

func _update_side_change_icon() -> void:
	if side_change_button == null:
		return
	var path: String = PATH_SURFACE_BTN if _showing_ex else PATH_EX_BTN
	path = _localized_stage_select_path(path)
	if ResourceLoader.exists(path):
		side_change_button.icon = load(path)

# ============================================================
# 設定・ホームボタンのアイコン設定
# ============================================================
func _setup_settings_home_icons() -> void:
	var btn_settings: Button = $BtnSettings
	var btn_home: Button = $BtnHome
	var icon_size: Vector2 = Vector2(76.0, 76.0)
	btn_settings.text = ""
	btn_home.text     = ""
	btn_settings.flat = true
	btn_home.flat     = true
	btn_settings.custom_minimum_size = icon_size
	btn_home.custom_minimum_size = icon_size
	btn_settings.size = icon_size
	btn_home.size = icon_size
	btn_home.position = Vector2(308.0, 762.0)
	btn_settings.position = Vector2(388.0, 762.0)
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
	for child in surface_stage_area.get_children():
		child.queue_free()
	_surface_rows.clear()
	for i in range(SURFACE_STAGES.size()):
		var stage: String = SURFACE_STAGES[i]
		var y: float = i * (SURFACE_ROW_H + ROW_GAP)
		var image_path := _localized_stage_select_path(SURFACE_NAME_IMAGES[i])
		var row_data: Dictionary = _create_stage_row(surface_stage_area, SURFACE_BUTTON_X, y, image_path, false, false)
		row_data["story_btn"].pressed.connect(_on_story_btn_pressed.bind(stage))
		if row_data["game_btn"] != null:
			row_data["game_btn"].pressed.connect(_on_game_btn_pressed.bind(stage))
		_surface_rows[stage] = row_data

func _build_ex_buttons() -> void:
	for child in ex_stage_area.get_children():
		child.queue_free()
	_ex_rows.clear()
	for i in range(EX_STAGES.size()):
		var stage: String = EX_STAGES[i]
		var y: float = i * (EX_ROW_H + ROW_GAP)
		var image_path: String = _get_ex_name_image(i)
		var row_data: Dictionary = _create_stage_row(ex_stage_area, EX_BUTTON_X, y, image_path, true, false)
		row_data["story_btn"].pressed.connect(_on_story_btn_pressed.bind(stage))
		if row_data["game_btn"] != null:
			row_data["game_btn"].pressed.connect(_on_game_btn_pressed.bind(stage))
		_ex_rows[stage] = row_data

func _get_ex_name_image(index: int) -> String:
	if index >= 0 and index < EX_STAGES.size() and EX_STAGES[index] == "music_room" and not SupportPurchase.is_supporter():
		return _localized_stage_select_path(PATH_SUPPORT_BTN)
	return _localized_stage_select_path(EX_NAME_IMAGES[index])

func _localized_stage_select_path(fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if locale == "ja":
		return fallback_path
	var localized_path := (LOCALIZED_STAGE_SELECT_DIR % locale) + fallback_path.get_file()
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _create_stage_row(parent: Control, lx: float, ly: float,
		name_img_path: String, is_ex: bool, show_game_btn: bool) -> Dictionary:
	var row: Control = Control.new()
	row.position = Vector2(0.0, ly)
	var actual_waku_w: float = EX_BUTTON_W if is_ex else SURFACE_BUTTON_W
	var row_h: float = EX_ROW_H if is_ex else SURFACE_ROW_H
	var row_w: float = PAGE_SIZE.x
	row.size = Vector2(row_w, row_h)
	parent.add_child(row)

	var waku_x: float
	var game_x: float

	if is_ex:
		waku_x = lx
		game_x = 0.0
	elif show_game_btn:
		waku_x = lx
		game_x = lx + actual_waku_w + WAKU_GAME_GAP
	else:
		waku_x = lx
		game_x = 0.0

	var name_img: TextureRect = TextureRect.new()
	name_img.position = Vector2(waku_x, 0.0)
	name_img.size = Vector2(actual_waku_w, row_h)
	name_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	name_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(name_img_path):
		name_img.texture = load(name_img_path)
	row.add_child(name_img)

	var score_row: Control = _make_high_score_digits(_get_stage_score_key(name_img_path, is_ex))
	if score_row != null:
		var score_size: Vector2 = score_row.custom_minimum_size
		if is_ex:
			score_row.position = Vector2(EX_SCORE_X, (row_h - score_size.y) / 2.0)
		else:
			score_row.position = Vector2(SURFACE_SCORE_X, (row_h - score_size.y) / 2.0)
		row.add_child(score_row)

	var story_btn: Button = Button.new()
	story_btn.position = Vector2(waku_x, 0.0)
	story_btn.size = Vector2(actual_waku_w, row_h)
	story_btn.custom_minimum_size = Vector2(actual_waku_w, row_h)
	story_btn.flat = true
	story_btn.text = ""
	row.add_child(story_btn)
	ButtonFeedback.set_target(story_btn, name_img)

	var game_btn: Button = null
	if show_game_btn and not is_ex:
		game_btn = Button.new()
		game_btn.position = Vector2(game_x, 0.0)
		game_btn.size = Vector2(GAME_W, row_h)
		game_btn.custom_minimum_size = Vector2(GAME_W, row_h)
		game_btn.flat = true
		game_btn.text = ""
		if ResourceLoader.exists(PATH_GAME_BTN):
			game_btn.icon = load(PATH_GAME_BTN)
		game_btn.expand_icon = true
		row.add_child(game_btn)

	var mask: Control = Control.new()
	mask.position = Vector2(0.0, 0.0)
	mask.size = Vector2(row_w, row_h)
	mask.visible = false

	var ki_h: float = 60.0
	var ki_w: float = row_w
	var ki_y: float = (row_h - ki_h) / 2.0
	var ki: TextureRect = TextureRect.new()
	ki.position = Vector2(0.0, ki_y)
	ki.size = Vector2(ki_w, ki_h)
	ki.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ki.stretch_mode = TextureRect.STRETCH_SCALE
	if ResourceLoader.exists(PATH_KI):
		ki.texture = load(PATH_KI)
	mask.add_child(ki)

	var mikai_w: float = row_w * 0.7
	var mikai_h: float = 120.0
	var mikai_x: float = (row_w - mikai_w) / 2.0
	var mikai_y: float = (row_h - mikai_h) / 2.0
	var mikai: TextureRect = TextureRect.new()
	mikai.position = Vector2(mikai_x, mikai_y)
	mikai.size = Vector2(mikai_w, mikai_h)
	mikai.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mikai.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var mikai_path := _localized_stage_select_path(PATH_MIKAI)
	if ResourceLoader.exists(mikai_path):
		mikai.texture = load(mikai_path)
	mask.add_child(mikai)

	row.add_child(mask)

	return {"story_btn": story_btn, "game_btn": game_btn, "mask": mask, "row": row}

func _get_stage_score_key(name_img_path: String, is_ex: bool) -> String:
	var list: Array = EX_NAME_IMAGES if is_ex else SURFACE_NAME_IMAGES
	var stages: Array = EX_STAGES if is_ex else SURFACE_STAGES
	var idx: int = -1
	var file_name := name_img_path.get_file()
	for i in range(list.size()):
		if str(list[i]).get_file() == file_name:
			idx = i
			break
	if idx < 0 or idx >= stages.size():
		return ""
	var stage: String = stages[idx]
	if stage == "music_room":
		return ""
	return stage

func _make_high_score_digits(stage_key: String) -> Control:
	if stage_key == "":
		return null
	var bg: Control = Control.new()
	var bg_size: Vector2 = HIGH_SCORE_PLATE_SIZE
	bg.custom_minimum_size = bg_size
	bg.size = bg_size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var plate := TextureRect.new()
	plate.position = Vector2.ZERO
	plate.size = bg_size
	plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plate.stretch_mode = TextureRect.STRETCH_SCALE
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(PATH_SCORE_PLATE):
		plate.texture = load(PATH_SCORE_PLATE)
	bg.add_child(plate)

	var margin: MarginContainer = MarginContainer.new()
	margin.position = Vector2.ZERO
	margin.size = bg_size
	margin.add_theme_constant_override("margin_left", int(HIGH_SCORE_BG_PAD_X))
	margin.add_theme_constant_override("margin_right", int(HIGH_SCORE_BG_PAD_X))
	margin.add_theme_constant_override("margin_top", int(HIGH_SCORE_BG_PAD_Y))
	margin.add_theme_constant_override("margin_bottom", int(HIGH_SCORE_BG_PAD_Y))
	bg.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.custom_minimum_size = Vector2(HIGH_SCORE_DIGIT_SLOT_W * HIGH_SCORE_DIGITS, HIGH_SCORE_DIGIT_H)
	row.size = row.custom_minimum_size
	row.add_theme_constant_override("separation", 0)
	row.alignment = BoxContainer.ALIGNMENT_END
	margin.add_child(row)
	var score_text: String = str(clampi(SaveData.get_high_score(stage_key), 0, 9999999))
	while score_text.length() < HIGH_SCORE_DIGITS:
		score_text = "0" + score_text
	for i in range(score_text.length()):
		var digit: String = score_text.substr(i, 1)
		var slot: Control = Control.new()
		slot.custom_minimum_size = Vector2(HIGH_SCORE_DIGIT_SLOT_W, HIGH_SCORE_DIGIT_H)
		slot.size = slot.custom_minimum_size
		slot.clip_contents = true
		var rect: TextureRect = TextureRect.new()
		var path: String = "res://assets/ui/menu_score_" + digit + ".webp"
		if ResourceLoader.exists(path):
			var texture: Texture2D = load(path) as Texture2D
			if texture != null:
				var texture_h: float = maxf(1.0, float(texture.get_height()))
				var digit_w: float = HIGH_SCORE_DIGIT_H * float(texture.get_width()) / texture_h
				rect.texture = texture
				rect.size = Vector2(digit_w, HIGH_SCORE_DIGIT_H)
				rect.custom_minimum_size = rect.size
				rect.position = Vector2((HIGH_SCORE_DIGIT_SLOT_W - digit_w) * 0.5, 0.0)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_SCALE
		slot.add_child(rect)
		row.add_child(slot)
	return bg

func _create_support_popup() -> void:
	if _support_popup != null and is_instance_valid(_support_popup):
		return
	var panel: Panel = Panel.new()
	panel.name = "SupportPopup"
	panel.visible = false
	panel.position = Vector2(25.0, 95.0)
	panel.size = Vector2(430.0, 650.0)
	panel.z_index = 50
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.08, 0.96)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.position = Vector2(58.0, 34.0)
	vbox.size = Vector2(314.0, 560.0)
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.name = "SupportTitle"
	title.text = "開発支援"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.text = ""
	title.custom_minimum_size = Vector2(0.0, 102.0)
	vbox.add_child(title)

	var body: Label = Label.new()
	body.text = "ゲーム本編はすべて無料で遊べます。\n500円で開発を支援できます。\n支援してくれた方には、お礼としてMusicroomが開放されます。"
	body.name = "SupportBody"
	body.text = _support_ui_text("body")
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 17)
	body.add_theme_color_override("font_color", Color.WHITE)
	body.custom_minimum_size = Vector2(314.0, 224.0)
	vbox.add_child(body)

	var message_label: Label = Label.new()
	message_label.text = ""
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 15)
	message_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.55))
	message_label.custom_minimum_size = Vector2(314.0, 36.0)
	vbox.add_child(message_label)

	var buy_button: Button = Button.new()
	buy_button.name = "BtnSupportBuy"
	buy_button.text = "購入する"
	buy_button.custom_minimum_size = Vector2(0.0, 48.0)
	buy_button.add_theme_font_size_override("font_size", 22)
	buy_button.pressed.connect(_on_support_purchase_pressed)
	vbox.add_child(buy_button)

	var restore_button: Button = Button.new()
	restore_button.name = "BtnSupportRestore"
	restore_button.text = "購入を復元"
	restore_button.custom_minimum_size = Vector2(0.0, 48.0)
	restore_button.add_theme_font_size_override("font_size", 22)
	restore_button.pressed.connect(_on_support_restore_pressed)
	vbox.add_child(restore_button)

	var close_button: Button = Button.new()
	close_button.name = "BtnSupportClose"
	close_button.text = "閉じる"
	close_button.custom_minimum_size = Vector2(0.0, 44.0)
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.pressed.connect(_on_support_close_pressed)
	vbox.add_child(close_button)
	_support_popup = panel
	_support_message_label = message_label
	_support_buy_button = buy_button
	_support_restore_button = restore_button
	PopupSkin.apply_support_popup(panel)
	_refresh_support_popup_texts()
	_update_support_popup_state()

func _connect_support_purchase_signals() -> void:
	if not SupportPurchase.state_changed.is_connected(_on_support_state_changed):
		SupportPurchase.state_changed.connect(_on_support_state_changed)
	if not SupportPurchase.purchase_finished.is_connected(_on_support_purchase_finished):
		SupportPurchase.purchase_finished.connect(_on_support_purchase_finished)
	if not SupportPurchase.restore_finished.is_connected(_on_support_restore_finished):
		SupportPurchase.restore_finished.connect(_on_support_restore_finished)

func _show_support_popup() -> void:
	if _support_popup == null or not is_instance_valid(_support_popup):
		_create_support_popup()
	PopupSkin.apply_support_popup(_support_popup)
	_refresh_support_popup_texts()
	_update_support_popup_state()
	_support_popup.visible = true
	_support_popup.move_to_front()

func _on_support_purchase_pressed() -> void:
	AudioManager.play_se("se_btntap")
	_set_support_message("購入処理を開始しています...")
	_set_support_message(_support_ui_text("purchase_start"))
	SupportPurchase.purchase_support()

func _on_support_restore_pressed() -> void:
	AudioManager.play_se("se_btntap")
	_set_support_message("購入情報を確認しています...")
	_set_support_message(_support_ui_text("restore_start"))
	SupportPurchase.restore_support()

func _on_support_close_pressed() -> void:
	AudioManager.play_se("se_btntap")
	if _support_popup != null and is_instance_valid(_support_popup):
		_support_popup.visible = false

func _on_support_state_changed() -> void:
	_update_support_popup_state()
	_build_ex_buttons()
	_update_lock_display()

func _on_support_purchase_finished(success: bool, message: String) -> void:
	_set_support_message(message)
	if success and SupportPurchase.is_supporter():
		_close_support_popup_after_support()

func _on_support_restore_finished(_success: bool, message: String) -> void:
	_set_support_message(message)
	if SupportPurchase.is_supporter():
		_close_support_popup_after_support()

func _close_support_popup_after_support() -> void:
	if _support_popup != null and is_instance_valid(_support_popup):
		_support_popup.visible = false
	_build_ex_buttons()
	_update_lock_display()

func _update_support_popup_state() -> void:
	var busy: bool = SupportPurchase.is_busy
	if _support_buy_button != null and is_instance_valid(_support_buy_button):
		_support_buy_button.disabled = busy or SupportPurchase.is_supporter()
	if _support_restore_button != null and is_instance_valid(_support_restore_button):
		_support_restore_button.disabled = busy
	if SupportPurchase.is_supporter():
		_set_support_message("開発支援済みです。Musicroomを利用できます。")
	elif busy:
		_set_support_message("処理中です...")

	if SupportPurchase.is_supporter():
		_set_support_message(_support_ui_text("supported"))
	elif busy:
		_set_support_message(_support_ui_text("busy"))

func _set_support_message(message: String) -> void:
	if _support_message_label != null and is_instance_valid(_support_message_label):
		_support_message_label.text = message

func _refresh_support_popup_texts() -> void:
	if _support_popup == null or not is_instance_valid(_support_popup):
		return
	var body := _support_popup.get_node_or_null("VBox/SupportBody") as Label
	if body != null:
		body.text = _support_ui_text("body")
	var title := _support_popup.get_node_or_null("VBox/SupportTitle") as Label
	if title != null:
		title.text = ""

func _support_ui_text(key: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var texts := {
		"ja": {
			"body": "「まちあて！」を遊んでいただき、ありがとうございます。\n狼天紅ゲームズは、これからも麻雀ゲーム・人狼ゲームを中心に開発を続けていきます。\n「このゲームが面白かった」「今後の作品も楽しみ」と思っていただけた方は、開発支援(500円)をご検討ください。\n支援の特典として、Musicroom(BGM全曲を自由に聴ける機能)が解放されます。\n※支援をしなくても、ゲーム本編はすべて無料で遊べます。",
			"purchase_start": "購入処理を開始しています...",
			"restore_start": "購入情報を確認しています...",
			"supported": "開発支援済みです。Musicroomを利用できます。",
			"busy": "処理中です...",
		},
		"en": {
			"body": "Thank you for playing Machi-ate!\nWolf Heaven Games will keep developing games, mainly mahjong and werewolf games.\nIf you enjoyed this game or are looking forward to future titles, please consider supporting development (¥500).\nAs a supporter benefit, Music Room unlocks, letting you freely listen to every BGM track.\n*Even without support, the full main game is free to play.",
			"purchase_start": "Starting purchase...",
			"restore_start": "Checking purchase information...",
			"supported": "Development support confirmed. Music Room is available.",
			"busy": "Processing...",
		},
		"zh_CN": {
			"body": "感谢您游玩《待牌猜猜看！》。\n狼天红 Games 今后也会继续以麻将游戏、人狼游戏为中心进行开发。\n如果您觉得“这个游戏很有趣”或“也期待今后的作品”，欢迎考虑开发支援（500日元）。\n作为支援特典，将解锁 Music Room（可自由聆听全部 BGM 的功能）。\n※即使不支援，也可以免费游玩全部游戏本篇。",
			"purchase_start": "正在开始购买处理...",
			"restore_start": "正在确认购买信息...",
			"supported": "已完成开发支援。可以使用 Music Room。",
			"busy": "处理中...",
		},
		"zh_TW": {
			"body": "感謝您遊玩《待牌猜猜看！》。\n狼天紅 Games 今後也會繼續以麻將遊戲、人狼遊戲為中心進行開發。\n如果您覺得「這款遊戲很有趣」或「也期待今後的作品」，歡迎考慮開發支援（500日圓）。\n作為支援特典，將解鎖 Music Room（可自由聆聽全部 BGM 的功能）。\n※即使不支援，也可以免費遊玩全部遊戲本篇。",
			"purchase_start": "正在開始購買處理...",
			"restore_start": "正在確認購買資訊...",
			"supported": "已完成開發支援。可以使用 Music Room。",
			"busy": "處理中...",
		},
		"ko": {
			"body": "마치아테!를 플레이해 주셔서 감사합니다.\n늑천홍 Games는 앞으로도 마작 게임과 인랑 게임을 중심으로 개발을 이어 나가겠습니다.\n“이 게임이 재미있었다”, “앞으로의 작품도 기대된다”고 느끼셨다면 개발 지원(500엔)을 검토해 주세요.\n지원 특전으로 Music Room(모든 BGM을 자유롭게 들을 수 있는 기능)이 해금됩니다.\n※지원을 하지 않아도 게임 본편은 모두 무료로 즐길 수 있습니다.",
			"purchase_start": "구매 처리를 시작하고 있습니다...",
			"restore_start": "구매 정보를 확인하고 있습니다...",
			"supported": "개발 지원이 완료되었습니다. Music Room을 이용할 수 있습니다.",
			"busy": "처리 중입니다...",
		},
	}
	var locale_texts: Dictionary = texts.get(locale, texts["ja"])
	return str(locale_texts.get(key, texts["ja"].get(key, "")))

# ============================================================
# ステージ表示状態の更新
# ============================================================
func _update_lock_display() -> void:
	for stage in SURFACE_STAGES:
		if not _surface_rows.has(stage):
			continue
		var row_data: Dictionary = _surface_rows[stage]
		row_data["mask"].visible       = false
		row_data["story_btn"].disabled = false
		if row_data["game_btn"] != null and row_data["game_btn"].is_inside_tree():
			row_data["game_btn"].disabled = false

	side_change_button.visible = true

	for stage in EX_STAGES:
		if not _ex_rows.has(stage):
			continue
		var row_data: Dictionary = _ex_rows[stage]
		row_data["mask"].visible       = false
		row_data["story_btn"].disabled = false
		if row_data["game_btn"] != null and row_data["game_btn"].is_inside_tree():
			row_data["game_btn"].disabled = false

# ============================================================
# デバッグ
# ============================================================
func _input(event: InputEvent) -> void:
	_handle_page_swipe(event)

	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		SupportPurchase.debug_reset_supporter()
		_build_ex_buttons()
		_update_lock_display()
		print("【デバッグ】開発支援を購入前に戻しました")

# ============================================================
# スライド演出
# ============================================================
func _handle_page_swipe(event: InputEvent) -> void:
	if _is_sliding or $SettingsPopup.visible or (_support_popup != null and _support_popup.visible):
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		_swipe_tracking = touch.pressed
		_swipe_start = touch.position
		_swipe_triggered = false
		return

	if event is InputEventScreenDrag and _swipe_tracking and not _swipe_triggered:
		var drag := event as InputEventScreenDrag
		var delta: Vector2 = drag.position - _swipe_start
		if absf(delta.x) < SWIPE_MIN_X:
			return
		if absf(delta.y) > SWIPE_MAX_Y:
			return
		if absf(delta.x) < absf(delta.y) * SWIPE_AXIS_RATIO:
			return

		_swipe_triggered = true
		if delta.x < 0.0 and not _showing_ex:
			_slide_to_ex()
		elif delta.x > 0.0 and _showing_ex:
			_slide_to_surface()

func _slide_to_ex() -> void:
	if _is_sliding:
		return
	SaveData.last_mode = "ex"
	SaveData.save()
	_showing_ex = true
	_is_sliding = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(slide_container, "position:x", EX_SLIDE_X, 0.4)
	await tween.finished
	_is_sliding = false
	_update_side_change_icon()

func _slide_to_surface() -> void:
	if _is_sliding:
		return
	SaveData.last_mode = "surface"
	SaveData.save()
	_showing_ex = false
	_is_sliding = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(slide_container, "position:x", 0.0, 0.4)
	await tween.finished
	_is_sliding = false
	_update_side_change_icon()

# ============================================================
# ボタン処理
# ============================================================
func _on_story_btn_pressed(stage: String) -> void:
	if _get_stage_talk_scene_id(stage) != "":
		_start_stage_story(stage)
		return
	_start_stage(stage)

func _on_game_btn_pressed(stage: String) -> void:
	_start_stage(stage)

func _get_stage_talk_scene_id(stage: String) -> String:
	return str(STAGE_TALK_SCENE_IDS.get(stage, ""))

func _start_stage_story(stage: String) -> void:
	SaveData.last_mode = "surface"
	if stage not in SURFACE_STAGES:
		SaveData.last_mode = "ex"
	SaveData.save()
	GameState.came_from_stage3 = false
	GameState.current_stage = stage
	GameState.talk_scene_id = _get_stage_talk_scene_id(stage)
	GameState.talk_return_scene = "res://game.tscn"
	if stage == "stage3" or stage == "ex_stage3":
		GameState.reset_run_score()
	get_tree().change_scene_to_file("res://TalkScene.tscn")

func _start_stage(stage: String) -> void:
	print("【デバッグ】_start_stage called: ", stage)
	if stage == "music_room" and not SupportPurchase.is_supporter():
		_show_support_popup()
		return
	if stage in SURFACE_STAGES:
		SaveData.last_mode = "surface"
	else:
		SaveData.last_mode = "ex"
	SaveData.save()

	match stage:
		"tutorial", "stage1", "stage2", "stage3":
			GameState.came_from_stage3 = false
			GameState.current_stage = stage
			GameState.talk_scene_id = ""
			GameState.talk_return_scene = ""
			if stage == "stage3":
				GameState.reset_run_score()
			get_tree().change_scene_to_file("res://game.tscn")
		"custom":
			GameState.talk_scene_id = ""
			GameState.talk_return_scene = ""
			get_tree().change_scene_to_file("res://custom.tscn")
		"ex_stage1", "ex_stage2", "ex_stage3":
			GameState.came_from_stage3 = false
			GameState.current_stage = stage
			GameState.talk_scene_id = ""
			GameState.talk_return_scene = ""
			if stage == "ex_stage3":
				GameState.reset_run_score()
			get_tree().change_scene_to_file("res://game.tscn")
		"endless":
			GameState.endless_block = 0
			GameState.endless_total_question = 0
			GameState.current_stage = "endless"
			GameState.is_instant_mode = false
			GameState.talk_scene_id = ""
			GameState.talk_return_scene = ""
			GameState.reset_run_score()
			get_tree().change_scene_to_file("res://game.tscn")
		"music_room":
			print("【デバッグ】music_room scene change")
			get_tree().change_scene_to_file("res://MusicRoom.tscn")

func _on_btn_side_change_pressed() -> void:
	if _showing_ex:
		_slide_to_surface()
	else:
		_slide_to_ex()

func _on_btn_settings_pressed() -> void:
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
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

func _on_language_button_pressed(code: String) -> void:
	SaveData.set_language_code(code)
	TranslationServer.set_locale(SaveData.language_code)
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	_setup_select_images()
	_build_surface_buttons()
	_build_ex_buttons()
	_update_lock_display()
	_update_side_change_icon()
	if _support_popup != null and is_instance_valid(_support_popup):
		PopupSkin.apply_support_popup(_support_popup)
		_refresh_support_popup_texts()
		_update_support_popup_state()
	AudioManager.play_se("se_btntap")

func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Title.tscn")
