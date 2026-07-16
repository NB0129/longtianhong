extends RefCounted

const META_INSTALLED := "button_feedback_installed"
const META_SKIP := "button_feedback_skip"
const META_TWEEN := "button_feedback_tween"
const META_TARGET := "button_feedback_target"
const META_REST_MODULATE := "button_feedback_rest_modulate"
const META_PRESS_MODULATE := "button_feedback_press_modulate"
const META_USE_MODULATE := "button_feedback_use_modulate"

const PRESS_SCALE := Vector2(0.94, 0.94)
const PRESS_MODULATE := Color(1.16, 1.12, 0.84, 1.0)


static func install(root: Node) -> void:
	if root == null:
		return
	_install_tree(root)
	if not root.child_entered_tree.is_connected(_on_child_entered_tree):
		root.child_entered_tree.connect(_on_child_entered_tree)


static func skip(button: BaseButton) -> void:
	if button != null:
		button.set_meta(META_SKIP, true)


static func set_target(button: BaseButton, target: Control, rest_modulate := Color.WHITE, press_modulate := PRESS_MODULATE) -> void:
	if button != null and target != null:
		button.set_meta(META_TARGET, target)
		button.set_meta(META_REST_MODULATE, rest_modulate)
		button.set_meta(META_PRESS_MODULATE, press_modulate)


static func set_use_modulate(button: BaseButton, use_modulate: bool) -> void:
	if button != null:
		button.set_meta(META_USE_MODULATE, use_modulate)


static func _on_child_entered_tree(child: Node) -> void:
	_install_tree(child)


static func _install_tree(node: Node) -> void:
	var button := node as BaseButton
	if button != null:
		_install_button(button)
	for child in node.get_children():
		_install_tree(child)


static func _install_button(button: BaseButton) -> void:
	if button.has_meta(META_INSTALLED) or button.has_meta(META_SKIP):
		return
	if _should_skip_button(button):
		return
	button.set_meta(META_INSTALLED, true)
	button.focus_mode = Control.FOCUS_NONE
	button.button_down.connect(_on_button_down.bind(button))
	button.button_up.connect(_on_button_up.bind(button))
	button.visibility_changed.connect(_on_button_up.bind(button))
	button.tree_exiting.connect(_kill_tween.bind(button))


static func _should_skip_button(button: BaseButton) -> bool:
	if button.name.to_lower().contains("overlay"):
		return true
	var control := button as Control
	return control != null and (control.size.x > 420.0 or control.size.y > 760.0)


static func _on_button_down(button: BaseButton) -> void:
	if button == null or not is_instance_valid(button) or button.disabled:
		return
	_play_feedback(button, PRESS_SCALE, _press_modulate(button), 0.055)


static func _on_button_up(button: BaseButton) -> void:
	if button == null or not is_instance_valid(button):
		return
	var rest_modulate := _rest_modulate(button)
	var target_modulate := Color(rest_modulate.r, rest_modulate.g, rest_modulate.b, rest_modulate.a * 0.42) if button.disabled else rest_modulate
	_play_feedback(button, Vector2.ONE, target_modulate, 0.095)


static func _play_feedback(button: BaseButton, target_scale: Vector2, target_modulate: Color, duration: float) -> void:
	_kill_tween(button)
	var target := _feedback_target(button)
	if target == null:
		return
	_update_pivot(target)
	var tween := target.create_tween()
	button.set_meta(META_TWEEN, tween)
	tween.set_parallel(true)
	tween.tween_property(target, "scale", target_scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _use_modulate(button):
		tween.tween_property(target, "modulate", target_modulate, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void:
		if button != null and is_instance_valid(button) and button.get_meta(META_TWEEN, null) == tween:
			button.remove_meta(META_TWEEN)
	)


static func _feedback_target(button: BaseButton) -> Control:
	if button == null or not is_instance_valid(button):
		return null
	var target := button.get_meta(META_TARGET, null) as Control
	if target != null and is_instance_valid(target):
		return target
	return button as Control


static func _rest_modulate(button: BaseButton) -> Color:
	return button.get_meta(META_REST_MODULATE, Color.WHITE) as Color


static func _press_modulate(button: BaseButton) -> Color:
	return button.get_meta(META_PRESS_MODULATE, PRESS_MODULATE) as Color


static func _use_modulate(button: BaseButton) -> bool:
	return bool(button.get_meta(META_USE_MODULATE, true))


static func _kill_tween(button: BaseButton) -> void:
	if button == null or not is_instance_valid(button) or not button.has_meta(META_TWEEN):
		return
	var tween := button.get_meta(META_TWEEN) as Tween
	if tween != null and is_instance_valid(tween):
		tween.kill()
	button.remove_meta(META_TWEEN)


static func _update_pivot(control: Control) -> void:
	var pivot_size := control.size
	if pivot_size.x <= 0.0 or pivot_size.y <= 0.0:
		pivot_size = control.custom_minimum_size
	control.pivot_offset = pivot_size * 0.5
