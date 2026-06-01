extends Control

# ============================================================
# 全曲リスト（表示順）
# ============================================================
const ALL_BGM_LIST: Array = [
	{"file": "bgm_yume_main",              "name": "リーチの歌"},
	{"file": "bgm_yume_jantou",            "name": "雀頭を探して"},
	{"file": "bgm_yume_barabara",          "name": "配牌がバラバラ！"},
	{"file": "bgm_utu_higakureru",         "name": "日が暮れちゃう♡"},
	{"file": "bgm_utu_zakozako",           "name": "ざこざこおにいちゃん♡"},
	{"file": "bgm_utu_matigai",            "name": "あれ、間違ってるよ♡"},
	{"file": "bgm_utu_nochan",             "name": "ノーミスでクリアして♡"},
	{"file": "bgm_utu_kotaewo",            "name": "答えを教えてあげる♡"},
	{"file": "bgm_utu_syogakusei",         "name": "小学生れべる♡"},
	{"file": "bgm_mabo_first_2tunoboketu", "name": "二つの墓穴"},
	{"file": "bgm_mabo_first_appaku",      "name": "圧迫問答"},
	{"file": "bgm_mabo_first_nebumi",      "name": "値踏みの視線"},
	{"file": "bgm_mabo_second_kougetu",    "name": "紅月の狼"},
	{"file": "bgm_mabo_second_ginniro",    "name": "銀色の影"},
	{"file": "bgm_mabo_second_inisie",     "name": "古の英雄"},
	{"file": "bgm_mabo_mugen",             "name": "無限の決闘"},
	{"file": "bgm_gameover_mou",           "name": "ゲームオーバーの歌"},
	{"file": "bgm_t_sentaku",              "name": "ステージ選択"},
	{"file": "bgm_t_title",                "name": "タイトルBGM"},
]

const PATH_BG_MUSIC   := "res://assets/bg/bg_music.webp"
const ICON_SETTINGS   := "res://assets/bg/icon_settei.webp"

const ROW_H_FULL: float = 50.0
const ROW_H_PLAY: float = 48.0

# 状態
var _full_list_selected_index: int = 0
var _player_state: String = "idle"  # idle, playing, paused
var _play_source: String = ""       # "" / "full_list" / "playlist"
var _current_playing_file: String = ""
var _playlist_play_index: int = 0
var _shuffle_order: Array = []
var _shuffle_pos: int = 0

# 動的ノード参照
var _full_list_row_nodes: Array = []
var _playlist_row_nodes: Array = []

# ============================================================
# 初期化
# ============================================================
func _ready() -> void:
	if ResourceLoader.exists(PATH_BG_MUSIC):
		$BG.texture = load(PATH_BG_MUSIC)

	_set_screen_keep_on(true)

	AudioManager.stop_bgm()

	_build_full_list()
	_build_playlist()

	_full_list_selected_index = 0

	if not AudioManager.bgm_player.finished.is_connected(_on_bgm_finished):
		AudioManager.bgm_player.finished.connect(_on_bgm_finished)

	_update_visuals()
	_update_track_name_display()
	_update_play_mode_button_text()

	# 設定ボタンにアイコン画像を設定
	if ResourceLoader.exists(ICON_SETTINGS):
		$BtnSettings.icon = load(ICON_SETTINGS)
	$BtnSettings.expand_icon = true

	# 設定ポップアップは最初は非表示
	$SettingsPopup.visible = false

func _exit_tree() -> void:
	if AudioManager.bgm_player.finished.is_connected(_on_bgm_finished):
		AudioManager.bgm_player.finished.disconnect(_on_bgm_finished)
	_set_screen_keep_on(false)

func _set_screen_keep_on(enable: bool) -> void:
	if DisplayServer.has_method("screen_set_keep_on"):
		DisplayServer.screen_set_keep_on(enable)

# ============================================================
# 全曲リスト構築
# ============================================================
func _build_full_list() -> void:
	var vbox: VBoxContainer = $FullListScroll/FullListVBox
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	_full_list_row_nodes.clear()

	for i in range(ALL_BGM_LIST.size()):
		var entry: Dictionary = ALL_BGM_LIST[i]
		var file: String = entry["file"]
		var display_name: String = entry["name"]
		var locked: bool = not SaveData.is_bgm_unlocked(file)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, ROW_H_FULL)
		if locked:
			btn.text = "  " + display_name + "  （未解放）"
		else:
			btn.text = "  " + display_name
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		btn.add_theme_font_size_override("font_size", 18)
		# 白背景に合わせてテキストを黒に初期設定
		_set_btn_text_color(btn, Color.BLACK)
		btn.pressed.connect(_on_full_list_row_pressed.bind(i))
		vbox.add_child(btn)

		_full_list_row_nodes.append({
			"button": btn,
			"locked": locked,
			"file": file,
		})

# ============================================================
# プレイリスト構築
# ============================================================
func _build_playlist() -> void:
	var vbox: VBoxContainer = $PlaylistScroll/PlaylistVBox
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	_playlist_row_nodes.clear()

	for i in range(SaveData.music_playlist.size()):
		var file: String = SaveData.music_playlist[i]
		var display_name: String = _get_display_name(file)

		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, ROW_H_PLAY)
		row.add_theme_constant_override("separation", 4)
		vbox.add_child(row)

		var label := Label.new()
		label.text = "  " + display_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)
		# 白背景に合わせてテキストを黒に設定
		label.add_theme_color_override("font_color", Color.BLACK)
		row.add_child(label)

		var btn_del := Button.new()
		btn_del.text = "削除"
		btn_del.custom_minimum_size = Vector2(60, ROW_H_PLAY)
		btn_del.add_theme_font_size_override("font_size", 16)
		btn_del.pressed.connect(_on_playlist_delete_pressed.bind(i))
		row.add_child(btn_del)

		var btn_up := Button.new()
		btn_up.text = "↑"
		btn_up.custom_minimum_size = Vector2(40, ROW_H_PLAY)
		btn_up.add_theme_font_size_override("font_size", 18)
		btn_up.pressed.connect(_on_playlist_up_pressed.bind(i))
		if i == 0:
			btn_up.disabled = true
		row.add_child(btn_up)

		var btn_down := Button.new()
		btn_down.text = "↓"
		btn_down.custom_minimum_size = Vector2(40, ROW_H_PLAY)
		btn_down.add_theme_font_size_override("font_size", 18)
		btn_down.pressed.connect(_on_playlist_down_pressed.bind(i))
		if i == SaveData.music_playlist.size() - 1:
			btn_down.disabled = true
		row.add_child(btn_down)

		_playlist_row_nodes.append({
			"row": row,
			"label": label,
			"file": file,
		})

# ============================================================
# ボタンのテキスト色を全状態まとめて設定するヘルパー
# ============================================================
func _set_btn_text_color(btn: Button, color: Color) -> void:
	btn.add_theme_color_override("font_color",         color)
	btn.add_theme_color_override("font_hover_color",   color)
	btn.add_theme_color_override("font_pressed_color", color)
	btn.add_theme_color_override("font_focus_color",   color)

# ============================================================
# 表示名取得
# ============================================================
func _get_display_name(file: String) -> String:
	for entry in ALL_BGM_LIST:
		if entry["file"] == file:
			return entry["name"]
	return file

# ============================================================
# 全曲リスト：行タップ
# ============================================================
func _on_full_list_row_pressed(index: int) -> void:
	AudioManager.play_se("se_btntap")
	_full_list_selected_index = index
	_update_visuals()

# ============================================================
# プレイリスト：削除
# ============================================================
func _on_playlist_delete_pressed(index: int) -> void:
	AudioManager.play_se("se_btntap")
	if index < 0 or index >= SaveData.music_playlist.size():
		return
	SaveData.music_playlist.remove_at(index)

	if _play_source == "playlist":
		if SaveData.music_playlist.is_empty():
			_stop_playback()
		else:
			if index < _playlist_play_index:
				_playlist_play_index -= 1
			if _playlist_play_index >= SaveData.music_playlist.size():
				_playlist_play_index = 0
			if SaveData.music_play_mode == "random":
				_shuffle_order = _generate_shuffle_order()
				_shuffle_pos = _shuffle_order.find(_playlist_play_index)
				if _shuffle_pos == -1:
					_shuffle_pos = 0

	_build_playlist()
	_update_visuals()

# ============================================================
# プレイリスト：上へ
# ============================================================
func _on_playlist_up_pressed(index: int) -> void:
	if index <= 0:
		return
	AudioManager.play_se("se_btntap")
	var item = SaveData.music_playlist[index]
	SaveData.music_playlist[index] = SaveData.music_playlist[index - 1]
	SaveData.music_playlist[index - 1] = item

	if _play_source == "playlist":
		if _playlist_play_index == index:
			_playlist_play_index = index - 1
		elif _playlist_play_index == index - 1:
			_playlist_play_index = index
		if SaveData.music_play_mode == "random":
			_shuffle_order = _generate_shuffle_order()
			_shuffle_pos = _shuffle_order.find(_playlist_play_index)
			if _shuffle_pos == -1:
				_shuffle_pos = 0

	_build_playlist()
	_update_visuals()

# ============================================================
# プレイリスト：下へ
# ============================================================
func _on_playlist_down_pressed(index: int) -> void:
	if index >= SaveData.music_playlist.size() - 1:
		return
	AudioManager.play_se("se_btntap")
	var item = SaveData.music_playlist[index]
	SaveData.music_playlist[index] = SaveData.music_playlist[index + 1]
	SaveData.music_playlist[index + 1] = item

	if _play_source == "playlist":
		if _playlist_play_index == index:
			_playlist_play_index = index + 1
		elif _playlist_play_index == index + 1:
			_playlist_play_index = index
		if SaveData.music_play_mode == "random":
			_shuffle_order = _generate_shuffle_order()
			_shuffle_pos = _shuffle_order.find(_playlist_play_index)
			if _shuffle_pos == -1:
				_shuffle_pos = 0

	_build_playlist()
	_update_visuals()

# ============================================================
# 追加ボタン
# ============================================================
func _on_btn_add_pressed() -> void:
	AudioManager.play_se("se_btntap")
	if _full_list_selected_index < 0 or _full_list_selected_index >= _full_list_row_nodes.size():
		return
	var entry: Dictionary = _full_list_row_nodes[_full_list_selected_index]
	if entry["locked"]:
		return  # 未解放曲は追加不可
	SaveData.music_playlist.append(entry["file"])

	if _play_source == "playlist" and SaveData.music_play_mode == "random":
		_shuffle_order = _generate_shuffle_order()
		_shuffle_pos = _shuffle_order.find(_playlist_play_index)
		if _shuffle_pos == -1:
			_shuffle_pos = 0

	_build_playlist()
	_update_visuals()

# ============================================================
# リセットボタン
# ============================================================
func _on_btn_reset_pressed() -> void:
	AudioManager.play_se("se_btntap")
	SaveData.music_playlist.clear()
	if _play_source == "playlist":
		_stop_playback()
	_build_playlist()
	_update_visuals()

# ============================================================
# 順次/ランダム切替
# ============================================================
func _on_btn_play_mode_pressed() -> void:
	AudioManager.play_se("se_btntap")
	if SaveData.music_play_mode == "sequential":
		SaveData.music_play_mode = "random"
	else:
		SaveData.music_play_mode = "sequential"

	if _play_source == "playlist" and SaveData.music_play_mode == "random":
		_shuffle_order = _generate_shuffle_order()
		_shuffle_pos = _shuffle_order.find(_playlist_play_index)
		if _shuffle_pos == -1:
			_shuffle_pos = 0

	_update_play_mode_button_text()

func _update_play_mode_button_text() -> void:
	if SaveData.music_play_mode == "random":
		$BtnPlayMode.text = "ランダム"
	else:
		$BtnPlayMode.text = "順次"

# ============================================================
# 再生・一時停止・停止
# ============================================================
func _on_btn_play_pressed() -> void:
	AudioManager.play_se("se_btntap")

	# 一時停止からの再開
	if _player_state == "paused":
		AudioManager.bgm_player.stream_paused = false
		_player_state = "playing"
		_update_visuals()
		_update_track_name_display()
		return

	# 既に再生中
	if _player_state == "playing":
		return

	# Idle → 新規再生
	if SaveData.music_playlist.is_empty():
		# 全曲リスト選択中の曲を再生
		if _full_list_selected_index < 0 or _full_list_selected_index >= _full_list_row_nodes.size():
			return
		var entry: Dictionary = _full_list_row_nodes[_full_list_selected_index]
		if entry["locked"]:
			return  # 未解放曲は再生不可
		_play_source = "full_list"
		_current_playing_file = entry["file"]
		AudioManager.play_bgm_once(_current_playing_file)
		_player_state = "playing"
	else:
		# プレイリスト再生（先頭から）
		_play_source = "playlist"
		if SaveData.music_play_mode == "random":
			_shuffle_order = _generate_shuffle_order()
			_shuffle_pos = 0
			_playlist_play_index = _shuffle_order[0]
		else:
			_playlist_play_index = 0
		_current_playing_file = SaveData.music_playlist[_playlist_play_index]
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
# 再生終了ハンドラ
# ============================================================
func _on_bgm_finished() -> void:
	if _player_state != "playing":
		return  # 一時停止中またはidleでは何もしない

	if _play_source == "full_list":
		# 全曲リストモード：終了で停止
		_stop_playback()
	elif _play_source == "playlist":
		if SaveData.music_playlist.is_empty():
			_stop_playback()
			return
		if SaveData.music_play_mode == "random":
			_shuffle_pos += 1
			if _shuffle_pos >= _shuffle_order.size():
				_shuffle_order = _generate_shuffle_order()
				_shuffle_pos = 0
			if _shuffle_pos >= _shuffle_order.size():
				_stop_playback()
				return
			_playlist_play_index = _shuffle_order[_shuffle_pos]
		else:
			# 順次：末尾→先頭ループ
			_playlist_play_index = (_playlist_play_index + 1) % SaveData.music_playlist.size()
		if _playlist_play_index < 0 or _playlist_play_index >= SaveData.music_playlist.size():
			_stop_playback()
			return
		_current_playing_file = SaveData.music_playlist[_playlist_play_index]
		AudioManager.play_bgm_once(_current_playing_file)
		_update_visuals()
		_update_track_name_display()

# ============================================================
# シャッフル順生成
# ============================================================
func _generate_shuffle_order() -> Array:
	var n: int = SaveData.music_playlist.size()
	var order: Array = []
	for i in range(n):
		order.append(i)
	order.shuffle()
	return order

# ============================================================
# 曲名表示更新
# ============================================================
func _update_track_name_display() -> void:
	var label: Label = $PlayerPanel/TrackNameLabel
	if _player_state == "idle" or _current_playing_file == "":
		label.text = "ー"
	else:
		var prefix: String = ""
		if _player_state == "paused":
			prefix = "(一時停止) "
		label.text = prefix + "♪ " + _get_display_name(_current_playing_file)

# ============================================================
# ハイライト・選択表示更新
# ============================================================
func _update_visuals() -> void:
	# 全曲リスト
	var hide_full_selection: bool = (_play_source == "playlist" and _player_state != "idle")
	for i in range(_full_list_row_nodes.size()):
		var node: Dictionary = _full_list_row_nodes[i]
		var btn: Button = node["button"]
		var locked: bool = node["locked"]
		var is_currently_playing: bool = (_play_source == "full_list" and _player_state != "idle" and node["file"] == _current_playing_file)
		var is_selected: bool = (not hide_full_selection) and (i == _full_list_selected_index)

		# modulate は黒文字に効かないため font_color オーバーライドで色付け
		if is_currently_playing:
			_set_btn_text_color(btn, Color(0.7, 0.4, 0.0))   # 再生中：濃いオレンジ
		elif is_selected:
			if locked:
				_set_btn_text_color(btn, Color(0.3, 0.4, 0.7))  # 選択中+未解放：スレートブルー
			else:
				_set_btn_text_color(btn, Color(0.0, 0.4, 0.8))  # 選択中：青
		elif locked:
			_set_btn_text_color(btn, Color(0.6, 0.6, 0.6))   # 未解放：グレー
		else:
			_set_btn_text_color(btn, Color.BLACK)             # 通常：黒

	# プレイリスト
	for i in range(_playlist_row_nodes.size()):
		var node: Dictionary = _playlist_row_nodes[i]
		var label: Label = node["label"]
		var is_currently_playing: bool = (
			_play_source == "playlist"
			and _player_state != "idle"
			and i == _playlist_play_index
			and i < SaveData.music_playlist.size()
			and SaveData.music_playlist[i] == _current_playing_file
		)
		if is_currently_playing:
			label.add_theme_color_override("font_color", Color(0.7, 0.4, 0.0))  # 再生中：濃いオレンジ
		else:
			label.add_theme_color_override("font_color", Color.BLACK)

# ============================================================
# 設定ボタン・設定ポップアップ
# ============================================================
func _on_btn_settings_pressed() -> void:
	AudioManager.play_se("se_btntap")
	# ポップアップを開く前に現在の音量値をスライダーに反映
	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume
	$SettingsPopup.visible = true

func _on_bgm_slider_changed(value: float) -> void:
	# スライダーを動かすとリアルタイムでBGM音量に反映
	AudioManager.bgm_volume = value
	AudioManager.bgm_player.volume_db = linear_to_db(value)

func _on_se_slider_changed(value: float) -> void:
	# スライダーを動かすとSE音量に反映
	AudioManager.se_volume = value

func _on_btn_settings_close_pressed() -> void:
	$SettingsPopup.visible = false

# ============================================================
# 戻るボタン
# ============================================================
func _on_btn_back_pressed() -> void:
	AudioManager.play_se("se_btntap")
	AudioManager.stop_bgm()
	SaveData.save()
	GameState.came_from_ex = true
	get_tree().change_scene_to_file("res://StageSelect.tscn")
