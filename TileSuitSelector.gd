extends GridContainer

signal tile_suit_changed(tile_suit: String)

@export var disable_manzu2_when_sorted_stage: bool = false

const TILE_BUTTON_SIZE := Vector2(126.0, 54.0)
const TILE_ICON_SIZE := Vector2(27.0, 38.0)
const TILE_PREVIEWS: Dictionary = {
	"pinzu": ["res://assets/tiles/a1pinz.webp", "res://assets/tiles/a2pinz.webp", "res://assets/tiles/a3pinz.webp"],
	"souzu": ["res://assets/tiles/so1.webp", "res://assets/tiles/so2.webp", "res://assets/tiles/so3.webp"],
	"manzu": ["res://assets/tiles/man1.webp", "res://assets/tiles/man2.webp", "res://assets/tiles/man3.webp"],
	"manzu2": ["res://assets/tiles/man3.webp", "res://assets/tiles/man1.webp", "res://assets/tiles/man2.webp"],
}
const TEXT: Dictionary = {
	"ja": {
		"manzu2_disabled": "理牌なしのステージで使用できます",
	},
	"en": {
		"manzu2_disabled": "Available on stages without hand sorting.",
	},
	"zh_CN": {
		"manzu2_disabled": "可在不理牌的关卡中使用。",
	},
	"zh_TW": {
		"manzu2_disabled": "可在不理牌的關卡中使用。",
	},
	"ko": {
		"manzu2_disabled": "패 정렬이 없는 스테이지에서 사용할 수 있습니다.",
	},
}


func _ready() -> void:
	var group: ButtonGroup = ButtonGroup.new()
	$BtnPinzu.button_group = group
	$BtnSouzu.button_group = group
	$BtnManzu.button_group = group
	$BtnManzu2.button_group = group
	_setup_tile_button($BtnPinzu, "pinzu")
	_setup_tile_button($BtnSouzu, "souzu")
	_setup_tile_button($BtnManzu, "manzu")
	_setup_tile_button($BtnManzu2, "manzu2")
	$BtnPinzu.pressed.connect(_select_tile_suit.bind("pinzu"))
	$BtnSouzu.pressed.connect(_select_tile_suit.bind("souzu"))
	$BtnManzu.pressed.connect(_select_tile_suit.bind("manzu"))
	$BtnManzu2.pressed.connect(_select_tile_suit.bind("manzu2"))
	sync_selection()

func sync_selection() -> void:
	var manzu2_enabled := _is_manzu2_enabled()
	$BtnManzu2.disabled = not manzu2_enabled
	$BtnManzu2.tooltip_text = _text("manzu2_disabled") if not manzu2_enabled else ""
	if not manzu2_enabled and SaveData.tile_suit == "manzu2":
		SaveData.tile_suit = "manzu"
		SaveData.save()
	$BtnPinzu.set_pressed_no_signal(SaveData.tile_suit == "pinzu")
	$BtnSouzu.set_pressed_no_signal(SaveData.tile_suit == "souzu")
	$BtnManzu.set_pressed_no_signal(SaveData.tile_suit == "manzu")
	$BtnManzu2.set_pressed_no_signal(manzu2_enabled and SaveData.tile_suit == "manzu2")

func _select_tile_suit(tile_suit: String) -> void:
	if tile_suit == "manzu2" and not _is_manzu2_enabled():
		sync_selection()
		return
	if SaveData.tile_suit == tile_suit:
		return
	SaveData.tile_suit = tile_suit
	SaveData.save()
	tile_suit_changed.emit(tile_suit)


func _setup_tile_button(button: CheckBox, tile_suit: String) -> void:
	button.text = ""
	button.custom_minimum_size = TILE_BUTTON_SIZE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.focus_mode = Control.FOCUS_NONE
	if button.has_node("TilePreview"):
		button.get_node("TilePreview").queue_free()

	var preview := HBoxContainer.new()
	preview.name = "TilePreview"
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.alignment = BoxContainer.ALIGNMENT_CENTER
	preview.add_theme_constant_override("separation", 4)
	preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(preview)

	var index := 0
	for path in TILE_PREVIEWS[tile_suit]:
		var tile := TextureRect.new()
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.custom_minimum_size = TILE_ICON_SIZE
		tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if ResourceLoader.exists(path):
			tile.texture = load(path)
		if tile_suit == "manzu2" and index == 1:
			tile.flip_h = true
			tile.flip_v = true
		preview.add_child(tile)
		index += 1

func _is_manzu2_enabled() -> bool:
	if not disable_manzu2_when_sorted_stage:
		return true
	return not _current_stage_sorts_hand()

func _current_stage_sorts_hand() -> bool:
	if GameState.current_stage == "":
		return false
	if GameState.current_stage == "endless":
		match GameState.endless_block:
			0, 1, 2, 6:
				return true
			_:
				return false
	if GameState.current_stage.begins_with("ex_"):
		return GameState.current_stage == "ex_stage3"
	if GameState.current_stage == "custom":
		return SaveData.custom_sort_enabled
	var effective_stage: String = GameState.current_stage
	if GameState.current_stage == "tutorial":
		effective_stage = "stage1"
	return effective_stage != "stage4"


func _text(key: String) -> String:
	var language: String = SaveData.normalize_language_code(SaveData.language_code)
	var texts: Dictionary = TEXT.get(language, TEXT["ja"])
	return str(texts.get(key, TEXT["ja"].get(key, "")))
