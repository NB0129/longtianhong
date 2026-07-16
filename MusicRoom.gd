extends Control

const PopupSkin := preload("res://PopupSkin.gd")
const ButtonFeedback := preload("res://ButtonFeedback.gd")

const ALL_BGM_LIST: Array = [
	{"file": "bgm_talk_tutorial",          "name": "ちゅーとりある"},
	{"file": "bgm_talk_easy",              "name": "麻雀山の入り口"},
	{"file": "bgm_talk_normal",            "name": "夕暮れの麻雀山"},
	{"file": "bgm_talk_hard",              "name": "三日月の麻雀山"},
	{"file": "bgm_yume_main",              "name": "リーチの歌"},
	{"file": "bgm_yume_jantou",            "name": "雀頭を探して"},
	{"file": "bgm_yume_barabara",          "name": "配牌がバラバラ！"},
	{"file": "bgm_utu_higakureru",         "name": "日が暮れちゃう♡"},
	{"file": "bgm_utu_matigai",            "name": "あれ、間違ってるよ♡"},
	{"file": "bgm_utu_nochan",             "name": "ノーミスでクリアして♡"},
	{"file": "bgm_utu_kotaewo",            "name": "答えを教えてあげる♡"},
	{"file": "bgm_mabo_first_2tunoboketu", "name": "二つの墓穴"},
	{"file": "bgm_mabo_first_appaku",      "name": "圧迫問答"},
	{"file": "bgm_mabo_first_nebumi",      "name": "値踏みの視線"},
	{"file": "bgm_mabo_second_kougetu",    "name": "紅月の狼"},
	{"file": "bgm_mabo_second_ginniro",    "name": "銀色の影"},
	{"file": "bgm_mabo_second_inisie",     "name": "古の英雄"},
	{"file": "bgm_mabo_mugen",             "name": "無限の決闘"},
	{"file": "bgm_gameover_mou",           "name": "ゲームオーバーの歌"},
	{"file": "bgm_t_sentaku",              "name": "少考の間"},
	{"file": "bgm_t_title",                "name": "夢か現か幻か"},
]

const LOCALIZED_TRACK_NAMES: Dictionary = {
	"en": {
		"bgm_talk_tutorial": "Tutorial",
		"bgm_talk_easy": "Entrance to Mahjong Mountain",
		"bgm_talk_normal": "Mahjong Mountain at Dusk",
		"bgm_talk_hard": "Crescent Moon Mahjong Mountain",
		"bgm_yume_main": "Riichi Song",
		"bgm_yume_jantou": "Searching for the Pair",
		"bgm_yume_barabara": "Scattered Starting Hand!",
		"bgm_utu_higakureru": "The Sun Is Setting♡",
		"bgm_utu_matigai": "Hey, That's Wrong♡",
		"bgm_utu_nochan": "Clear Without Mistakes♡",
		"bgm_utu_kotaewo": "I'll Tell You the Answer♡",
		"bgm_mabo_first_2tunoboketu": "Two Graves",
		"bgm_mabo_first_appaku": "Oppressive Interrogation",
		"bgm_mabo_first_nebumi": "Appraising Gaze",
		"bgm_mabo_second_kougetu": "Crimson Moon Wolf",
		"bgm_mabo_second_ginniro": "Silver Shadow",
		"bgm_mabo_second_inisie": "Ancient Hero",
		"bgm_mabo_mugen": "Endless Duel",
		"bgm_gameover_mou": "Game Over Song",
		"bgm_t_sentaku": "Time to Think",
		"bgm_t_title": "Dream, Reality, or Illusion",
	},
	"zh_CN": {
		"bgm_talk_tutorial": "教程",
		"bgm_talk_easy": "麻将山入口",
		"bgm_talk_normal": "黄昏的麻将山",
		"bgm_talk_hard": "新月下的麻将山",
		"bgm_yume_main": "立直之歌",
		"bgm_yume_jantou": "寻找雀头",
		"bgm_yume_barabara": "配牌乱七八糟！",
		"bgm_utu_higakureru": "太阳要下山了♡",
		"bgm_utu_matigai": "咦，答错了哦♡",
		"bgm_utu_nochan": "请无失误通关♡",
		"bgm_utu_kotaewo": "我来告诉你答案♡",
		"bgm_mabo_first_2tunoboketu": "两个墓穴",
		"bgm_mabo_first_appaku": "压迫问答",
		"bgm_mabo_first_nebumi": "估价的视线",
		"bgm_mabo_second_kougetu": "红月之狼",
		"bgm_mabo_second_ginniro": "银色之影",
		"bgm_mabo_second_inisie": "远古英雄",
		"bgm_mabo_mugen": "无限决斗",
		"bgm_gameover_mou": "游戏结束之歌",
		"bgm_t_sentaku": "少考之间",
		"bgm_t_title": "梦、现实或幻影",
	},
	"zh_TW": {
		"bgm_talk_tutorial": "教學",
		"bgm_talk_easy": "麻將山入口",
		"bgm_talk_normal": "黃昏的麻將山",
		"bgm_talk_hard": "新月下的麻將山",
		"bgm_yume_main": "立直之歌",
		"bgm_yume_jantou": "尋找雀頭",
		"bgm_yume_barabara": "配牌亂七八糟！",
		"bgm_utu_higakureru": "太陽要下山了♡",
		"bgm_utu_matigai": "咦，答錯了喔♡",
		"bgm_utu_nochan": "請無失誤通關♡",
		"bgm_utu_kotaewo": "我來告訴你答案♡",
		"bgm_mabo_first_2tunoboketu": "兩個墓穴",
		"bgm_mabo_first_appaku": "壓迫問答",
		"bgm_mabo_first_nebumi": "估價的視線",
		"bgm_mabo_second_kougetu": "紅月之狼",
		"bgm_mabo_second_ginniro": "銀色之影",
		"bgm_mabo_second_inisie": "遠古英雄",
		"bgm_mabo_mugen": "無限決鬥",
		"bgm_gameover_mou": "遊戲結束之歌",
		"bgm_t_sentaku": "少考之間",
		"bgm_t_title": "夢、現實或幻影",
	},
	"ko": {
		"bgm_talk_tutorial": "튜토리얼",
		"bgm_talk_easy": "마작산 입구",
		"bgm_talk_normal": "해질녘의 마작산",
		"bgm_talk_hard": "초승달의 마작산",
		"bgm_yume_main": "리치의 노래",
		"bgm_yume_jantou": "머리 찾기",
		"bgm_yume_barabara": "배패가 엉망진창!",
		"bgm_utu_higakureru": "해가 져 버려♡",
		"bgm_utu_matigai": "어라, 틀렸어♡",
		"bgm_utu_nochan": "노미스로 클리어해 줘♡",
		"bgm_utu_kotaewo": "정답을 알려 줄게♡",
		"bgm_mabo_first_2tunoboketu": "두 개의 무덤",
		"bgm_mabo_first_appaku": "압박 문답",
		"bgm_mabo_first_nebumi": "값을 매기는 시선",
		"bgm_mabo_second_kougetu": "붉은 달의 늑대",
		"bgm_mabo_second_ginniro": "은빛 그림자",
		"bgm_mabo_second_inisie": "고대의 영웅",
		"bgm_mabo_mugen": "무한의 결투",
		"bgm_gameover_mou": "게임 오버의 노래",
		"bgm_t_sentaku": "잠시 생각하는 시간",
		"bgm_t_title": "꿈인가 현실인가 환상인가",
	},
}

const MUSIC_SETTINGS_TEXT: Dictionary = {
	"ja": {
		"bgm_volume": "BGM音量",
		"se_volume": "SE音量",
		"repeat_one": "同じ曲を繰り返し",
	},
	"en": {
		"bgm_volume": "BGM volume",
		"se_volume": "SE volume",
		"repeat_one": "Repeat same track",
	},
	"zh_CN": {
		"bgm_volume": "BGM 音量",
		"se_volume": "SE 音量",
		"repeat_one": "重复播放同一首",
	},
	"zh_TW": {
		"bgm_volume": "BGM 音量",
		"se_volume": "SE 音量",
		"repeat_one": "重複播放同一首",
	},
	"ko": {
		"bgm_volume": "BGM 음량",
		"se_volume": "SE 음량",
		"repeat_one": "같은 곡 반복",
	},
}

const PATH_BG_MUSIC   := "res://assets/bg/music_bg.webp"
const ICON_SETTINGS   := "res://assets/bg/music_icon_settings_ui.webp"
const ICON_HOME       := "res://assets/bg/music_icon_home_ui.webp"
const PATH_TITLE      := "res://assets/bg/music_title_ui.webp"
const PATH_NOW_PLAYING := "res://assets/bg/music_now_playing_ui.webp"
const PATH_HEADER_ALL := "res://assets/bg/music_header_all_tracks_ui.webp"
const PATH_BTN_PLAY := "res://assets/bg/music_btn_play_ui.webp"
const PATH_BTN_PAUSE := "res://assets/bg/music_btn_pause_ui.webp"
const PATH_BTN_STOP := "res://assets/bg/music_btn_stop_ui.webp"
const LOCALIZED_MUSIC_ROOM_DIR := "res://assets/language/normalized/%s/music_room/"
const JACKET_DIR := "res://assets/ui/stage_intro/"
const JACKET_PATHS: Dictionary = {
	"bgm_talk_tutorial": JACKET_DIR + "jacket_bgm_talk_tutorial.webp",
	"bgm_talk_easy": JACKET_DIR + "jacket_bgm_talk_easy.webp",
	"bgm_talk_normal": JACKET_DIR + "jacket_bgm_talk_normal.webp",
	"bgm_talk_hard": JACKET_DIR + "jacket_bgm_talk_hard.webp",
	"bgm_yume_main": JACKET_DIR + "jacket_bgm_yume_reach_v8.webp",
	"bgm_yume_jantou": JACKET_DIR + "jacket_bgm_yume_jantou_v4.webp",
	"bgm_yume_barabara": JACKET_DIR + "jacket_bgm_yume_barabara.webp",
	"bgm_utu_higakureru": JACKET_DIR + "jacket_bgm_utu_higakureru_v4.webp",
	"bgm_utu_matigai": JACKET_DIR + "jacket_bgm_utu_matigai.webp",
	"bgm_utu_nochan": JACKET_DIR + "jacket_bgm_utu_nochan_trial.webp",
	"bgm_utu_kotaewo": JACKET_DIR + "jacket_bgm_utu_kotaewo_v3.webp",
	"bgm_mabo_first_2tunoboketu": JACKET_DIR + "jacket_bgm_mabo_first_2tunoboketu.webp",
	"bgm_mabo_first_appaku": JACKET_DIR + "jacket_bgm_mabo_first_appaku_no_tiles.webp",
	"bgm_mabo_first_nebumi": JACKET_DIR + "jacket_bgm_mabo_first_nebumi.webp",
	"bgm_mabo_second_kougetu": JACKET_DIR + "jacket_bgm_mabo_second_kougetu_v2.webp",
	"bgm_mabo_second_ginniro": JACKET_DIR + "jacket_bgm_mabo_second_ginniro.webp",
	"bgm_mabo_second_inisie": JACKET_DIR + "jacket_bgm_mabo_second_inisie.webp",
	"bgm_mabo_mugen": JACKET_DIR + "jacket_bgm_mabo_mugen.webp",
	"bgm_gameover_mou": JACKET_DIR + "jacket_bgm_gameover_mou.webp",
	"bgm_t_sentaku": JACKET_DIR + "jacket_bgm_t_sentaku.webp",
	"bgm_t_title": JACKET_DIR + "jacket_bgm_t_title.webp",
}

const ROW_H_FULL: float = 50.0
const ROW_H_PLAY: float = 52.0

var _full_list_selected_index: int = 0
var _player_state: String = "idle"  # idle, playing, paused
var _play_source: String = ""       # "" / "full_list"
var _current_playing_file: String = ""

# 蜍慕噪繝弱・繝牙盾辣ｧ
var _full_list_row_nodes: Array = []
var _jacket_rect: TextureRect = null
var _jacket_fallback_label: Label = null
var _status_label: Label = null
var _repeat_one_check: CheckBox = null
var _list_dragging: bool = false
var _list_drag_last_y: float = 0.0
var _list_drag_total: float = 0.0

# ============================================================
# 蛻晄悄蛹・# ============================================================
func _ready() -> void:
	if ResourceLoader.exists(PATH_BG_MUSIC):
		$BG.texture = load(PATH_BG_MUSIC)
	$BG.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$BG.stretch_mode = TextureRect.STRETCH_SCALE
	_setup_generated_ui()

	_set_screen_keep_on(true)

	AudioManager.stop_bgm()

	_build_full_list()

	_full_list_selected_index = 0

	if not AudioManager.bgm_player.finished.is_connected(_on_bgm_finished):
		AudioManager.bgm_player.finished.connect(_on_bgm_finished)

	_update_visuals()
	_update_track_name_display()

	if ResourceLoader.exists(ICON_SETTINGS):
		$BtnSettings.icon = load(ICON_SETTINGS)
	$BtnSettings.expand_icon = true

	# 險ｭ螳壹・繝・・繧｢繝・・縺ｯ譛蛻昴・髱櫁｡ｨ遉ｺ
	$SettingsPopup.visible = false
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	_setup_music_settings()
	ButtonFeedback.install(self)

func _setup_generated_ui() -> void:
	_add_texture_layer("MusicTitleImage", _localized_music_room_path("music_title_ui.webp", PATH_TITLE), Vector2(32.0, 6.0), Vector2(416.0, 74.0))
	var all_tracks_header := get_node_or_null("AllTracksHeaderImage") as TextureRect
	if all_tracks_header != null:
		all_tracks_header.visible = false
	var now_playing_header := get_node_or_null("NowPlayingImage") as TextureRect
	if now_playing_header != null:
		now_playing_header.visible = false

	_setup_jacket_view()

	$PlayerPanel.position = Vector2(12.0, 472.0)
	$PlayerPanel.size = Vector2(456.0, 76.0)
	var player_style := StyleBoxFlat.new()
	player_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	$PlayerPanel.add_theme_stylebox_override("panel", player_style)
	$PlayerPanel/TrackNameLabel.visible = false

	_setup_image_button($PlayerPanel/BtnPlay, _localized_music_room_path("music_btn_play_ui.webp", PATH_BTN_PLAY), Vector2(26.0, 19.0), Vector2(124.0, 38.0))
	_setup_image_button($PlayerPanel/BtnPause, _localized_music_room_path("music_btn_pause_ui.webp", PATH_BTN_PAUSE), Vector2(166.0, 19.0), Vector2(124.0, 38.0))
	_setup_image_button($PlayerPanel/BtnStop, _localized_music_room_path("music_btn_stop_ui.webp", PATH_BTN_STOP), Vector2(306.0, 19.0), Vector2(124.0, 38.0))

	$FullListLabel.visible = false
	$FullListScroll.position = Vector2(18.0, 548.0)
	$FullListScroll.size = Vector2(444.0, 188.0)
	if not $FullListScroll.gui_input.is_connected(_on_full_list_scroll_gui_input):
		$FullListScroll.gui_input.connect(_on_full_list_scroll_gui_input)
	_set_scroll_panel_dark($FullListScroll)

	_setup_image_button($BtnBack, ICON_HOME, Vector2(314.0, 752.0), Vector2(72.0, 72.0))
	_setup_image_button($BtnSettings, ICON_SETTINGS, Vector2(390.0, 752.0), Vector2(72.0, 72.0))

func _setup_jacket_view() -> void:
	var frame := get_node_or_null("JacketFrame") as Panel
	if frame == null:
		frame = Panel.new()
		frame.name = "JacketFrame"
		add_child(frame)
		move_child(frame, 2)
	frame.position = Vector2(48.0, 86.0)
	frame.size = Vector2(384.0, 384.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.008, 0.022, 0.80)
	style.border_color = Color(1.0, 0.66, 0.22, 0.55)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	frame.add_theme_stylebox_override("panel", style)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_jacket_rect = frame.get_node_or_null("JacketImage") as TextureRect
	if _jacket_rect == null:
		_jacket_rect = TextureRect.new()
		_jacket_rect.name = "JacketImage"
		frame.add_child(_jacket_rect)
	_jacket_rect.position = Vector2(12.0, 12.0)
	_jacket_rect.size = Vector2(360.0, 360.0)
	_jacket_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_jacket_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_jacket_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_jacket_fallback_label = frame.get_node_or_null("FallbackLabel") as Label
	if _jacket_fallback_label == null:
		_jacket_fallback_label = Label.new()
		_jacket_fallback_label.name = "FallbackLabel"
		frame.add_child(_jacket_fallback_label)
	_jacket_fallback_label.position = Vector2(28.0, 130.0)
	_jacket_fallback_label.size = Vector2(328.0, 116.0)
	_jacket_fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_jacket_fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_jacket_fallback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_jacket_fallback_label.add_theme_font_size_override("font_size", 26)
	_jacket_fallback_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.62))
	_jacket_fallback_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	_jacket_fallback_label.add_theme_constant_override("shadow_offset_x", 2)
	_jacket_fallback_label.add_theme_constant_override("shadow_offset_y", 2)

	_status_label = get_node_or_null("PlaybackStatusLabel") as Label
	if _status_label == null:
		_status_label = Label.new()
		_status_label.name = "PlaybackStatusLabel"
		add_child(_status_label)
		move_child(_status_label, 3)
	_status_label.position = Vector2(38.0, 442.0)
	_status_label.size = Vector2(404.0, 28.0)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 18)
	_status_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	_status_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	_status_label.add_theme_constant_override("shadow_offset_x", 2)
	_status_label.add_theme_constant_override("shadow_offset_y", 2)

func _setup_music_settings() -> void:
	var vbox: VBoxContainer = $SettingsPopup/VBox
	for path in ["SettingsPopup/VBox/LabelTileSuit", "SettingsPopup/VBox/TileSuitGrid"]:
		var node := get_node_or_null(path) as Control
		if node != null:
			node.visible = false
			node.custom_minimum_size = Vector2.ZERO
			node.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_repeat_one_check = vbox.get_node_or_null("CheckRepeatOne") as CheckBox
	if _repeat_one_check == null:
		_repeat_one_check = CheckBox.new()
		_repeat_one_check.name = "CheckRepeatOne"
		vbox.add_child(_repeat_one_check)
	var se_slider := vbox.get_node_or_null("SeSlider")
	if se_slider != null:
		vbox.move_child(_repeat_one_check, se_slider.get_index() + 1)
	_repeat_one_check.custom_minimum_size = Vector2(0.0, 46.0)
	_repeat_one_check.add_theme_font_size_override("font_size", 22)
	var settings_label_color := Color(0.10, 0.38, 0.32)
	_repeat_one_check.add_theme_color_override("font_color", settings_label_color)
	_repeat_one_check.add_theme_color_override("font_hover_color", settings_label_color)
	_repeat_one_check.add_theme_color_override("font_pressed_color", settings_label_color)
	_repeat_one_check.add_theme_color_override("font_focus_color", settings_label_color)
	_repeat_one_check.add_theme_color_override("font_outline_color", Color(1.0, 0.96, 0.82, 0.72))
	_repeat_one_check.add_theme_constant_override("outline_size", 3)
	_repeat_one_check.button_pressed = SaveData.music_repeat_one
	if not _repeat_one_check.toggled.is_connected(_on_repeat_one_toggled):
		_repeat_one_check.toggled.connect(_on_repeat_one_toggled)
	_refresh_music_settings_text()

func _refresh_music_settings_text() -> void:
	var vbox: VBoxContainer = $SettingsPopup/VBox
	var bgm_label := vbox.get_node_or_null("LabelBgm") as Label
	if bgm_label != null:
		bgm_label.text = _music_settings_text("bgm_volume")
	var se_label := vbox.get_node_or_null("LabelSe") as Label
	if se_label != null:
		se_label.text = _music_settings_text("se_volume")
	if _repeat_one_check != null:
		_repeat_one_check.text = _music_settings_text("repeat_one")

func _music_settings_text(key: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var locale_texts: Dictionary = MUSIC_SETTINGS_TEXT.get(locale, MUSIC_SETTINGS_TEXT["ja"])
	return str(locale_texts.get(key, MUSIC_SETTINGS_TEXT["ja"].get(key, "")))

func _add_texture_layer(name: String, path: String, position: Vector2, size: Vector2) -> TextureRect:
	var rect: TextureRect = get_node_or_null(name) as TextureRect
	if rect == null:
		rect = TextureRect.new()
		rect.name = name
		add_child(rect)
		move_child(rect, 1)
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

func _setup_image_button(button: Button, path: String, position: Vector2, size: Vector2) -> void:
	button.text = ""
	button.position = position
	button.size = size
	button.custom_minimum_size = size
	button.flat = true
	button.icon = null
	button.expand_icon = false
	_set_button_art(button, path)

func _set_button_art(button: Button, path: String) -> void:
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

func _localized_music_room_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if locale == "ja":
		return fallback_path
	var localized_path := (LOCALIZED_MUSIC_ROOM_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _refresh_localized_music_images() -> void:
	var title_rect := get_node_or_null("MusicTitleImage") as TextureRect
	var title_path := _localized_music_room_path("music_title_ui.webp", PATH_TITLE)
	if title_rect != null and ResourceLoader.exists(title_path):
		title_rect.texture = load(title_path)
	var now_playing_rect := get_node_or_null("NowPlayingImage") as TextureRect
	var now_playing_path := _localized_music_room_path("music_now_playing_ui.webp", PATH_NOW_PLAYING)
	if now_playing_rect != null and ResourceLoader.exists(now_playing_path):
		now_playing_rect.texture = load(now_playing_path)
	var all_tracks_rect := get_node_or_null("AllTracksHeaderImage") as TextureRect
	var all_tracks_path := _localized_music_room_path("music_header_all_tracks_ui.webp", PATH_HEADER_ALL)
	if all_tracks_rect != null and ResourceLoader.exists(all_tracks_path):
		all_tracks_rect.texture = load(all_tracks_path)
	_set_button_art($PlayerPanel/BtnPlay, _localized_music_room_path("music_btn_play_ui.webp", PATH_BTN_PLAY))
	_set_button_art($PlayerPanel/BtnPause, _localized_music_room_path("music_btn_pause_ui.webp", PATH_BTN_PAUSE))
	_set_button_art($PlayerPanel/BtnStop, _localized_music_room_path("music_btn_stop_ui.webp", PATH_BTN_STOP))

func _set_scroll_panel_dark(scroll: ScrollContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.018, 0.035, 0.58)
	style.border_color = Color(0.95, 0.65, 0.24, 0.32)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	scroll.add_theme_stylebox_override("panel", style)

func _apply_music_row_button_style(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.025, 0.045, 0.60)
	normal.border_color = Color(0.95, 0.62, 0.24, 0.24)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)
	normal.set_content_margin(SIDE_LEFT, 10.0)
	normal.set_content_margin(SIDE_TOP, 7.0)
	normal.set_content_margin(SIDE_RIGHT, 8.0)
	normal.set_content_margin(SIDE_BOTTOM, 0.0)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.20, 0.045, 0.075, 0.78)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.35, 0.16, 0.05, 0.88)
	pressed.border_color = Color(1.0, 0.78, 0.32, 0.55)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)

func _setup_compact_icon_button(button: Button, path: String) -> void:
	button.text = ""
	button.custom_minimum_size = Vector2(40.0, ROW_H_PLAY)
	button.size = button.custom_minimum_size
	button.flat = true
	button.icon = null
	button.expand_icon = false
	_set_button_art(button, path)

func _exit_tree() -> void:
	if AudioManager.bgm_player.finished.is_connected(_on_bgm_finished):
		AudioManager.bgm_player.finished.disconnect(_on_bgm_finished)
	_set_screen_keep_on(false)

func _set_screen_keep_on(enable: bool) -> void:
	if DisplayServer.has_method("screen_set_keep_on"):
		DisplayServer.screen_set_keep_on(enable)

func _on_full_list_scroll_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_list_dragging = event.pressed
		_list_drag_last_y = event.position.y
		if event.pressed:
			_list_drag_total = 0.0
		if event.pressed:
			$FullListScroll.accept_event()
	elif event is InputEventScreenDrag:
		$FullListScroll.scroll_vertical -= int(event.relative.y)
		_list_drag_total += abs(event.relative.y)
		$FullListScroll.accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_list_dragging = event.pressed
		_list_drag_last_y = event.position.y
		if event.pressed:
			_list_drag_total = 0.0
	elif event is InputEventMouseMotion and _list_dragging:
		var delta_y: float = event.position.y - _list_drag_last_y
		$FullListScroll.scroll_vertical -= int(delta_y)
		_list_drag_total += abs(delta_y)
		_list_drag_last_y = event.position.y
		$FullListScroll.accept_event()

# ============================================================
# 蜈ｨ譖ｲ繝ｪ繧ｹ繝域ｧ狗ｯ・# ============================================================
func _build_full_list() -> void:
	var vbox: VBoxContainer = $FullListScroll/FullListVBox
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	_full_list_row_nodes.clear()

	for i in range(ALL_BGM_LIST.size()):
		var entry: Dictionary = ALL_BGM_LIST[i]
		var file: String = entry["file"]
		var display_name: String = _get_display_name(file)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, ROW_H_FULL)
		btn.text = "  " + display_name
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = false
		btn.add_theme_font_size_override("font_size", 18)
		_apply_music_row_button_style(btn)
		_set_btn_text_color(btn, Color(1.0, 0.94, 0.78))
		btn.pressed.connect(_on_full_list_row_pressed.bind(i))
		btn.gui_input.connect(_on_full_list_row_gui_input)
		vbox.add_child(btn)

		_full_list_row_nodes.append({
			"button": btn,
			"file": file,
		})

func _on_full_list_row_gui_input(event: InputEvent) -> void:
	_on_full_list_scroll_gui_input(event)

# ============================================================
# 繝励Ξ繧､繝ｪ繧ｹ繝域ｧ狗ｯ・# ============================================================
func _set_btn_text_color(btn: Button, color: Color) -> void:
	btn.add_theme_color_override("font_color",         color)
	btn.add_theme_color_override("font_hover_color",   color)
	btn.add_theme_color_override("font_pressed_color", color)
	btn.add_theme_color_override("font_focus_color",   color)

# ============================================================
# 陦ｨ遉ｺ蜷榊叙蠕・# ============================================================
func _get_display_name(file: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_names: Dictionary = LOCALIZED_TRACK_NAMES.get(locale, {})
	if localized_names.has(file):
		return str(localized_names[file])
	for entry in ALL_BGM_LIST:
		if entry["file"] == file:
			return entry["name"]
	return file

func _get_selected_file() -> String:
	if _full_list_selected_index < 0 or _full_list_selected_index >= _full_list_row_nodes.size():
		return ""
	var entry: Dictionary = _full_list_row_nodes[_full_list_selected_index]
	return str(entry["file"])

func _get_jacket_path(file: String) -> String:
	return str(JACKET_PATHS.get(file, ""))

# ============================================================
# 蜈ｨ譖ｲ繝ｪ繧ｹ繝茨ｼ夊｡後ち繝・・
# ============================================================
func _on_full_list_row_pressed(index: int) -> void:
	if _list_drag_total > 8.0:
		return
	AudioManager.play_se("se_btntap")
	_full_list_selected_index = index
	_update_visuals()
	if _player_state == "idle":
		_update_track_name_display()

# ============================================================
# 繝励Ξ繧､繝ｪ繧ｹ繝茨ｼ壼炎髯､
# ============================================================
func _on_btn_play_pressed() -> void:
	AudioManager.play_se("se_btntap")

	if _player_state == "paused":
		AudioManager.bgm_player.stream_paused = false
		_player_state = "playing"
		_update_visuals()
		_update_track_name_display()
		return

	if _player_state == "playing":
		return

	var selected_file := _get_selected_file()
	if selected_file == "":
		return
	_play_source = "full_list"
	_current_playing_file = selected_file
	AudioManager.play_bgm_once(_current_playing_file)
	_player_state = "playing"

	_update_visuals()
	_update_track_name_display()
func _on_btn_pause_pressed() -> void:
	AudioManager.play_se("se_btntap")
	if _player_state == "playing":
		AudioManager.bgm_player.stream_paused = true
		_player_state = "paused"
		_update_visuals()
		_update_track_name_display()

func _on_btn_stop_pressed() -> void:
	AudioManager.play_se("se_btntap")
	_stop_playback()

func _stop_playback() -> void:
	AudioManager.stop_bgm()
	_player_state = "idle"
	_play_source = ""
	_current_playing_file = ""
	_update_visuals()
	_update_track_name_display()

# ============================================================
# 蜀咲函邨ゆｺ・ワ繝ｳ繝峨Λ
# ============================================================
func _on_bgm_finished() -> void:
	if _player_state != "playing":
		return  # 荳譎ょ●豁｢荳ｭ縺ｾ縺溘・idle縺ｧ縺ｯ菴輔ｂ縺励↑縺・
	if SaveData.music_repeat_one and _current_playing_file != "":
		AudioManager.play_bgm_once(_current_playing_file)
		_update_visuals()
		_update_track_name_display()
		return
	if _play_source == "full_list":
		# 蜈ｨ譖ｲ繝ｪ繧ｹ繝医Δ繝ｼ繝会ｼ夂ｵゆｺ・〒蛛懈ｭ｢
		_stop_playback()
	else:
		_stop_playback()

# ============================================================
# 譖ｲ蜷崎｡ｨ遉ｺ譖ｴ譁ｰ
# ============================================================
func _update_track_name_display() -> void:
	var label: Label = $PlayerPanel/TrackNameLabel
	var display_file := _current_playing_file
	if display_file == "":
		display_file = _get_selected_file()
	var display_name := _get_display_name(display_file) if display_file != "" else ""
	var jacket_path := _get_jacket_path(display_file)
	if _jacket_rect != null:
		if jacket_path != "" and ResourceLoader.exists(jacket_path):
			_jacket_rect.texture = load(jacket_path)
			_jacket_rect.visible = true
			if _jacket_fallback_label != null:
				_jacket_fallback_label.visible = false
		else:
			_jacket_rect.texture = null
			_jacket_rect.visible = false
			if _jacket_fallback_label != null:
				_jacket_fallback_label.text = display_name
				_jacket_fallback_label.visible = display_name != ""
	if _status_label != null:
		if _player_state == "playing":
			_status_label.text = "NOW PLAYING"
		elif _player_state == "paused":
			_status_label.text = "PAUSED"
		else:
			_status_label.text = ""
	if _player_state == "idle" or _current_playing_file == "":
		label.text = "繝ｼ"
	else:
		var prefix: String = ""
		if _player_state == "paused":
			prefix = "(荳譎ょ●豁｢) "
		label.text = prefix + "笙ｪ " + _get_display_name(_current_playing_file)

# ============================================================
# 繝上う繝ｩ繧､繝医・驕ｸ謚櫁｡ｨ遉ｺ譖ｴ譁ｰ
# ============================================================
func _update_visuals() -> void:
	for i in range(_full_list_row_nodes.size()):
		var node: Dictionary = _full_list_row_nodes[i]
		var btn: Button = node["button"]
		var is_currently_playing: bool = (_play_source == "full_list" and _player_state != "idle" and node["file"] == _current_playing_file)
		var is_selected: bool = i == _full_list_selected_index

		# modulate 縺ｯ鮟呈枚蟄励↓蜉ｹ縺九↑縺・◆繧・font_color 繧ｪ繝ｼ繝舌・繝ｩ繧､繝峨〒濶ｲ莉倥￠
		if is_currently_playing:
			_set_btn_text_color(btn, Color(1.0, 0.82, 0.35))
		elif is_selected:
			_set_btn_text_color(btn, Color(1.0, 0.86, 0.48))
		else:
			_set_btn_text_color(btn, Color(1.0, 0.94, 0.78))

# ============================================================
# 險ｭ螳壹・繧ｿ繝ｳ繝ｻ險ｭ螳壹・繝・・繧｢繝・・
# ============================================================
func _on_btn_settings_pressed() -> void:
	AudioManager.play_se("se_btntap")
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	_setup_music_settings()
	# 繝昴ャ繝励い繝・・繧帝幕縺丞燕縺ｫ迴ｾ蝨ｨ縺ｮ髻ｳ驥丞､繧偵せ繝ｩ繧､繝繝ｼ縺ｫ蜿肴丐
	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume
	if _repeat_one_check != null:
		_repeat_one_check.button_pressed = SaveData.music_repeat_one
	$SettingsPopup.visible = true

func _on_repeat_one_toggled(enabled: bool) -> void:
	AudioManager.play_se("se_btntap")
	SaveData.music_repeat_one = enabled
	SaveData.save()

func _on_bgm_slider_changed(value: float) -> void:
	# 繧ｹ繝ｩ繧､繝繝ｼ繧貞虚縺九☆縺ｨ繝ｪ繧｢繝ｫ繧ｿ繧､繝縺ｧBGM髻ｳ驥上↓蜿肴丐
	AudioManager.bgm_volume = value
	AudioManager.bgm_player.volume_db = linear_to_db(value)

func _on_se_slider_changed(value: float) -> void:
	# 繧ｹ繝ｩ繧､繝繝ｼ繧貞虚縺九☆縺ｨSE髻ｳ驥上↓蜿肴丐
	AudioManager.se_volume = value

func _on_language_button_pressed(code: String) -> void:
	SaveData.set_language_code(code)
	TranslationServer.set_locale(SaveData.language_code)
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	_setup_music_settings()
	_refresh_localized_music_images()
	_build_full_list()
	_update_track_name_display()
	_update_visuals()
	AudioManager.play_se("se_btntap")

func _on_btn_settings_close_pressed() -> void:
	$SettingsPopup.visible = false

# ============================================================
# 謌ｻ繧九・繧ｿ繝ｳ
# ============================================================
func _on_btn_back_pressed() -> void:
	AudioManager.play_se("se_btntap")
	AudioManager.stop_bgm()
	SaveData.save()
	GameState.came_from_ex = true
	get_tree().change_scene_to_file("res://StageSelect.tscn")
