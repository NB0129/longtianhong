extends Control

const PATH_BG            := "res://assets/bg/bg_rogotai.webp"
const PATH_STORY         := "res://assets/bg/story2.webp"
const PATH_IKINARI       := "res://assets/bg/ikinari2.webp"
const PATH_ICON_SETTINGS := "res://assets/bg/icon_settei.webp"

func _ready() -> void:
	AudioManager.play_bgm("bgm_t_title")
	if ResourceLoader.exists(PATH_BG):
		var tex: Texture2D = load(PATH_BG)
		var img: Image = tex.get_image()
		img.resize(480, 854, Image.INTERPOLATE_BILINEAR)
		$BG.texture = ImageTexture.create_from_image(img)
	_setup_story_button()
	_setup_instant_button()
	_setup_settings_button()
	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume

# ============================================================
# ストーリーモードボタン
# ============================================================
func _setup_story_button() -> void:
	if ResourceLoader.exists(PATH_STORY):
		$StoryFrame/StoryImg.texture = load(PATH_STORY)
	$StoryFrame/StoryImg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$StoryFrame/StoryImg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$StoryFrame/BtnStory.flat = true
	$StoryFrame/BtnStory.text = ""

# ============================================================
# いきなりゲームモードボタン
# ============================================================
func _setup_instant_button() -> void:
	if ResourceLoader.exists(PATH_IKINARI):
		$InstantFrame/InstantImg.texture = load(PATH_IKINARI)
	$InstantFrame/InstantImg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$InstantFrame/InstantImg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$InstantFrame/BtnInstant.flat = true
	$InstantFrame/BtnInstant.text = ""

# ============================================================
# 設定ボタン
# ============================================================
func _setup_settings_button() -> void:
	var btn := $BtnSettings
	btn.text = ""
	btn.flat = true
	if ResourceLoader.exists(PATH_ICON_SETTINGS):
		btn.icon = load(PATH_ICON_SETTINGS)
	btn.expand_icon = true
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

# ============================================================
# ボタン処理
# ============================================================
func _on_btn_story_pressed() -> void:
	get_tree().change_scene_to_file("res://StageSelect.tscn")

func _on_btn_instant_pressed() -> void:
	GameState.came_from_stage3 = false
	GameState.came_from_ex = false
	GameState.current_stage = "endless"
	GameState.endless_block = 0
	GameState.endless_total_question = 0
	GameState.is_instant_mode = true
	get_tree().change_scene_to_file("res://Game.tscn")

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
