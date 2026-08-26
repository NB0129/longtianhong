extends Control

const TITLE_SCENE := preload("res://Title.tscn")
const SHARED_BLANK_TEXTURE := "res://assets/ui/popups/credit_buttons/owner_adopted_known_alpha_debt/popup_btn_credit_blank_r01.png"
const PRIVACY_POLICY_URL := "https://rotenkogames.com/privacy"

const LOCALIZED_BUTTON_TEXT := {
	"ja": ["ライセンス / OSS", "クレジットに戻る", "プライバシーポリシー"],
	"en": ["Licenses / OSS", "Back to Credits", "Privacy Policy"],
	"zh_CN": ["许可证 / 开源软件", "返回制作人员名单", "隐私政策"],
	"zh_TW": ["授權條款 / 開源軟體", "返回製作人員名單", "隱私權政策"],
	"ko": ["라이선스 / 오픈 소스", "크레딧으로 돌아가기", "개인정보처리방침"],
}

var _failed := false
var _original_language := "ja"
var _title: Control = null
var _credit_popup: Panel = null
var _credit_body: Label = null
var _action_row: HBoxContainer = null
var _licenses_button: Button = null
var _privacy_button: Button = null
var _captured_url := ""


func _ready() -> void:
	_original_language = SaveData.language_code
	SaveData.language_code = "ja"
	_title = TITLE_SCENE.instantiate() as Control
	_assert(_title != null, "Title scene instantiates")
	if _title == null:
		_finish()
		return
	add_child(_title)
	await get_tree().process_frame
	_bind_credit_nodes()
	if _failed:
		_finish()
		return
	await _validate_credit_and_legal_views()
	await _validate_localized_button_text()
	_validate_close_behavior()
	_finish()


func _bind_credit_nodes() -> void:
	_credit_popup = _title.get_node_or_null("CreditPopup") as Panel
	_credit_body = _title.get_node_or_null("CreditPopup/VBox/CreditScroll/CreditBody") as Label
	_action_row = _title.get_node_or_null("CreditPopup/VBox/CreditActionRow") as HBoxContainer
	_licenses_button = _title.get_node_or_null("CreditPopup/VBox/CreditActionRow/BtnLicenses") as Button
	_privacy_button = _title.get_node_or_null("CreditPopup/VBox/CreditActionRow/BtnPrivacyPolicy") as Button
	_assert(_credit_popup != null, "Credit popup exists")
	_assert(_credit_body != null, "Credit body exists")
	_assert(_action_row != null, "Credit action row exists")
	_assert(_licenses_button != null, "Licenses / OSS button exists")
	_assert(_privacy_button != null, "Privacy Policy button exists")


func _validate_credit_and_legal_views() -> void:
	var open_button := _title.get_node_or_null("CreditFrame/BtnCredit") as Button
	_assert(open_button != null, "Credit open button exists")
	if open_button == null:
		return
	open_button.pressed.emit()
	await get_tree().process_frame
	_assert(_credit_popup.visible, "Credit popup opens")
	_assert(_credit_body.text.contains("企画 / 制作"), "Normal Credits contains production information")
	_assert(_credit_body.text.contains("狼天紅ゲームズ"), "Normal Credits contains the production credit")
	_assert(_credit_body.text.contains("原画 / キャラクターデザイン"), "Normal Credits contains creative attribution")
	_assert(not _credit_body.text.contains("第1条　用語の定義"), "Normal Credits excludes the IPA license body")
	_assert(not _credit_body.text.contains("SIL OPEN FONT LICENSE Version 1.1"), "Normal Credits excludes the OFL body")
	_assert(not _credit_body.text.contains("Permission is hereby granted, free of charge"), "Normal Credits excludes the Godot license body")
	_assert(not _credit_body.text.contains("Godot Engine third-party components"), "Normal Credits excludes Godot third-party notices")
	_assert(_licenses_button.text == LOCALIZED_BUTTON_TEXT["ja"][0], "Japanese Licenses / OSS text is drawn at runtime")
	_assert(_privacy_button.text == LOCALIZED_BUTTON_TEXT["ja"][2], "Japanese Privacy Policy text is drawn at runtime")
	_assert(_button_texture_path(_licenses_button) == SHARED_BLANK_TEXTURE, "Japanese Licenses / OSS uses the shared blank background")
	_assert(_button_texture_path(_privacy_button) == SHARED_BLANK_TEXTURE, "Japanese Privacy Policy uses the shared blank background")
	_validate_action_layout()
	_title.set("_shell_open_override", Callable(self, "_capture_url"))
	_privacy_button.pressed.emit()
	_assert(_captured_url == PRIVACY_POLICY_URL, "Privacy Policy image button keeps the external URL action")

	_licenses_button.pressed.emit()
	await get_tree().process_frame
	_assert(_credit_body.text.contains("IPA Font License Agreement v1.0 <Japanese/English>"), "Legal view contains the IPA license")
	_assert(_credit_body.text.contains("SIL OPEN FONT LICENSE Version 1.1"), "Legal view contains the Noto OFL license")
	_assert(_credit_body.text.contains("Godot Engine license"), "Legal view identifies the Godot license")
	_assert(_credit_body.text.contains("Permission is hereby granted, free of charge"), "Legal view contains the Godot license body")
	_assert(not _privacy_button.visible, "Privacy Policy button is hidden in the legal view")
	_assert(_licenses_button.text == LOCALIZED_BUTTON_TEXT["ja"][1], "Legal view exposes a localized Back to Credits action")
	_assert(_button_texture_path(_licenses_button) == SHARED_BLANK_TEXTURE, "Legal view keeps the shared blank background")

	_title.call("_handle_system_back")
	await get_tree().process_frame
	_assert(_credit_popup.visible, "System Back from legal notices keeps Credits open")
	_assert(_credit_body.text.contains("企画 / 制作"), "System Back restores normal Credits")
	_assert(not _credit_body.text.contains("SIL OPEN FONT LICENSE Version 1.1"), "System Back removes the legal body")
	_assert(_privacy_button.visible, "System Back restores the Privacy Policy button")
	_assert(_licenses_button.text == LOCALIZED_BUTTON_TEXT["ja"][0], "System Back restores the Japanese Licenses / OSS label")
	_assert(_privacy_button.text == LOCALIZED_BUTTON_TEXT["ja"][2], "System Back restores the Japanese Privacy Policy label")
	_assert(_button_texture_path(_licenses_button) == SHARED_BLANK_TEXTURE, "System Back restores the shared blank background")
	_assert(_button_texture_path(_privacy_button) == SHARED_BLANK_TEXTURE, "System Back restores Privacy Policy's shared blank background")


func _validate_localized_button_text() -> void:
	for locale: String in LOCALIZED_BUTTON_TEXT:
		SaveData.language_code = locale
		_title.call("_apply_title_language")
		await get_tree().process_frame
		var expected: Array = LOCALIZED_BUTTON_TEXT[locale]
		_assert(_licenses_button.text == str(expected[0]), "%s Licenses / OSS runtime label matches" % locale)
		_assert(_privacy_button.text == str(expected[2]), "%s Privacy Policy runtime label matches" % locale)
		_assert(_button_texture_path(_licenses_button) == SHARED_BLANK_TEXTURE, "%s Licenses / OSS uses the shared blank background" % locale)
		_assert(_button_texture_path(_privacy_button) == SHARED_BLANK_TEXTURE, "%s Privacy Policy uses the shared blank background" % locale)
		_assert(str(_licenses_button.get_meta("locale_font_code", "")) == locale, "%s Licenses / OSS uses its bundled locale font" % locale)
		_assert(str(_privacy_button.get_meta("locale_font_code", "")) == locale, "%s Privacy Policy uses its bundled locale font" % locale)
		_licenses_button.pressed.emit()
		await get_tree().process_frame
		_assert(_licenses_button.text == str(expected[1]), "%s Back to Credits label matches" % locale)
		_assert(_button_texture_path(_licenses_button) == SHARED_BLANK_TEXTURE, "%s Back to Credits uses the shared blank background" % locale)
		_assert(str(_licenses_button.get_meta("locale_font_code", "")) == locale, "%s Back to Credits uses its bundled locale font" % locale)
		_assert(not _privacy_button.visible, "%s legal view hides Privacy Policy" % locale)
		_licenses_button.pressed.emit()
		await get_tree().process_frame
		_assert(_licenses_button.text == str(expected[0]), "%s Back action restores the Licenses / OSS label" % locale)
		_assert(_privacy_button.text == str(expected[2]), "%s Back action restores the Privacy Policy label" % locale)
		_assert(_privacy_button.visible, "%s Back action restores Privacy Policy" % locale)
		_validate_action_layout()


func _validate_action_layout() -> void:
	_assert(_action_row != null, "Credit action row remains available")
	if _action_row == null:
		return
	_assert(_licenses_button.get_parent() == _action_row, "Licenses / OSS belongs to the horizontal action row")
	_assert(_privacy_button.get_parent() == _action_row, "Privacy Policy belongs to the horizontal action row")
	_assert(_licenses_button.get_index() < _privacy_button.get_index(), "Licenses / OSS is left of Privacy Policy")
	_assert(is_equal_approx(_credit_popup.position.x, 18.0) and is_equal_approx(_credit_popup.position.y, 50.0), "Credit popup uses the enlarged centered position")
	_assert(_credit_popup.size.is_equal_approx(Vector2(444.0, 754.0)), "Credit popup uses the enlarged size")
	_assert(is_equal_approx(_action_row.size.x, 348.0), "Credit action row has the approved inner width")
	_assert(_licenses_button.size.y >= 48.0 and _privacy_button.size.y >= 48.0, "Both credit action buttons keep a touch-safe height")
	var licenses_rect := Rect2(_licenses_button.position, _licenses_button.size)
	var privacy_rect := Rect2(_privacy_button.position, _privacy_button.size)
	_assert(licenses_rect.end.x <= privacy_rect.position.x + 0.5, "Horizontal credit action buttons do not overlap")
	_assert(absf(_licenses_button.position.y - _privacy_button.position.y) <= 0.5, "Horizontal credit action buttons share one row")
	_assert(Rect2(Vector2.ZERO, _action_row.size).encloses(licenses_rect), "Licenses / OSS stays inside the action row")
	_assert(Rect2(Vector2.ZERO, _action_row.size).encloses(privacy_rect), "Privacy Policy stays inside the action row")


func _button_texture_path(button: Button) -> String:
	var style := button.get_theme_stylebox("normal") as StyleBoxTexture
	if style == null or style.texture == null:
		return ""
	return style.texture.resource_path


func _capture_url(url: String) -> void:
	_captured_url = url


func _validate_close_behavior() -> void:
	var close_button := _title.get_node_or_null("CreditPopup/VBox/BtnCreditClose") as Button
	_assert(close_button != null, "Credit close button exists")
	if close_button == null:
		return
	_licenses_button.pressed.emit()
	close_button.pressed.emit()
	_assert(not _credit_popup.visible, "Close hides the popup from the legal view")
	var open_button := _title.get_node_or_null("CreditFrame/BtnCredit") as Button
	_assert(open_button != null, "Credit open button remains available after Close")
	if open_button == null:
		return
	open_button.pressed.emit()
	_assert(_credit_popup.visible, "Credits can reopen after Close")
	_assert(_credit_body.text.contains("Codex"), "Reopening starts on localized normal Credits")
	_assert(not _credit_body.text.contains("SIL OPEN FONT LICENSE Version 1.1"), "Reopening does not retain the legal body")


func _finish() -> void:
	SaveData.language_code = _original_language
	if AudioManager != null:
		AudioManager.stop_bgm()
	if _title != null and is_instance_valid(_title):
		remove_child(_title)
		_title.free()
		_title = null
	if _failed:
		get_tree().quit(1)
		return
	print("PASS credit_legal_split locales=%d" % LOCALIZED_BUTTON_TEXT.size())
	get_tree().quit(0)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
