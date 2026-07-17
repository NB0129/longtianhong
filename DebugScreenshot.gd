extends Node

const SCREENSHOT_DIR := "user://screenshots"

var _capturing := false


func _ready() -> void:
	set_process_input(OS.is_debug_build())


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F12 or event.physical_keycode == KEY_F12:
			get_viewport().set_input_as_handled()
			capture()


func capture() -> void:
	if not OS.is_debug_build():
		return
	if _capturing:
		return
	_capturing = true
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("スクリーンショットの取得に失敗しました")
		_capturing = false
		return
	var absolute_directory := ProjectSettings.globalize_path(SCREENSHOT_DIR)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		push_error("スクリーンショット保存先を作成できません: " + str(directory_error))
		_capturing = false
		return
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	var filename: String = "longtianhong_%04d%02d%02d_%02d%02d%02d_%03d.png" % [
		int(datetime["year"]),
		int(datetime["month"]),
		int(datetime["day"]),
		int(datetime["hour"]),
		int(datetime["minute"]),
		int(datetime["second"]),
		Time.get_ticks_msec() % 1000,
	]
	var output_path: String = absolute_directory.path_join(filename)
	var save_error: Error = image.save_png(output_path)
	if save_error == OK:
		print("スクリーンショットを保存しました: ", output_path)
	else:
		push_error("スクリーンショットの保存に失敗しました: " + str(save_error))
	_capturing = false
