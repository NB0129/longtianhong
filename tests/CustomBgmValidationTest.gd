extends Node

const CUSTOM_SCENE := preload("res://custom.tscn")

const EXPECTED_WARNING := {
	"ja": "BGMを1曲以上選んでください",
	"en": "Select at least one BGM track.",
	"zh_CN": "请至少选择1首BGM。",
	"zh_TW": "請至少選擇1首BGM。",
	"ko": "BGM을 1곡 이상 선택해 주세요.",
}

var _failures := 0
var _custom: Control
var _saved_language := "ja"
var _saved_stage := ""
var _saved_bgm: Array[bool] = []


func _ready() -> void:
	_save_state()
	_prepare_empty_bgm_state()
	_custom = CUSTOM_SCENE.instantiate() as Control
	add_child(_custom)
	await get_tree().process_frame
	_validate_locales()
	_validate_invalid_start_and_idempotence()
	_validate_clear_after_selection()
	_restore_state()
	_custom.queue_free()
	await get_tree().process_frame
	if _failures == 0:
		print("PASS custom_bgm_validation invalid_blocked=1 warning=1 focus=1 clear=1 idempotent=1 locales=5")
	get_tree().quit(0 if _failures == 0 else 1)


func _save_state() -> void:
	_saved_language = SaveData.language_code
	_saved_stage = GameState.current_stage
	_saved_bgm = [
		SaveData.custom_bgm_yume,
		SaveData.custom_bgm_utu,
		SaveData.custom_bgm_mabo_first,
		SaveData.custom_bgm_mabo_second,
	]


func _prepare_empty_bgm_state() -> void:
	SaveData.language_code = "ja"
	SaveData.custom_bgm_yume = false
	SaveData.custom_bgm_utu = false
	SaveData.custom_bgm_mabo_first = false
	SaveData.custom_bgm_mabo_second = false
	GameState.current_stage = "__custom_bgm_validation_sentinel__"


func _validate_locales() -> void:
	var warning := _custom.get_node("MainVBox/BgmValidationLabel") as Label
	for locale in EXPECTED_WARNING:
		SaveData.language_code = locale
		_custom.call("_apply_text_language")
		_assert(warning.text == EXPECTED_WARNING[locale], "%s BGM warning is localized" % locale)
	SaveData.language_code = "ja"
	_custom.call("_apply_text_language")


func _validate_invalid_start_and_idempotence() -> void:
	var warning := _custom.get_node("MainVBox/BgmValidationLabel") as Label
	var bgm_label := _custom.get_node("MainVBox/BgmLabel") as Label
	var first_bgm := _custom.get_node("MainVBox/BgmGrid/CheckYume") as CheckBox
	var warning_id := warning.get_instance_id()
	var toggle_connection_count := first_bgm.toggled.get_connections().size()
	var se_player_count := AudioManager.se_players.size()
	_custom.call("_on_btn_start_pressed")
	_assert(warning.visible, "invalid Start reveals one inline warning")
	_assert(warning.text == EXPECTED_WARNING["ja"], "invalid Start uses the exact Japanese warning")
	_assert(bool(warning.get_meta("validation_active", false)), "BGM validation state is active")
	_assert(bgm_label.get_theme_color("font_color") == Color(0.72, 0.10, 0.06), "BGM section is visually identified")
	_assert(get_viewport().gui_get_focus_owner() == first_bgm, "invalid Start moves focus to the first BGM control")
	_assert(GameState.current_stage == "__custom_bgm_validation_sentinel__", "invalid Start does not start the game")
	_custom.call("_on_btn_start_pressed")
	_assert(warning.get_instance_id() == warning_id, "repeated invalid Start reuses the same warning")
	_assert(_custom.find_children("BgmValidationLabel", "Label", true, false).size() == 1, "repeated invalid Start does not stack labels")
	_assert(first_bgm.toggled.get_connections().size() == toggle_connection_count, "repeated invalid Start does not stack signals")
	_assert(AudioManager.se_players.size() == se_player_count, "repeated invalid Start does not create SE instances")


func _validate_clear_after_selection() -> void:
	var warning := _custom.get_node("MainVBox/BgmValidationLabel") as Label
	var bgm_label := _custom.get_node("MainVBox/BgmLabel") as Label
	var first_bgm := _custom.get_node("MainVBox/BgmGrid/CheckYume") as CheckBox
	first_bgm.set_pressed_no_signal(true)
	_custom.call("_on_bgm_changed", true)
	_assert(not warning.visible, "selecting one BGM clears the warning")
	_assert(not bool(warning.get_meta("validation_active", true)), "selecting one BGM clears validation state")
	_assert(bgm_label.get_theme_color("font_color") == Color(0.10, 0.38, 0.32), "selecting one BGM clears the section highlight")


func _restore_state() -> void:
	SaveData.language_code = _saved_language
	GameState.current_stage = _saved_stage
	SaveData.custom_bgm_yume = _saved_bgm[0]
	SaveData.custom_bgm_utu = _saved_bgm[1]
	SaveData.custom_bgm_mabo_first = _saved_bgm[2]
	SaveData.custom_bgm_mabo_second = _saved_bgm[3]
	SaveData.save()


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error(message)
