extends RefCounted

const PREFERRED_TOUCH_TARGET := 48.0
const MINIMUM_TOUCH_TARGET := 44.0

const META_ACTIVE := "modal_foundation_active"
const META_INVOKER := "modal_foundation_invoker"
const META_FOCUS_PATHS := "modal_foundation_focus_paths"


static func configure_backdrop(backdrop: Control, panel: Control, backdrop_z: int) -> void:
	if backdrop == null or panel == null:
		return
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.focus_mode = Control.FOCUS_NONE
	backdrop.z_index = backdrop_z
	panel.z_index = backdrop_z + 1
	if backdrop is ColorRect:
		(backdrop as ColorRect).color = Color(0.0, 0.0, 0.0, 0.58)


static func open_modal(
		backdrop: Control,
		panel: Control,
		invoker: Control = null,
		preferred_focus: Control = null,
		backdrop_z: int = 40
	) -> Array[Control]:
	if backdrop == null or panel == null:
		return []
	configure_backdrop(backdrop, panel, backdrop_z)
	panel.set_meta(META_ACTIVE, true)
	panel.set_meta(META_INVOKER, weakref(invoker) if invoker != null and is_instance_valid(invoker) else null)
	backdrop.visible = true
	backdrop.move_to_front()
	panel.visible = true
	panel.move_to_front()
	var focus_controls := collect_focusable_controls(panel)
	configure_focus_ring(focus_controls)
	var target := preferred_focus
	if not _is_focus_candidate(target, panel):
		target = focus_controls[0] if not focus_controls.is_empty() else null
	if target != null:
		target.grab_focus()
	return focus_controls


static func close_modal(backdrop: Control, panel: Control, restore_focus: bool = true) -> void:
	if backdrop == null or panel == null:
		return
	var focus_target: Control = null
	var stored_invoker: Variant = panel.get_meta(META_INVOKER) if panel.has_meta(META_INVOKER) else null
	if stored_invoker is WeakRef:
		focus_target = (stored_invoker as WeakRef).get_ref() as Control
	panel.set_meta(META_ACTIVE, false)
	panel.set_meta(META_INVOKER, null)
	panel.visible = false
	backdrop.visible = false
	if restore_focus and _can_restore_focus(focus_target):
		focus_target.grab_focus()


static func collect_focusable_controls(panel: Control) -> Array[Control]:
	var result: Array[Control] = []
	if panel == null:
		return result
	for node in panel.find_children("*", "Control", true, false):
		var control := node as Control
		if _is_focus_candidate(control, panel):
			result.append(control)
	return result


static func configure_focus_ring(controls: Array[Control]) -> void:
	var valid_controls: Array[Control] = []
	for control in controls:
		if control != null and is_instance_valid(control) and control.focus_mode != Control.FOCUS_NONE:
			valid_controls.append(control)
	if valid_controls.is_empty():
		return
	var paths: Array[NodePath] = []
	for control in valid_controls:
		paths.append(control.get_path())
	for index in range(valid_controls.size()):
		var control := valid_controls[index]
		var previous_path := paths[(index - 1 + paths.size()) % paths.size()]
		var next_path := paths[(index + 1) % paths.size()]
		control.focus_neighbor_left = previous_path
		control.focus_neighbor_top = previous_path
		control.focus_previous = previous_path
		control.focus_neighbor_right = next_path
		control.focus_neighbor_bottom = next_path
		control.focus_next = next_path
	var panel := valid_controls[0].get_parent()
	while panel != null and panel is Control:
		if (panel as Control).has_meta(META_ACTIVE) and bool((panel as Control).get_meta(META_ACTIVE)):
			(panel as Control).set_meta(META_FOCUS_PATHS, paths)
			break
		panel = panel.get_parent()


static func ensure_minimum_touch_height(control: Control, preferred_height: float = PREFERRED_TOUCH_TARGET) -> float:
	if control == null:
		return 0.0
	var target_height := maxf(MINIMUM_TOUCH_TARGET, preferred_height)
	control.custom_minimum_size = Vector2(control.custom_minimum_size.x, maxf(control.custom_minimum_size.y, target_height))
	return control.custom_minimum_size.y


static func _is_focus_candidate(control: Control, panel: Control) -> bool:
	if control == null or not is_instance_valid(control) or control.focus_mode == Control.FOCUS_NONE:
		return false
	if panel != null and control != panel and not panel.is_ancestor_of(control):
		return false
	if control.is_inside_tree():
		if not control.is_visible_in_tree():
			return false
	elif not control.visible:
		return false
	if control is BaseButton and (control as BaseButton).disabled:
		return false
	return true


static func _can_restore_focus(control: Control) -> bool:
	if control == null or not is_instance_valid(control) or control.focus_mode == Control.FOCUS_NONE:
		return false
	if control is BaseButton and (control as BaseButton).disabled:
		return false
	return control.is_visible_in_tree() if control.is_inside_tree() else control.visible
