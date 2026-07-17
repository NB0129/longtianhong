extends Control

const PopupSkin := preload("res://PopupSkin.gd")
const ButtonFeedback := preload("res://ButtonFeedback.gd")

const PATH_BG := "res://assets/ui/bg_top_generated.webp"
const PATH_LOGO := "res://assets/ui/matiate.webp"
const PATH_SUBTITLE := "res://assets/ui/tinitukuizu.webp"
const PATH_STORY := "res://assets/ui/title_btn_story.webp"
const PATH_IKINARI := "res://assets/ui/title_btn_instant.webp"
const PATH_RANKING := "res://assets/ui/title_btn_ranking.webp"
const PATH_HIGHSCORE := "res://assets/ui/haisukoa.webp"
const PATH_ICON_SETTINGS := "res://assets/bg/music_icon_settings_ui.webp"
const PATH_CREDIT_BUTTON := "res://assets/ui/title_btn_credit.webp"

const LANGUAGE_OPTIONS: Array[Dictionary] = [
	{"code": "ja", "label": "日本語"},
	{"code": "en", "label": "English"},
	{"code": "zh_CN", "label": "简体中文"},
	{"code": "zh_TW", "label": "繁體中文"},
	{"code": "ko", "label": "한국어"},
]

const SETTINGS_LABEL_COLOR := Color(0.10, 0.38, 0.32)
const SETTINGS_LABEL_OUTLINE := Color(1.0, 0.96, 0.82, 0.72)

const UI_TEXT := {
	"ja": {
		"settings_bgm": "BGM音量",
		"settings_se": "SE音量",
		"settings_tile": "牌の種類",
		"language": "Language",
		"credit": "企画・制作\n狼天紅ゲームズ\n\n原画・キャラクターデザイン\n椿式\n\nコーディング\nCodex\nClaude Code\n\nUI・ビジュアル制作\nAdobe Photoshop\nAdobe Firefly\nGPT Image\n\nBGM・サウンド制作\nSuno\n\nフォント\n刻明朝 Regular / Koku Mincho Regular\nCopyright (c) freefontnoki, Information-technology Promotion Agency, Japan (IPA)\nIPA Font License Agreement v1.0\nライセンス全文: assets/font/IPA_Font_License_Agreement_v1.0.txt\n\n効果音協力\n効果音ラボ\n\nゲームエンジン\nGodot Engine\n\nGodot Engine License\n",
	},
	"en": {
		"settings_bgm": "BGM volume",
		"settings_se": "SE volume",
		"settings_tile": "Tile suit",
		"language": "Language",
		"credit": "Planning / Production\n狼天紅 games\n\nOriginal art / Character design\n椿式\n\nCoding\nCodex\nClaude Code\n\nUI / Visual production\nAdobe Photoshop\nAdobe Firefly\nGPT Image\n\nBGM / Sound production\nSuno\n\nFont\nKoku Mincho Regular\nCopyright (c) freefontnoki, Information-technology Promotion Agency, Japan (IPA)\nIPA Font License Agreement v1.0\nLicense text: assets/font/IPA_Font_License_Agreement_v1.0.txt\n\nSound effects\nSound Effect Lab\n\nGame engine\nGodot Engine\n\nGodot Engine License\n",
	},
	"zh_CN": {
		"settings_bgm": "BGM 音量",
		"settings_se": "SE 音量",
		"settings_tile": "牌面花色",
		"language": "Language",
		"credit": "企划 / 制作\n狼天红 games\n\n原画 / 角色设计\n椿式\n\n程序\nCodex\nClaude Code\n\nUI / 视觉制作\nAdobe Photoshop\nAdobe Firefly\nGPT Image\n\nBGM / 音效制作\nSuno\n\n字体\nKoku Mincho Regular\nCopyright (c) freefontnoki, Information-technology Promotion Agency, Japan (IPA)\nIPA Font License Agreement v1.0\n许可证全文: assets/font/IPA_Font_License_Agreement_v1.0.txt\n\n音效\nSound Effect Lab\n\n游戏引擎\nGodot Engine\n\nGodot Engine License\n",
	},
	"zh_TW": {
		"settings_bgm": "BGM 音量",
		"settings_se": "SE 音量",
		"settings_tile": "牌面花色",
		"language": "Language",
		"credit": "企劃 / 製作\n狼天紅 games\n\n原畫 / 角色設計\n椿式\n\n程式\nCodex\nClaude Code\n\nUI / 視覺製作\nAdobe Photoshop\nAdobe Firefly\nGPT Image\n\nBGM / 音效製作\nSuno\n\n字型\nKoku Mincho Regular\nCopyright (c) freefontnoki, Information-technology Promotion Agency, Japan (IPA)\nIPA Font License Agreement v1.0\n授權全文: assets/font/IPA_Font_License_Agreement_v1.0.txt\n\n音效\nSound Effect Lab\n\n遊戲引擎\nGodot Engine\n\nGodot Engine License\n",
	},
	"ko": {
		"settings_bgm": "BGM 볼륨",
		"settings_se": "SE 볼륨",
		"settings_tile": "패 종류",
		"language": "Language",
		"credit": "기획 / 제작\n狼天紅 games\n\n원화 / 캐릭터 디자인\n椿式\n\n코딩\nCodex\nClaude Code\n\nUI / 비주얼 제작\nAdobe Photoshop\nAdobe Firefly\nGPT Image\n\nBGM / 사운드 제작\nSuno\n\n폰트\nKoku Mincho Regular\nCopyright (c) freefontnoki, Information-technology Promotion Agency, Japan (IPA)\nIPA Font License Agreement v1.0\n라이선스 전문: assets/font/IPA_Font_License_Agreement_v1.0.txt\n\n효과음\nSound Effect Lab\n\n게임 엔진\nGodot Engine\n\nGodot Engine License\n",
	},
}

const HIGH_SCORE_DIGITS := 7
const HIGH_SCORE_DIGIT_H := 27.0
const HIGH_SCORE_DIGIT_SLOT_W := 23.0

var _ranking_frame: Control = null
var _logo: TextureRect = null
var _subtitle: TextureRect = null
var _brand_label: Label = null
var _high_score_panel: Panel = null
var _high_score_label: TextureRect = null
var _high_score_digits: HBoxContainer = null
var _credit_frame: Control = null
var _settings_overlay: Button = null
var _settings_scroll: ScrollContainer = null
var _settings_content: VBoxContainer = null
var _credit_overlay: Button = null
var _credit_popup: Panel = null
var _credit_scroll: ScrollContainer = null
var _language_buttons: Dictionary = {}
var _credit_dragging: bool = false
var _credit_last_drag_y: float = 0.0
var _settings_dragging: bool = false
var _settings_last_drag_y: float = 0.0


func _ready() -> void:
	AudioManager.play_bgm("bgm_t_title")
	_setup_background()
	_ensure_title_nodes()
	_setup_image_button($StoryFrame, $StoryFrame/StoryImg, $StoryFrame/BtnStory, PATH_STORY)
	_setup_image_button($InstantFrame, $InstantFrame/InstantImg, $InstantFrame/BtnInstant, PATH_IKINARI)
	_setup_ranking_button()
	_setup_instant_high_score_display()
	_setup_settings_button()
	_setup_settings_popup()
	_setup_language_controls()
	_setup_credit_button()
	_setup_credit_popup()
	_apply_title_language()
	_layout_title()
	_sync_settings_sliders()
	ButtonFeedback.install(self)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		_layout_title()


func _input(event: InputEvent) -> void:
	if $SettingsPopup.visible and _settings_scroll != null and (event is InputEventScreenDrag or (_settings_dragging and event is InputEventMouseMotion)):
		_handle_drag_scroll(event, _settings_scroll, true)
	if _credit_popup != null and _credit_popup.visible and _credit_scroll != null and (event is InputEventScreenDrag or (_credit_dragging and event is InputEventMouseMotion)):
		_handle_drag_scroll(event, _credit_scroll, false)


func _setup_background() -> void:
	if ResourceLoader.exists(PATH_BG):
		$BG.texture = load(PATH_BG)
	$BG.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$BG.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED


func _ensure_title_nodes() -> void:
	_brand_label = get_node_or_null("BrandLabel") as Label
	if _brand_label != null:
		_brand_label.text = ""
		_brand_label.visible = false

	if not has_node("TitleLogo"):
		var logo: TextureRect = TextureRect.new()
		logo.name = "TitleLogo"
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(logo)
	_logo = $TitleLogo
	if ResourceLoader.exists(PATH_LOGO):
		_logo.texture = load(PATH_LOGO)

	if not has_node("SubtitleLogo"):
		var subtitle: TextureRect = TextureRect.new()
		subtitle.name = "SubtitleLogo"
		subtitle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		subtitle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(subtitle)
	_subtitle = $SubtitleLogo
	if ResourceLoader.exists(PATH_SUBTITLE):
		_subtitle.texture = load(PATH_SUBTITLE)


func _set_texture(rect: TextureRect, path: String) -> void:
	if rect == null:
		return
	if ResourceLoader.exists(path):
		rect.texture = load(path)


func _localized_title_path(file_base: String, fallback_path: String) -> String:
	var locale: String = SaveData.normalize_language_code(SaveData.language_code)
	var normalized_path: String = "res://assets/language/normalized/" + locale + "/" + file_base + ".webp"
	if ResourceLoader.exists(normalized_path):
		return normalized_path
	if locale == "ja":
		return fallback_path
	var path: String = "res://assets/language/" + locale + "/" + file_base + ".webp"
	if ResourceLoader.exists(path):
		return path
	return fallback_path


func _apply_title_language() -> void:
	var locale: String = SaveData.normalize_language_code(SaveData.language_code)
	TranslationServer.set_locale(locale)
	_set_texture(_logo, _localized_title_path("matiate", PATH_LOGO))
	_set_texture(_subtitle, _localized_title_path("tinitukuizu", PATH_SUBTITLE))
	_set_texture($StoryFrame/StoryImg, _localized_title_path("title_btn_story", PATH_STORY))
	_set_texture($InstantFrame/InstantImg, _localized_title_path("title_btn_instant", PATH_IKINARI))
	if _ranking_frame != null and _ranking_frame.has_node("RankingImg"):
		_set_texture(_ranking_frame.get_node("RankingImg"), _localized_title_path("title_btn_ranking", PATH_RANKING))
	if _credit_frame != null and _credit_frame.has_node("CreditImg"):
		_set_texture(_credit_frame.get_node("CreditImg"), _localized_title_path("title_btn_credit", PATH_CREDIT_BUTTON))
	_set_texture(_high_score_label, _localized_title_path("haisukoa", PATH_HIGHSCORE))
	_apply_text_language()
	_layout_title()


func _text_value(key: String) -> String:
	var locale: String = SaveData.normalize_language_code(SaveData.language_code)
	var dict: Dictionary = UI_TEXT.get(locale, UI_TEXT["ja"])
	return str(dict.get(key, UI_TEXT["ja"].get(key, "")))


func _apply_text_language() -> void:
	if _settings_content != null:
		_set_label_text("LabelBgm", _text_value("settings_bgm"))
		_set_label_text("LabelSe", _text_value("settings_se"))
		_set_label_text("LabelTileSuit", _text_value("settings_tile"))
		_set_label_text("LabelLanguage", _text_value("language"))
		var grid := _settings_content.get_node_or_null("TileSuitGrid")
		if grid != null:
			for button_name in ["BtnPinzu", "BtnSouzu", "BtnManzu", "BtnManzu2"]:
				_set_button_text(grid, button_name, "")
	if _credit_popup != null and _credit_popup.has_node("VBox/CreditScroll/CreditBody"):
		var body := _credit_popup.get_node("VBox/CreditScroll/CreditBody") as Label
		body.text = _make_credit_text()


func _set_label_text(node_name: String, value: String) -> void:
	var label := _settings_content.get_node_or_null(node_name) as Label
	if label != null:
		label.text = value


func _set_button_text(parent: Node, node_name: String, value: String) -> void:
	var button := parent.get_node_or_null(node_name) as Button
	if button != null:
		button.text = value


func _style_settings_label(label: Label, font_size: int) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", SETTINGS_LABEL_COLOR)
	label.add_theme_color_override("font_outline_color", SETTINGS_LABEL_OUTLINE)
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _setup_image_button(frame: Control, img: TextureRect, btn: Button, path: String) -> void:
	if ResourceLoader.exists(path):
		img.texture = load(path)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.flat = true
	btn.text = ""
	btn.focus_mode = Control.FOCUS_NONE
	ButtonFeedback.set_target(btn, img)


func _setup_ranking_button() -> void:
	if _ranking_frame == null or not is_instance_valid(_ranking_frame):
		if has_node("RankingFrame"):
			_ranking_frame = $RankingFrame
		else:
			_ranking_frame = Control.new()
			_ranking_frame.name = "RankingFrame"
			add_child(_ranking_frame)
			var img: TextureRect = TextureRect.new()
			img.name = "RankingImg"
			_ranking_frame.add_child(img)
			var btn: Button = Button.new()
			btn.name = "BtnRanking"
			btn.pressed.connect(_on_btn_ranking_pressed)
			_ranking_frame.add_child(btn)
	var ranking_img: TextureRect = _ranking_frame.get_node("RankingImg")
	var ranking_btn: Button = _ranking_frame.get_node("BtnRanking")
	_setup_image_button(_ranking_frame, ranking_img, ranking_btn, PATH_RANKING)


func _setup_instant_high_score_display() -> void:
	if has_node("InstantHighScorePanel"):
		$InstantHighScorePanel.queue_free()
	var panel: Panel = Panel.new()
	panel.name = "InstantHighScorePanel"
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.38)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	_high_score_panel = panel

	var label: TextureRect = TextureRect.new()
	label.name = "HighScoreLabel"
	label.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	label.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var high_score_path := _localized_title_path("haisukoa", PATH_HIGHSCORE)
	if ResourceLoader.exists(high_score_path):
		label.texture = load(high_score_path)
	panel.add_child(label)
	_high_score_label = label

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "HighScoreDigits"
	row.add_theme_constant_override("separation", 0)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(row)
	_high_score_digits = row
	_add_high_score_digits(row)


func _add_high_score_digits(row: HBoxContainer) -> void:
	for child in row.get_children():
		child.queue_free()
	var score_value: int = SaveData.get_high_score("endless")
	var score_text: String = str(clampi(score_value, 0, 9999999))
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


func _setup_settings_button() -> void:
	var btn: Button = $BtnSettings
	btn.text = ""
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(PATH_ICON_SETTINGS):
		btn.icon = load(PATH_ICON_SETTINGS)
	btn.expand_icon = true
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _setup_credit_button() -> void:
	if has_node("CreditFrame"):
		_credit_frame = $CreditFrame
	else:
		_credit_frame = Control.new()
		_credit_frame.name = "CreditFrame"
		add_child(_credit_frame)
		var img := TextureRect.new()
		img.name = "CreditImg"
		_credit_frame.add_child(img)
		var btn := Button.new()
		btn.name = "BtnCredit"
		btn.pressed.connect(_on_btn_credit_pressed)
		_credit_frame.add_child(btn)
	var credit_img: TextureRect = _credit_frame.get_node("CreditImg")
	var credit_btn: Button = _credit_frame.get_node("BtnCredit")
	if ResourceLoader.exists(PATH_CREDIT_BUTTON):
		credit_img.texture = load(PATH_CREDIT_BUTTON)
	credit_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	credit_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	credit_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credit_btn.text = ""
	credit_btn.flat = true
	credit_btn.focus_mode = Control.FOCUS_NONE
	ButtonFeedback.set_target(credit_btn, credit_img)


func _setup_settings_popup() -> void:
	if has_node("SettingsOverlay"):
		_settings_overlay = $SettingsOverlay
	else:
		_settings_overlay = Button.new()
		_settings_overlay.name = "SettingsOverlay"
		_settings_overlay.visible = false
		_settings_overlay.flat = true
		_settings_overlay.text = ""
		_settings_overlay.focus_mode = Control.FOCUS_NONE
		_settings_overlay.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		_settings_overlay.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		_settings_overlay.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		_settings_overlay.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		_settings_overlay.pressed.connect(_on_btn_settings_close_pressed)
		add_child(_settings_overlay)

	if has_node("SettingsPopup/VBox/BtnExitGame"):
		$SettingsPopup/VBox/BtnExitGame.queue_free()
	_refresh_settings_skin()


func _refresh_settings_skin() -> void:
	PopupSkin.apply_settings_popup($SettingsPopup)
	_ensure_settings_scroll_content()


func _ensure_settings_scroll_content() -> void:
	if not has_node("SettingsPopup/VBox"):
		return
	var root_vbox: VBoxContainer = $SettingsPopup/VBox
	_settings_scroll = root_vbox.get_node_or_null("SettingsScroll") as ScrollContainer
	var close_button := root_vbox.get_node_or_null("BtnSettingsClose")
	var close_spacer := root_vbox.get_node_or_null("SettingsCloseSpacer")
	if close_spacer != null:
		root_vbox.remove_child(close_spacer)
		close_spacer.queue_free()
		close_spacer = null
	if _settings_scroll != null:
		var old_content := _settings_scroll.get_node_or_null("SettingsContent") as VBoxContainer
		if old_content != null:
			for child in old_content.get_children():
				old_content.remove_child(child)
				root_vbox.add_child(child)
		root_vbox.remove_child(_settings_scroll)
		_settings_scroll.queue_free()
	_settings_scroll = null
	_settings_content = root_vbox
	_settings_content.mouse_filter = Control.MOUSE_FILTER_PASS
	_settings_content.add_theme_constant_override("separation", 7)
	if close_button != null:
		root_vbox.move_child(close_button, root_vbox.get_child_count() - 1)

	_layout_settings_content()


func _layout_settings_content() -> void:
	if _settings_content == null:
		return
	if _settings_content.has_node("LabelBgm"):
		var label_bgm := _settings_content.get_node("LabelBgm") as Label
		_style_settings_label(label_bgm, 22)
	if _settings_content.has_node("LabelSe"):
		var label_se := _settings_content.get_node("LabelSe") as Label
		_style_settings_label(label_se, 22)
	if _settings_content.has_node("LabelTileSuit"):
		var label_tile := _settings_content.get_node("LabelTileSuit") as Label
		_style_settings_label(label_tile, 18)
	if _settings_content.has_node("BgmSlider"):
		var bgm_slider := _settings_content.get_node("BgmSlider") as HSlider
		bgm_slider.custom_minimum_size = Vector2(250.0, 32.0)
		bgm_slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if _settings_content.has_node("SeSlider"):
		var se_slider := _settings_content.get_node("SeSlider") as HSlider
		se_slider.custom_minimum_size = Vector2(250.0, 32.0)
		se_slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if _settings_content.has_node("TileSuitGrid"):
		var grid := _settings_content.get_node("TileSuitGrid") as GridContainer
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 5)
	_apply_text_language()


func _sync_settings_sliders() -> void:
	if _settings_content == null:
		return
	if _settings_content.has_node("BgmSlider"):
		(_settings_content.get_node("BgmSlider") as HSlider).value = AudioManager.bgm_volume
	if _settings_content.has_node("SeSlider"):
		(_settings_content.get_node("SeSlider") as HSlider).value = AudioManager.se_volume


func _setup_language_controls() -> void:
	if _settings_content == null:
		_ensure_settings_scroll_content()
	if _settings_content == null:
		return
	var label := _settings_content.get_node_or_null("LabelLanguage") as Label
	if label == null:
		label = Label.new()
		label.name = "LabelLanguage"
		_settings_content.add_child(label)
	label.text = "Language"
	_style_settings_label(label, 18)
	label.custom_minimum_size = Vector2(0.0, 24.0)

	var grid := _settings_content.get_node_or_null("LanguageGrid") as GridContainer
	if grid == null:
		grid = GridContainer.new()
		grid.name = "LanguageGrid"
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 6)
		_settings_content.add_child(grid)
	grid.columns = 2
	grid.custom_minimum_size = Vector2(0.0, 118.0)

	_language_buttons.clear()
	var group := ButtonGroup.new()
	for option in LANGUAGE_OPTIONS:
		var code: String = option["code"]
		var button_name := "BtnLanguage" + code.replace("_", "")
		var button := grid.get_node_or_null(button_name) as CheckBox
		if button == null:
			var old_button := grid.get_node_or_null(button_name)
			if old_button != null:
				grid.remove_child(old_button)
				old_button.free()
			button = CheckBox.new()
			button.name = button_name
			button.focus_mode = Control.FOCUS_NONE
			button.pressed.connect(_on_language_button_pressed.bind(code))
			grid.add_child(button)
		button.button_group = group
		button.custom_minimum_size = Vector2(124.0, 36.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_color_override("font_color", Color(0.30, 0.18, 0.09))
		button.add_theme_color_override("font_hover_color", Color(0.30, 0.18, 0.09))
		button.add_theme_color_override("font_pressed_color", Color(0.30, 0.18, 0.09))
		button.add_theme_color_override("font_outline_color", SETTINGS_LABEL_OUTLINE)
		button.add_theme_constant_override("outline_size", 3)
		_language_buttons[code] = button
	var close_button := _settings_content.get_node_or_null("BtnSettingsClose") as Button
	if close_button != null:
		_settings_content.move_child(close_button, _settings_content.get_child_count() - 1)
	_refresh_language_buttons()


func _refresh_language_buttons() -> void:
	var current: String = SaveData.normalize_language_code(SaveData.language_code)
	for option in LANGUAGE_OPTIONS:
		var code: String = option["code"]
		if not _language_buttons.has(code):
			continue
		var button := _language_buttons[code] as CheckBox
		button.text = str(option["label"])
		button.set_pressed_no_signal(code == current)
		button.modulate = Color(1.0, 0.92, 0.72, 1.0) if code == current else Color(1.0, 1.0, 1.0, 1.0)


func _setup_credit_popup() -> void:
	if has_node("CreditOverlay"):
		_credit_overlay = $CreditOverlay
	else:
		_credit_overlay = Button.new()
		_credit_overlay.name = "CreditOverlay"
		_credit_overlay.visible = false
		_credit_overlay.flat = true
		_credit_overlay.text = ""
		_credit_overlay.focus_mode = Control.FOCUS_NONE
		_credit_overlay.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		_credit_overlay.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		_credit_overlay.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		_credit_overlay.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		_credit_overlay.pressed.connect(_on_btn_credit_close_pressed)
		add_child(_credit_overlay)

	if has_node("CreditPopup"):
		_credit_popup = $CreditPopup
	else:
		_credit_popup = Panel.new()
		_credit_popup.name = "CreditPopup"
		_credit_popup.visible = false
		add_child(_credit_popup)
		var vbox := VBoxContainer.new()
		vbox.name = "VBox"
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		_credit_popup.add_child(vbox)
		var scroll := ScrollContainer.new()
		scroll.name = "CreditScroll"
		scroll.follow_focus = true
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.gui_input.connect(_on_credit_scroll_gui_input)
		vbox.add_child(scroll)
		var body := Label.new()
		body.name = "CreditBody"
		body.text = _make_credit_text()
		body.mouse_filter = Control.MOUSE_FILTER_IGNORE
		scroll.add_child(body)
		var close_button := Button.new()
		close_button.name = "BtnCreditClose"
		close_button.pressed.connect(_on_btn_credit_close_pressed)
		vbox.add_child(close_button)
	_credit_scroll = _credit_popup.get_node("VBox/CreditScroll")
	PopupSkin.apply_credit_popup(_credit_popup)


func _layout_title() -> void:
	if _logo == null or _subtitle == null or _ranking_frame == null or _high_score_panel == null or _credit_frame == null or _settings_overlay == null or _credit_overlay == null or _credit_popup == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	var center_x: float = vp.x * 0.5
	var safe_w: float = minf(vp.x * 0.86, 380.0)

	if _brand_label != null:
		_brand_label.visible = false

	var logo_w: float = minf(vp.x * 0.98, 516.0)
	var logo_h: float = logo_w * 0.40
	_logo.size = Vector2(logo_w, logo_h)
	_logo.position = Vector2(center_x - logo_w * 0.5, vp.y * 0.08)

	var subtitle_w: float = minf(vp.x * 0.98, 450.0)
	var subtitle_h: float = subtitle_w * 0.40
	_subtitle.size = Vector2(subtitle_w, subtitle_h)
	_subtitle.position = Vector2(center_x - subtitle_w * 0.5, _logo.position.y + logo_h * 0.48)

	var button_w: float = safe_w
	var button_h: float = minf(button_w * 0.32, 104.0)
	var button_gap: float = maxf(vp.y * 0.015, 12.0)
	var buttons_total_h: float = button_h * 3.0 + button_gap * 2.0
	var button_top: float = vp.y * 0.47
	if button_top + buttons_total_h > vp.y * 0.75:
		button_top = vp.y * 0.75 - buttons_total_h

	_layout_button_frame($StoryFrame, center_x, button_top, button_w, button_h)
	_layout_button_frame($InstantFrame, center_x, button_top + button_h + button_gap, button_w, button_h)
	_layout_button_frame(_ranking_frame, center_x, button_top + (button_h + button_gap) * 2.0, button_w, button_h)

	var score_panel_w: float = minf(vp.x * 0.72, 330.0)
	var score_panel_h: float = 76.0
	var score_y: float = button_top + buttons_total_h + maxf(vp.y * 0.024, 18.0)
	if score_y + score_panel_h > vp.y - 138.0:
		score_y = vp.y - 138.0 - score_panel_h
	_high_score_panel.size = Vector2(score_panel_w, score_panel_h)
	_high_score_panel.position = Vector2(center_x - score_panel_w * 0.5, score_y)
	var label_w: float = score_panel_w * 0.62
	_high_score_label.size = Vector2(label_w, 34.0)
	_high_score_label.position = Vector2((score_panel_w - label_w) * 0.5, 8.0)
	var digits_w: float = HIGH_SCORE_DIGIT_SLOT_W * HIGH_SCORE_DIGITS
	_high_score_digits.size = Vector2(digits_w, HIGH_SCORE_DIGIT_H)
	_high_score_digits.custom_minimum_size = _high_score_digits.size
	_high_score_digits.position = Vector2((score_panel_w - digits_w) * 0.5, 42.0)

	var settings_size: float = 120.0
	$BtnSettings.size = Vector2(settings_size, settings_size)
	$BtnSettings.custom_minimum_size = $BtnSettings.size
	$BtnSettings.position = Vector2(vp.x - settings_size - 12.0, vp.y - settings_size - 12.0)
	_layout_credit_button(settings_size, vp)
	_settings_overlay.position = Vector2.ZERO
	_settings_overlay.size = vp
	_settings_overlay.custom_minimum_size = vp
	_credit_overlay.position = Vector2.ZERO
	_credit_overlay.size = vp
	_credit_overlay.custom_minimum_size = vp
	PopupSkin.apply_credit_popup(_credit_popup)


func _layout_button_frame(frame: Control, center_x: float, y: float, w: float, h: float) -> void:
	frame.size = Vector2(w, h)
	frame.position = Vector2(center_x - w * 0.5, y)
	var img: TextureRect = frame.get_child(0) as TextureRect
	var btn: Button = frame.get_child(1) as Button
	img.position = Vector2.ZERO
	img.size = frame.size
	btn.position = Vector2.ZERO
	btn.size = frame.size
	btn.custom_minimum_size = frame.size


func _layout_credit_button(size: float, vp: Vector2) -> void:
	_credit_frame.size = Vector2(size, size)
	_credit_frame.position = Vector2(12.0, vp.y - size - 12.0)
	var img: TextureRect = _credit_frame.get_node("CreditImg")
	var btn: Button = _credit_frame.get_node("BtnCredit")
	img.position = Vector2.ZERO
	img.size = _credit_frame.size
	btn.position = Vector2.ZERO
	btn.size = _credit_frame.size
	btn.custom_minimum_size = _credit_frame.size


func _make_credit_text() -> String:
	var godot_license := Engine.get_license_text()
	return _text_value("credit") + godot_license


func _on_btn_story_pressed() -> void:
	get_tree().change_scene_to_file("res://StageSelect.tscn")


func _on_btn_instant_pressed() -> void:
	GameState.came_from_stage3 = false
	GameState.came_from_ex = false
	GameState.current_stage = "endless"
	GameState.endless_block = 0
	GameState.endless_total_question = 0
	GameState.is_instant_mode = true
	GameState.reset_run_score()
	get_tree().change_scene_to_file("res://game.tscn")


func _on_btn_ranking_pressed() -> void:
	RankingManager.show_leaderboard()


func _on_btn_settings_pressed() -> void:
	_refresh_settings_skin()
	_sync_settings_sliders()
	_refresh_language_buttons()
	_settings_overlay.visible = true
	$SettingsPopup.visible = true
	_settings_overlay.move_to_front()
	$SettingsPopup.move_to_front()


func _on_btn_settings_close_pressed() -> void:
	_settings_overlay.visible = false
	$SettingsPopup.visible = false
	_settings_dragging = false


func _on_btn_credit_pressed() -> void:
	_apply_text_language()
	_credit_overlay.visible = true
	_credit_popup.visible = true
	_credit_overlay.move_to_front()
	_credit_popup.move_to_front()


func _on_btn_credit_close_pressed() -> void:
	_credit_overlay.visible = false
	_credit_popup.visible = false
	_credit_dragging = false


func _on_settings_scroll_gui_input(event: InputEvent) -> void:
	_handle_drag_scroll(event, _settings_scroll, true)


func _handle_drag_scroll(event: InputEvent, scroll: ScrollContainer, is_settings: bool) -> void:
	if scroll == null:
		return
	var global_rect := Rect2(scroll.global_position, scroll.size)
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not global_rect.has_point(touch.position):
			return
		if is_settings:
			_settings_dragging = touch.pressed
			_settings_last_drag_y = touch.position.y
		else:
			_credit_dragging = touch.pressed
			_credit_last_drag_y = touch.position.y
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if not global_rect.has_point(drag.position):
			return
		scroll.scroll_vertical = maxi(0, scroll.scroll_vertical - int(drag.relative.y))
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index != MOUSE_BUTTON_LEFT:
			return
		if not global_rect.has_point(button.position):
			return
		if is_settings:
			_settings_dragging = button.pressed
			_settings_last_drag_y = button.position.y
		else:
			_credit_dragging = button.pressed
			_credit_last_drag_y = button.position.y
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if is_settings:
			if not _settings_dragging:
				return
			var delta_y_settings := motion.position.y - _settings_last_drag_y
			scroll.scroll_vertical = maxi(0, scroll.scroll_vertical - int(delta_y_settings))
			_settings_last_drag_y = motion.position.y
		else:
			if not _credit_dragging:
				return
			var delta_y_credit := motion.position.y - _credit_last_drag_y
			scroll.scroll_vertical = maxi(0, scroll.scroll_vertical - int(delta_y_credit))
			_credit_last_drag_y = motion.position.y
		get_viewport().set_input_as_handled()


func _on_credit_scroll_gui_input(event: InputEvent) -> void:
	if _credit_scroll == null:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		_credit_dragging = touch.pressed
		_credit_last_drag_y = touch.position.y
		_credit_scroll.accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_credit_scroll.scroll_vertical = maxi(0, _credit_scroll.scroll_vertical - int(drag.relative.y))
		_credit_scroll.accept_event()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT:
			_credit_dragging = button.pressed
			_credit_last_drag_y = button.position.y
			_credit_scroll.accept_event()
	elif event is InputEventMouseMotion and _credit_dragging:
		var motion := event as InputEventMouseMotion
		var delta_y := motion.position.y - _credit_last_drag_y
		_credit_scroll.scroll_vertical = maxi(0, _credit_scroll.scroll_vertical - int(delta_y))
		_credit_last_drag_y = motion.position.y
		_credit_scroll.accept_event()


func _on_btn_exit_game_pressed() -> void:
	get_tree().quit()


func _on_bgm_slider_changed(value: float) -> void:
	AudioManager.bgm_volume = value
	AudioManager.bgm_player.volume_db = linear_to_db(value)


func _on_se_slider_changed(value: float) -> void:
	AudioManager.se_volume = value


func _on_language_button_pressed(code: String) -> void:
	SaveData.set_language_code(code)
	_apply_title_language()
	_refresh_settings_skin()
	_setup_language_controls()
	_refresh_language_buttons()
