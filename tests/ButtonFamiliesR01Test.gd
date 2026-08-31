extends Control

const CUSTOM_SCENE := preload("res://custom.tscn")
const GAME_SCENE := preload("res://game.tscn")
const TITLE_SCENE := preload("res://title.tscn")
const PopupSkin := preload("res://PopupSkin.gd")

const PATH_START := "res://assets/ui/button_families_r01/custom_primary_start_204x54.png"
const PATH_BACK := "res://assets/ui/button_families_r01/custom_secondary_back_154x54.png"
const PATH_RESULT_BACK := "res://assets/ui/button_families_r02/result_back_compact_r02_170x62.png"
const PATH_CONFIRM := "res://assets/ui/button_families_r02/confirm_compact_r02_112x48.png"
const PATH_CLOSE := "res://assets/ui/button_families_r02/close_compact_r02_130x54.png"
const KAISEI_PATH := "res://assets/font/kaisei_decol_bold_700/KaiseiDecol-Bold.ttf"
const R02_LAYOUT_PATH := "res://assets/ui/button_families_r02/INK_LAYOUTS.json"
const R02_BINDING_RECEIPT_PATH := "res://assets/ui/button_families_r02/OWNER_RUNTIME_BINDING_RECEIPT.json"
const RESULT_EXACT4 := ["BtnRetry", "BtnHome", "BtnSubmitRanking", "BtnShowAnswer"]

const TEXT := {
	"ja": {"start": "ゲーム開始", "back": "戻る", "close": "閉じる", "yes": "はい", "no": "いいえ"},
	"en": {"start": "Start game", "back": "Back", "close": "Close", "yes": "Yes", "no": "No"},
	"zh_CN": {"start": "开始游戏", "back": "返回", "close": "关闭", "yes": "是", "no": "否"},
	"zh_TW": {"start": "開始遊戲", "back": "返回", "close": "關閉", "yes": "是", "no": "否"},
	"ko": {"start": "게임 시작", "back": "뒤로", "close": "닫기", "yes": "예", "no": "아니요"},
}

const R02_TUPLES := {
	"result_back": {"ja": [24, 63, 11], "en": [26, 53, 10], "zh_CN": [23, 62, 12], "zh_TW": [23, 62, 12], "ko": [23, 63, 12]},
	"confirm_yes": {"ja": [23, 32, 4], "en": [24, 35, 4], "zh_CN": [18, 46, 9], "zh_TW": [18, 46, 9], "ko": [18, 47, 9]},
	"confirm_no": {"ja": [19, 26, 7], "en": [23, 39, 5], "zh_CN": [19, 46, 7], "zh_TW": [19, 46, 7], "ko": [18, 30, 9]},
	"close": {"ja": [22, 32, 7], "en": [21, 35, 9], "zh_CN": [21, 43, 9], "zh_TW": [23, 41, 7], "ko": [22, 44, 8]},
}

var _failures := 0
var _saved_language := "ja"
var _custom: Control
var _game: Control
var _title: Control


func _ready() -> void:
	_saved_language = SaveData.language_code
	SaveData.language_code = "ja"
	_custom = CUSTOM_SCENE.instantiate() as Control
	_game = GAME_SCENE.instantiate() as Control
	_title = TITLE_SCENE.instantiate() as Control
	add_child(_custom)
	add_child(_game)
	add_child(_title)
	await get_tree().process_frame
	await get_tree().process_frame
	await _prepare_result_fixture()
	_validate_structure_and_callbacks()
	_validate_talk_shared_confirm_callsite()
	_validate_r02_assets_static()
	_validate_r02_receipts()
	for locale: String in TEXT:
		_validate_locale(locale)
	_restore()
	if _failures == 0:
		print("PASS button_families_r02 r01_custom=2 r02_roles=4 exact20=1 locales=5 exact4_unchanged=1 callbacks=1 focus=1")
	get_tree().quit(0 if _failures == 0 else 1)


func _prepare_result_fixture() -> void:
	# Use the production result setup order. _setup_popup_buttons styles the two
	# scene-authored controls; _move_clear_buttons_to_result_layer reparents them
	# and creates Ranking, Answer, spacer, and Back through the real helper.
	_game.set("popup_state", "clear")
	_game.set("is_gameover_result", false)
	_game.set("is_result_answer_view", false)
	_game.call("_setup_popup_buttons", "clear")
	_game.call("_move_clear_buttons_to_result_layer")
	await get_tree().process_frame


func _validate_structure_and_callbacks() -> void:
	_assert(_custom != null and _game != null and _title != null, "Custom, Game, and Title scenes instantiate")
	var custom_back := _custom.get_node("BottomBox/BtnBack") as Button
	var custom_start := _custom.get_node("BottomBox/BtnStart") as Button
	_assert(custom_back.custom_minimum_size == Vector2(154.0, 54.0), "Custom Back remains 154x54")
	_assert(custom_start.custom_minimum_size == Vector2(204.0, 54.0), "Custom Start remains 204x54")
	_assert(custom_back.pressed.is_connected(Callable(_custom, "_on_btn_back_pressed")), "Custom Back callback remains connected")
	_assert(custom_start.pressed.is_connected(Callable(_custom, "_on_btn_start_pressed")), "Custom Start callback remains connected")
	var result_back := _game.get_node_or_null("PopupResult/BtnBackToResult") as Button
	_assert(result_back != null, "Result Back is created before validation")
	if result_back != null:
		_assert(result_back.position == Vector2(112.5, 751.0) and result_back.custom_minimum_size == Vector2(255.0, 93.0), "Result Back is 255x93 at (112.5,751)")
		var result_back_label := result_back.get_node("ButtonFamilyText") as Label
		_assert(result_back_label.get_meta("button_family_ink_scale", Vector2.ZERO) == Vector2(1.5, 1.5), "Result Back scales its exact20 runtime text by 1.5")
		_assert(result_back.pressed.is_connected(Callable(_game, "_on_btn_back_to_result_pressed")), "Result Back callback remains connected")
	var yes := _game.get_node("HomeConfirmPopup/BtnConfirmYes") as Button
	var no := _game.get_node("HomeConfirmPopup/BtnConfirmNo") as Button
	_assert(yes.position == Vector2(93.0, 194.0) and yes.size == Vector2(112.0, 48.0), "Confirm Yes is 112x48 at (93,194)")
	_assert(no.position == Vector2(205.0, 194.0) and no.size == Vector2(112.0, 48.0), "Confirm No is 112x48 at (205,194)")
	_assert(yes.pressed.is_connected(Callable(_game, "_on_btn_confirm_yes_pressed")), "Confirm Yes callback remains connected")
	_assert(no.pressed.is_connected(Callable(_game, "_on_btn_confirm_no_pressed")), "Confirm No callback remains connected")
	var settings_panel := _game.get_node("SettingsPopup") as Panel
	var settings_vbox := settings_panel.get_node("VBox") as VBoxContainer
	var settings_bgm := settings_vbox.get_node("LabelBgm") as Label
	var settings_close := settings_vbox.get_node("BtnSettingsClose") as Button
	_assert(Rect2(settings_panel.position, settings_panel.size) == Rect2(20.0, 17.0, 440.0, 820.0), "Settings popup is centered at 440x820")
	_assert(Rect2(settings_vbox.position, settings_vbox.size) == Rect2(58.0, 160.0, 332.0, 590.0), "Settings VBox uses the owner-corrected content rectangle")
	_assert(settings_panel.get_global_rect().encloses(settings_bgm.get_global_rect()), "Settings BGM label control remains inside the popup")
	_assert(settings_bgm.get_global_rect().position.y >= settings_panel.get_global_rect().position.y + 160.0, "Settings BGM label keeps at least 8px below the inner cream top at y=152")
	_assert(settings_close.custom_minimum_size == Vector2(130.0, 70.0), "Settings close hitbox is 130x70")
	_assert(settings_close.size_flags_horizontal == Control.SIZE_SHRINK_CENTER, "Settings close does not expand across its VBox")
	var settings_close_art := settings_close.get_node("ButtonFamilyArt") as TextureRect
	var settings_art_bottom := settings_close.get_global_rect().position.y + settings_close_art.position.y + settings_close_art.size.y
	_assert(is_equal_approx(settings_panel.get_global_rect().end.y - settings_art_bottom, 78.0), "Settings close art keeps 78px below it inside the popup")
	var credit_close := _title.get_node_or_null("CreditPopup/VBox/BtnCreditClose") as Button
	_assert(credit_close != null, "Credits close exists")
	if credit_close != null:
		_assert(credit_close.custom_minimum_size == Vector2(130.0, 70.0), "Credits close hitbox is 130x70")
		_assert(credit_close.pressed.is_connected(Callable(_title, "_on_btn_credit_close_pressed")), "Credits close callback remains connected")
	for button_name in RESULT_EXACT4:
		var button := _game.get_node("PopupResult/ResultButtons/" + button_name) as Button
		_assert(not bool(button.get_meta("button_family_runtime_text", false)), "%s remains excluded from R01" % button_name)
		_assert(button.get_node_or_null("ButtonFamilyText") == null, "%s has no R01 text child" % button_name)


func _validate_locale(locale: String) -> void:
	SaveData.language_code = locale
	_custom.call("_apply_text_language")
	PopupSkin.apply_settings_popup(_game.get_node("SettingsPopup") as Panel)
	PopupSkin.refresh_settings_language(_game.get_node("SettingsPopup") as Panel)
	PopupSkin.apply_home_confirm_popup(_game.get_node("HomeConfirmPopup") as Panel)
	_game.call("_refresh_back_to_result_button")
	PopupSkin.apply_credit_popup(_title.get_node("CreditPopup") as Panel)
	_assert_runtime_button(_custom.get_node("BottomBox/BtnStart") as Button, PATH_START, TEXT[locale]["start"], locale, "Custom Start")
	_assert_runtime_button(_custom.get_node("BottomBox/BtnBack") as Button, PATH_BACK, TEXT[locale]["back"], locale, "Custom Back")
	_assert_runtime_button(_game.get_node_or_null("PopupResult/BtnBackToResult") as Button, PATH_RESULT_BACK, TEXT[locale]["back"], locale, "Result Back")
	_assert_runtime_button(_game.get_node("SettingsPopup/VBox/BtnSettingsClose") as Button, PATH_CLOSE, TEXT[locale]["close"], locale, "Settings Close")
	_assert_runtime_button(_game.get_node("HomeConfirmPopup/BtnConfirmYes") as Button, PATH_CONFIRM, TEXT[locale]["yes"], locale, "Confirm Yes")
	_assert_runtime_button(_game.get_node("HomeConfirmPopup/BtnConfirmNo") as Button, PATH_CONFIRM, TEXT[locale]["no"], locale, "Confirm No")
	_assert_runtime_button(_title.get_node("CreditPopup/VBox/BtnCreditClose") as Button, PATH_CLOSE, TEXT[locale]["close"], locale, "Credits Close")
	_assert_r02_tuple(_game.get_node_or_null("PopupResult/BtnBackToResult") as Button, "result_back", locale, Rect2(0.0, 0.0, 255.0, 93.0), "Result Back")
	_assert_r02_tuple(_game.get_node("HomeConfirmPopup/BtnConfirmYes") as Button, "confirm_yes", locale, Rect2(0.0, 0.0, 112.0, 48.0), "Confirm Yes")
	_assert_r02_tuple(_game.get_node("HomeConfirmPopup/BtnConfirmNo") as Button, "confirm_no", locale, Rect2(0.0, 0.0, 112.0, 48.0), "Confirm No")
	_assert_r02_tuple(_game.get_node("SettingsPopup/VBox/BtnSettingsClose") as Button, "close", locale, Rect2(0.0, 8.0, 130.0, 54.0), "Settings Close")
	_assert_r02_tuple(_title.get_node("CreditPopup/VBox/BtnCreditClose") as Button, "close", locale, Rect2(0.0, 8.0, 130.0, 54.0), "Credits Close")
	var no_art := (_game.get_node("HomeConfirmPopup/BtnConfirmNo") as Button).get_node("ButtonFamilyArt") as TextureRect
	var yes_art := (_game.get_node("HomeConfirmPopup/BtnConfirmYes") as Button).get_node("ButtonFamilyArt") as TextureRect
	_assert(no_art.modulate == Color.WHITE and yes_art.modulate == Color.WHITE, "%s R02 Yes and No use the exact un-tinted frame" % locale)


func _validate_talk_shared_confirm_callsite() -> void:
	var source := FileAccess.get_file_as_string("res://TalkScene.gd")
	_assert(source.contains("PopupSkin.apply_home_confirm_popup(_home_confirm_popup)"), "TalkScene routes shared home confirmation through PopupSkin")
	_assert(source.contains("yes_button.pressed.connect(_on_home_confirm_yes_pressed)"), "TalkScene Yes callback remains connected")
	_assert(source.contains("no_button.pressed.connect(_on_home_confirm_no_pressed)"), "TalkScene No callback remains connected")


func _validate_r02_assets_static() -> void:
	var expectations := {
		PATH_RESULT_BACK: {"size": Vector2i(170, 62), "sha": "FA4219B78153E24E8344B6D6A34A107FA9E888632964FAF4BBB913CA723FE2D9"},
		PATH_CONFIRM: {"size": Vector2i(112, 48), "sha": "8A35099418E777F1D44E2685BD2202D6010C31B3E9318D35338EB5FDF8F8B7CF"},
		PATH_CLOSE: {"size": Vector2i(130, 54), "sha": "0AD98422D4D055778A8CF4083B948C41A416A33A67E111ABE31E91879CB20399"},
	}
	for path: String in expectations:
		var image := Image.load_from_file(path)
		_assert(image != null and image.get_size() == expectations[path]["size"], "%s keeps its adopted R02 dimensions" % path)
		_assert(FileAccess.get_sha256(path).to_upper() == expectations[path]["sha"], "%s keeps its adopted exact bytes" % path)


func _validate_r02_receipts() -> void:
	var layouts := JSON.parse_string(FileAccess.get_file_as_string(R02_LAYOUT_PATH)) as Dictionary
	var receipt := JSON.parse_string(FileAccess.get_file_as_string(R02_BINDING_RECEIPT_PATH)) as Dictionary
	_assert(not layouts.is_empty() and layouts.get("runtime_uses_textless_frames", false), "R02 runtime layout mirror binds textless frames")
	_assert(not receipt.is_empty() and receipt.get("runtime_binding", false), "R02 owner runtime-binding receipt is present")
	_assert((receipt.get("accepted_exact20", []) as Array).size() == 20, "R02 owner receipt records every accepted locale/role tuple")
	_assert((receipt.get("fallback_inventory", []) as Array).is_empty(), "R02 runtime binding has no fallback inventory")


func _assert_r02_tuple(button: Button, role: String, locale: String, expected_art_rect: Rect2, label: String) -> void:
	var text_label := button.get_node_or_null("ButtonFamilyText") as Label
	_assert(text_label != null, "%s has its runtime Label" % label)
	if text_label == null:
		return
	var tuple: Array = R02_TUPLES[role][locale]
	var base_size := Vector2(170.0, 62.0) if role == "result_back" else expected_art_rect.size
	var ink_scale := expected_art_rect.size / base_size
	var expected_position := expected_art_rect.position + Vector2(float(tuple[1]) * ink_scale.x, float(tuple[2]) * ink_scale.y)
	_assert(button.get_meta("button_family_art_rect", Rect2()) == expected_art_rect, "%s uses the exact R02 art rect" % label)
	_assert(text_label.position == expected_position, "%s uses the corrected Godot Label position" % label)
	_assert(text_label.get_theme_font_size("font_size") == roundi(float(tuple[0]) * ink_scale.y), "%s scales the accepted R02 font size deterministically" % label)
	_assert(text_label.get_meta("button_family_ink_scale", Vector2.ZERO) == ink_scale, "%s records its deterministic runtime scale" % label)
	_assert(str(text_label.get_meta("button_family_ink_layout_key", "")) == role, "%s uses the accepted R02 role tuple" % label)


func _assert_runtime_button(button: Button, expected_path: String, expected_text: String, locale: String, label: String) -> void:
	if button == null:
		_assert(false, "%s exists" % label)
		return
	_assert(bool(button.get_meta("button_family_runtime_text", false)), "%s uses runtime text" % label)
	_assert(button.text == "", "%s has no baked Button.text" % label)
	_assert(button.accessibility_name == expected_text, "%s accessibility is localized" % label)
	var art := button.get_node_or_null("ButtonFamilyArt") as TextureRect
	var text_label := button.get_node_or_null("ButtonFamilyText") as Label
	_assert(art != null and art.texture != null and art.texture.resource_path == expected_path, "%s uses only its adopted frame" % label)
	_assert(text_label != null and text_label.text == expected_text, "%s visible label is localized" % label)
	if text_label == null:
		return
	_assert(is_equal_approx(float(button.get_meta("button_family_safe_text_ratio", 0.0)), 0.20), "%s keeps a 20%% clear zone at each side" % label)
	_assert(bool(button.get_meta("button_family_ink_centered", false)) and text_label.has_meta("button_family_ink_draw_position"), "%s uses a measured actual-ink placement" % label)
	_assert(str(button.get_meta("button_family_frame_revision", "")) == ("r02" if expected_path.contains("/button_families_r02/") else "r01"), "%s records the correct frame revision" % label)
	_assert(button.has_meta("button_feedback_installed"), "%s keeps shared held feedback" % label)
	_assert(button.get_theme_stylebox("focus") is StyleBoxFlat, "%s keeps visible focus feedback" % label)
	var font := text_label.get_theme_font("font")
	if locale == "ja" or locale == "en":
		_assert(font is FontVariation and (font as FontVariation).base_font.resource_path == KAISEI_PATH, "%s uses Kaisei Decol Bold for %s" % [label, locale])
	else:
		_assert(font != null and not (font is FontVariation and (font as FontVariation).base_font.resource_path == KAISEI_PATH), "%s uses the regional deterministic font for %s" % [label, locale])


func _restore() -> void:
	SaveData.language_code = _saved_language
	if is_instance_valid(_custom):
		_custom.queue_free()
	if is_instance_valid(_game):
		_game.queue_free()
	if is_instance_valid(_title):
		_title.queue_free()


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error(message)
