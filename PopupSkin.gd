extends RefCounted

const TalkLocalization := preload("res://TalkLocalization.gd")

const PANEL_SETTINGS := "res://assets/ui/popups/popup_panel_settings.webp"
const PANEL_CONFIRM := "res://assets/ui/popups/popup_panel_confirm.webp"
const PANEL_SETTINGS_V2 := "res://assets/ui/popups/popup_panel_settings_v2.webp"
const PANEL_CONFIRM_V2 := "res://assets/ui/popups/popup_panel_confirm_v2.webp"
const PANEL_SUPPORT := "res://assets/ui/popups/popup_panel_support.webp"
const PANEL_CREDIT := "res://assets/ui/popups/popup_panel_credit.webp"

const BTN_BLUE := "res://assets/ui/popups/popup_btn_blue.webp"
const BTN_BLUE_PRESSED := "res://assets/ui/popups/popup_btn_blue_pressed.webp"
const BTN_GREEN := "res://assets/ui/popups/popup_btn_green.webp"
const BTN_GREEN_PRESSED := "res://assets/ui/popups/popup_btn_green_pressed.webp"
const BTN_PINK := "res://assets/ui/popups/popup_btn_pink.webp"
const BTN_PINK_PRESSED := "res://assets/ui/popups/popup_btn_pink_pressed.webp"
const BTN_GOLD := "res://assets/ui/popups/popup_btn_gold.webp"
const BTN_GOLD_PRESSED := "res://assets/ui/popups/popup_btn_gold_pressed.webp"
const BTN_CLOSE_GENERATED := "res://assets/ui/popups/popup_btn_close_generated.webp"
const BTN_CLOSE_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_close_generated_pressed.webp"
const BTN_YES_GENERATED := "res://assets/ui/popups/popup_btn_yes_generated.webp"
const BTN_YES_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_yes_generated_pressed.webp"
const BTN_NO_GENERATED := "res://assets/ui/popups/popup_btn_no_generated.webp"
const BTN_NO_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_no_generated_pressed.webp"
const BTN_CLOSE_V2 := "res://assets/ui/popups/popup_btn_close_v2.webp"
const BTN_YES_V2 := "res://assets/ui/popups/popup_btn_yes_v2.webp"
const BTN_NO_V2 := "res://assets/ui/popups/popup_btn_no_v2.webp"
const BTN_BACK_V2 := "res://assets/ui/popups/popup_btn_back_v2.webp"
const BTN_BUY_GENERATED := "res://assets/ui/popups/popup_btn_buy_generated.webp"
const BTN_BUY_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_buy_generated_pressed.webp"
const BTN_RESTORE_GENERATED := "res://assets/ui/popups/popup_btn_restore_generated.webp"
const BTN_RESTORE_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_restore_generated_pressed.webp"
const BTN_SUPPORT_BUY_GENERATED := "res://assets/ui/popups/popup_btn_support_buy_generated.webp"
const BTN_SUPPORT_BUY_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_support_buy_generated_pressed.webp"
const BTN_SUPPORT_RESTORE_GENERATED := "res://assets/ui/popups/popup_btn_support_restore_generated.webp"
const BTN_SUPPORT_RESTORE_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_support_restore_generated_pressed.webp"
const BTN_SUPPORT_CLOSE_GENERATED := "res://assets/ui/popups/popup_btn_support_close_generated.webp"
const BTN_SUPPORT_CLOSE_GENERATED_PRESSED := "res://assets/ui/popups/popup_btn_support_close_generated_pressed.webp"
const LOCALIZED_SETTINGS_PANEL_DIR := "res://assets/language/normalized/%s/settings_panels/"
const LOCALIZED_SETTINGS_BUTTON_DIR := "res://assets/language/normalized/%s/settings_buttons/"
const LOCALIZED_CONFIRM_PANEL_DIR := "res://assets/language/normalized/%s/confirm_panels/"
const LOCALIZED_CONFIRM_BUTTON_DIR := "res://assets/language/normalized/%s/confirm_buttons/"
const LOCALIZED_SUPPORT_BUTTON_DIR := "res://assets/language/normalized/%s/support_buttons/"


static func apply_settings_popup(panel: Panel) -> void:
	var panel_path := _localized_settings_panel_path("popup_panel_settings.webp", PANEL_SETTINGS_V2)
	_apply_panel(panel, panel_path, 0.0)
	_layout_settings_popup(panel)
	_style_tree(panel)
	_style_settings_content(panel)
	if panel.has_node("VBox/BtnSettingsClose"):
		var close_button: Button = panel.get_node("VBox/BtnSettingsClose")
		_ensure_spacer_before(close_button, "SettingsCloseSpacer")
		var close_path := _localized_settings_button_path("popup_btn_close.webp", BTN_CLOSE_V2)
		apply_generated_text_button(close_button, close_path, close_path)
	if panel.has_node("VBox/BtnExitGame"):
		apply_button(panel.get_node("VBox/BtnExitGame"), "pink")


static func apply_home_confirm_popup(panel: Panel) -> void:
	_layout_home_confirm_popup(panel)
	var panel_path := _localized_confirm_panel_path("popup_panel_confirm.webp", PANEL_CONFIRM_V2)
	_apply_panel(panel, panel_path, 0.0)
	_style_tree(panel)
	if panel.has_node("ConfirmLabel"):
		var label: Label = panel.get_node("ConfirmLabel")
		label.text = ""
	if panel.has_node("BtnConfirmYes"):
		var yes_path := _localized_confirm_button_path("popup_btn_yes.webp", BTN_YES_V2)
		apply_generated_text_button(panel.get_node("BtnConfirmYes"), yes_path, yes_path)
	if panel.has_node("BtnConfirmNo"):
		var no_path := _localized_confirm_button_path("popup_btn_no.webp", BTN_NO_V2)
		apply_generated_text_button(panel.get_node("BtnConfirmNo"), no_path, no_path)


static func apply_support_popup(panel: Panel) -> void:
	_apply_panel(panel, PANEL_SUPPORT, 34.0)
	_layout_support_popup(panel)
	_style_tree(panel)
	if panel.has_node("VBox"):
		var vbox: VBoxContainer = panel.get_node("VBox")
		vbox.add_theme_constant_override("separation", 6)
	if panel.has_node("VBox/SupportTitle"):
		var title: Label = panel.get_node("VBox/SupportTitle")
		title.add_theme_font_size_override("font_size", 26)
	if panel.has_node("VBox/BtnSupportBuy"):
		var buy_path := _localized_support_button_path("popup_btn_support_buy.webp", BTN_SUPPORT_BUY_GENERATED)
		apply_generated_text_button(panel.get_node("VBox/BtnSupportBuy"), buy_path, buy_path)
	if panel.has_node("VBox/BtnSupportRestore"):
		var restore_path := _localized_support_button_path("popup_btn_support_restore.webp", BTN_SUPPORT_RESTORE_GENERATED)
		apply_generated_text_button(panel.get_node("VBox/BtnSupportRestore"), restore_path, restore_path)
	if panel.has_node("VBox/BtnSupportClose"):
		var close_path := _localized_settings_button_path("popup_btn_close.webp", BTN_SUPPORT_CLOSE_GENERATED)
		apply_generated_text_button(panel.get_node("VBox/BtnSupportClose"), close_path, close_path)


static func apply_credit_popup(panel: Panel) -> void:
	_apply_panel(panel, PANEL_CREDIT, 48.0)
	_layout_credit_popup(panel)
	_style_tree(panel)
	if panel.has_node("VBox/CreditScroll/CreditBody"):
		var body: Label = panel.get_node("VBox/CreditScroll/CreditBody")
		body.add_theme_font_size_override("font_size", 16)
		body.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
		body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if panel.has_node("VBox/BtnCreditClose"):
		var close_path := _localized_settings_button_path("popup_btn_close.webp", BTN_CLOSE_V2)
		apply_generated_text_button(panel.get_node("VBox/BtnCreditClose"), close_path, close_path)


static func ensure_settings_language_controls(panel: Panel, pressed_callback: Callable) -> void:
	if panel == null or not panel.has_node("VBox"):
		return
	var vbox := panel.get_node("VBox") as VBoxContainer
	var label := vbox.get_node_or_null("LabelLanguage") as Label
	if label == null:
		label = Label.new()
		label.name = "LabelLanguage"
		vbox.add_child(label)

	var grid := vbox.get_node_or_null("LanguageGrid") as GridContainer
	if grid == null:
		grid = GridContainer.new()
		grid.name = "LanguageGrid"
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 6)
		vbox.add_child(grid)
	grid.columns = 2
	grid.custom_minimum_size = Vector2(0.0, 118.0)

	_move_settings_language_controls_before_close_area(vbox, label, grid)

	var group := ButtonGroup.new()
	for option in TalkLocalization.LANGUAGE_OPTIONS:
		var code: String = option["code"]
		var button_name := "BtnLanguage" + code.replace("_", "")
		var button := grid.get_node_or_null(button_name) as CheckBox
		if button == null:
			button = CheckBox.new()
			button.name = button_name
			button.focus_mode = Control.FOCUS_NONE
			grid.add_child(button)
		button.button_group = group
		button.custom_minimum_size = Vector2(132.0, 32.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 15)
		if pressed_callback.is_valid() and not button.has_meta("settings_language_connected"):
			button.pressed.connect(pressed_callback.bind(code))
			button.set_meta("settings_language_connected", true)
	refresh_settings_language(panel)


static func _move_settings_language_controls_before_close_area(vbox: VBoxContainer, label: Label, grid: GridContainer) -> void:
	var spacer := vbox.get_node_or_null("SettingsCloseSpacer") as Control
	var close_button := vbox.get_node_or_null("BtnSettingsClose") as Button
	vbox.move_child(label, vbox.get_child_count() - 1)
	vbox.move_child(grid, vbox.get_child_count() - 1)
	var insert_index := vbox.get_child_count()
	if spacer != null:
		insert_index = spacer.get_index()
	elif close_button != null:
		insert_index = close_button.get_index()
	vbox.move_child(label, insert_index)
	vbox.move_child(grid, label.get_index() + 1)


static func refresh_settings_language(panel: Panel) -> void:
	if panel == null or not panel.has_node("VBox"):
		return
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var vbox := panel.get_node("VBox")
	_set_label_text(vbox, "LabelBgm", TalkLocalization.ui_text(locale, "settings_bgm"))
	_set_label_text(vbox, "LabelSe", TalkLocalization.ui_text(locale, "settings_se"))
	_set_label_text(vbox, "LabelTileSuit", TalkLocalization.ui_text(locale, "settings_tile"))
	_set_label_text(vbox, "LabelLanguage", TalkLocalization.ui_text(locale, "language"))
	if vbox.has_node("BtnSettingsClose"):
		var close_button := vbox.get_node("BtnSettingsClose") as Button
		close_button.text = ""
	var grid := vbox.get_node_or_null("LanguageGrid") as GridContainer
	if grid != null:
		for option in TalkLocalization.LANGUAGE_OPTIONS:
			var code: String = option["code"]
			var button := grid.get_node_or_null("BtnLanguage" + code.replace("_", "")) as CheckBox
			if button != null:
				button.text = str(option["label"])
				button.set_pressed_no_signal(code == locale)


static func apply_button(button: Button, kind: String = "blue") -> void:
	var normal_path := BTN_BLUE
	var pressed_path := BTN_BLUE_PRESSED
	match kind:
		"green":
			normal_path = BTN_GREEN
			pressed_path = BTN_GREEN_PRESSED
		"pink":
			normal_path = BTN_PINK
			pressed_path = BTN_PINK_PRESSED
		"gold":
			normal_path = BTN_GOLD
			pressed_path = BTN_GOLD_PRESSED

	button.flat = false
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _make_style(normal_path, 24.0))
	button.add_theme_stylebox_override("hover", _make_style(normal_path, 24.0))
	button.add_theme_stylebox_override("pressed", _make_style(pressed_path, 24.0))
	button.add_theme_stylebox_override("disabled", _make_style(pressed_path, 24.0))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(1.0, 1.0, 1.0, 0.45))
	button.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.14, 1.0))
	button.add_theme_constant_override("outline_size", 5)


static func _set_label_text(parent: Node, node_name: String, value: String) -> void:
	var label := parent.get_node_or_null(node_name) as Label
	if label != null:
		label.text = value


static func apply_generated_text_button(button: Button, normal_path: String, pressed_path: String) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.text = ""
	button.flat = false
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var button_size := _generated_button_min_size(normal_path)
	button.custom_minimum_size = button_size
	var parent := button.get_parent()
	if not (parent is Container):
		var center := button.position + button.size * 0.5
		button.size = button_size
		button.position = center - button.size * 0.5
	button.add_theme_stylebox_override("normal", _make_style(normal_path, 0.0))
	button.add_theme_stylebox_override("hover", _make_style(normal_path, 0.0))
	button.add_theme_stylebox_override("pressed", _make_style(pressed_path, 0.0))
	button.add_theme_stylebox_override("disabled", _make_style(pressed_path, 0.0))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


static func _apply_invisible_hit_button(button: Button) -> void:
	button.text = ""
	button.icon = null
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_stylebox_override("focus", empty)


static func _apply_panel(panel: Panel, texture_path: String, margin: float) -> void:
	panel.add_theme_stylebox_override("panel", _make_style(texture_path, margin))


static func _layout_settings_popup(panel: Panel) -> void:
	panel.position = Vector2(36.0, 42.0)
	panel.size = Vector2(408.0, 760.0)
	if not panel.has_node("VBox"):
		return
	var vbox := panel.get_node("VBox") as VBoxContainer
	vbox.offset_left = 58.0
	vbox.offset_top = 156.0
	vbox.offset_right = -50.0
	vbox.offset_bottom = -72.0
	vbox.add_theme_constant_override("separation", 6)
	if vbox.has_node("LabelBgm"):
		(vbox.get_node("LabelBgm") as Label).add_theme_font_size_override("font_size", 24)
	if vbox.has_node("LabelSe"):
		(vbox.get_node("LabelSe") as Label).add_theme_font_size_override("font_size", 24)
	if vbox.has_node("LabelTileSuit"):
		(vbox.get_node("LabelTileSuit") as Label).add_theme_font_size_override("font_size", 20)
	if vbox.has_node("BgmSlider"):
		var bgm_slider := vbox.get_node("BgmSlider") as HSlider
		bgm_slider.custom_minimum_size = Vector2(250.0, 34.0)
		bgm_slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if vbox.has_node("SeSlider"):
		var se_slider := vbox.get_node("SeSlider") as HSlider
		se_slider.custom_minimum_size = Vector2(250.0, 34.0)
		se_slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if vbox.has_node("TileSuitGrid"):
		var grid := vbox.get_node("TileSuitGrid") as GridContainer
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		for child in grid.get_children():
			if child is CheckBox:
				var check := child as CheckBox
				check.custom_minimum_size = Vector2(144.0, 36.0)
				check.add_theme_font_size_override("font_size", 18)
	if vbox.has_node("LanguageGrid"):
		var language_grid := vbox.get_node("LanguageGrid") as GridContainer
		language_grid.add_theme_constant_override("h_separation", 10)
		language_grid.add_theme_constant_override("v_separation", 6)
		for child in language_grid.get_children():
			if child is CheckBox:
				var check := child as CheckBox
				check.custom_minimum_size = Vector2(132.0, 32.0)
				check.add_theme_font_size_override("font_size", 15)


static func _layout_support_popup(panel: Panel) -> void:
	panel.position = Vector2(36.0, 94.0)
	panel.size = Vector2(408.0, 650.0)
	if not panel.has_node("VBox"):
		return
	var vbox := panel.get_node("VBox") as VBoxContainer
	vbox.offset_left = 62.0
	vbox.offset_top = 84.0
	vbox.offset_right = -62.0
	vbox.offset_bottom = -70.0
	vbox.add_theme_constant_override("separation", 8)
	if vbox.has_node("SupportTitle"):
		var title := vbox.get_node("SupportTitle") as Label
		title.custom_minimum_size = Vector2(0.0, 16.0)
	if vbox.get_child_count() > 1:
		var body := vbox.get_child(1) as Label
		if body != null:
			body.custom_minimum_size = Vector2(284.0, 200.0)
			body.add_theme_font_size_override("font_size", 11)
	if vbox.get_child_count() > 2:
		var message := vbox.get_child(2) as Label
		if message != null:
			message.custom_minimum_size = Vector2(284.0, 24.0)
			message.add_theme_font_size_override("font_size", 11)
	if vbox.get_child_count() > 0 and not vbox.has_node("SupportButtonSpacer"):
		var spacer := Control.new()
		spacer.name = "SupportButtonSpacer"
		spacer.custom_minimum_size = Vector2(0.0, 2.0)
		var insert_index := vbox.get_child_count()
		if vbox.has_node("BtnSupportBuy"):
			insert_index = (vbox.get_node("BtnSupportBuy") as Button).get_index()
		vbox.add_child(spacer)
		vbox.move_child(spacer, insert_index)
	if vbox.has_node("BtnSupportBuy"):
		(vbox.get_node("BtnSupportBuy") as Button).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if vbox.has_node("BtnSupportRestore"):
		(vbox.get_node("BtnSupportRestore") as Button).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if vbox.has_node("BtnSupportClose"):
		(vbox.get_node("BtnSupportClose") as Button).size_flags_horizontal = Control.SIZE_SHRINK_CENTER


static func _layout_credit_popup(panel: Panel) -> void:
	panel.position = Vector2(36.0, 92.0)
	panel.size = Vector2(408.0, 668.0)
	if not panel.has_node("VBox"):
		return
	var vbox := panel.get_node("VBox") as VBoxContainer
	vbox.offset_left = 74.0
	vbox.offset_top = 118.0
	vbox.offset_right = -74.0
	vbox.offset_bottom = -122.0
	vbox.add_theme_constant_override("separation", 10)
	if vbox.has_node("CreditScroll"):
		var scroll := vbox.get_node("CreditScroll") as ScrollContainer
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	if vbox.has_node("CreditScroll/CreditBody"):
		var body := vbox.get_node("CreditScroll/CreditBody") as Label
		body.custom_minimum_size = Vector2(0.0, 1480.0)
		body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if vbox.has_node("BtnCreditClose"):
		var close_button := vbox.get_node("BtnCreditClose") as Button
		close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


static func _ensure_spacer_before(node: Control, spacer_name: String) -> void:
	if node == null or not is_instance_valid(node):
		return
	var parent := node.get_parent() as Container
	if parent == null:
		return
	if parent.has_node(spacer_name):
		return
	var spacer := Control.new()
	spacer.name = spacer_name
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var index := node.get_index()
	parent.add_child(spacer)
	parent.move_child(spacer, index)


static func _make_style(texture_path: String, margin: float) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	if ResourceLoader.exists(texture_path):
		style.texture = load(texture_path)
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	return style


static func _localized_settings_button_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_path := (LOCALIZED_SETTINGS_BUTTON_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path


static func _localized_settings_panel_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_path := (LOCALIZED_SETTINGS_PANEL_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path


static func _localized_confirm_button_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if locale == "ja":
		return fallback_path
	var localized_path := (LOCALIZED_CONFIRM_BUTTON_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path


static func _localized_confirm_panel_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_path := (LOCALIZED_CONFIRM_PANEL_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path


static func _localized_support_button_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_path := (LOCALIZED_SUPPORT_BUTTON_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path


static func _generated_button_min_size(texture_path: String) -> Vector2:
	var target_height := _generated_button_height(texture_path)
	if ResourceLoader.exists(texture_path):
		var texture := load(texture_path) as Texture2D
		if texture != null:
			var texture_size := texture.get_size()
			if texture_size.y > 0.0:
				return Vector2(target_height * texture_size.x / texture_size.y, target_height)
	return Vector2(180.0, target_height)


static func _generated_button_height(texture_path: String) -> float:
	if texture_path.ends_with("/confirm_buttons/popup_btn_yes.webp") or texture_path.ends_with("/confirm_buttons/popup_btn_no.webp"):
		return 48.0
	if texture_path.ends_with("/settings_buttons/popup_btn_close.webp"):
		return 92.0
	if texture_path.ends_with("/support_buttons/popup_btn_support_buy.webp") or texture_path.ends_with("/support_buttons/popup_btn_support_restore.webp"):
		return 58.0
	if texture_path == BTN_CLOSE_V2:
		return 58.0
	if texture_path == BTN_YES_V2 or texture_path == BTN_NO_V2:
		return 48.0
	if texture_path == BTN_BACK_V2:
		return 50.0
	if texture_path == BTN_SUPPORT_BUY_GENERATED or texture_path == BTN_SUPPORT_BUY_GENERATED_PRESSED:
		return 76.0
	if texture_path == BTN_SUPPORT_RESTORE_GENERATED or texture_path == BTN_SUPPORT_RESTORE_GENERATED_PRESSED:
		return 76.0
	if texture_path == BTN_SUPPORT_CLOSE_GENERATED or texture_path == BTN_SUPPORT_CLOSE_GENERATED_PRESSED:
		return 58.0
	if texture_path == BTN_YES_GENERATED or texture_path == BTN_YES_GENERATED_PRESSED:
		return 44.0
	if texture_path == BTN_NO_GENERATED or texture_path == BTN_NO_GENERATED_PRESSED:
		return 44.0
	if texture_path == BTN_RESTORE_GENERATED or texture_path == BTN_RESTORE_GENERATED_PRESSED:
		return 58.0
	if texture_path == BTN_BUY_GENERATED or texture_path == BTN_BUY_GENERATED_PRESSED:
		return 58.0
	return 54.0


static func _layout_home_confirm_popup(panel: Panel) -> void:
	panel.position = Vector2(35.0, 255.0)
	panel.size = Vector2(410.0, 300.0)
	if panel.has_node("ConfirmLabel"):
		var label: Label = panel.get_node("ConfirmLabel")
		label.position = Vector2(58.0, 104.0)
		label.size = Vector2(294.0, 42.0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if panel.has_node("BtnConfirmYes"):
		var yes_button: Button = panel.get_node("BtnConfirmYes")
		yes_button.position = Vector2(55.0, 194.0)
		yes_button.size = Vector2(150.0, 48.0)
	if panel.has_node("BtnConfirmNo"):
		var no_button: Button = panel.get_node("BtnConfirmNo")
		no_button.position = Vector2(205.0, 194.0)
		no_button.size = Vector2(150.0, 48.0)


static func _style_settings_content(panel: Panel) -> void:
	var text_color := Color(0.30, 0.18, 0.09)
	var sub_color := Color(0.10, 0.38, 0.32)
	for node in panel.find_children("*", "Label", true, false):
		var label := node as Label
		label.add_theme_color_override("font_color", sub_color)
		label.add_theme_color_override("font_outline_color", Color(1.0, 0.96, 0.82, 0.72))
		label.add_theme_constant_override("outline_size", 3)
	for node in panel.find_children("*", "CheckBox", true, false):
		var check := node as CheckBox
		check.add_theme_color_override("font_color", text_color)
		check.add_theme_color_override("font_hover_color", text_color)
		check.add_theme_color_override("font_pressed_color", text_color)
		check.add_theme_color_override("font_outline_color", Color(1.0, 0.96, 0.82, 0.72))
		check.add_theme_constant_override("outline_size", 3)


static func _style_tree(node: Node) -> void:
	if node is Label:
		var label := node as Label
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.14, 1.0))
		label.add_theme_constant_override("outline_size", 4)
	elif node is CheckBox:
		var check := node as CheckBox
		check.add_theme_color_override("font_color", Color.WHITE)
		check.add_theme_color_override("font_hover_color", Color.WHITE)
		check.add_theme_color_override("font_pressed_color", Color.WHITE)
		check.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.14, 1.0))
		check.add_theme_constant_override("outline_size", 4)
	elif node is Button:
		apply_button(node as Button, "blue")

	for child in node.get_children():
		_style_tree(child)
