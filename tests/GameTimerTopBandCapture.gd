extends Control

const GAME_SCENE := preload("res://game.tscn")
const VIEWPORT_SIZE := Vector2i(480, 854)
const CAPTURE_RECT := Rect2i(0, 0, 480, 240)
const OUTPUT_PATH := "res://artifacts/visual_evidence/timer_top_band_20260828/machiate_timer_top_band_en_y1_480x240.png"

var _failed := false
var _game: Control = null
var _original_stage := ""
var _original_language := "ja"
var _original_timer_enabled := false
var _original_timer_seconds := 0
var _original_question_count := 0
var _original_bgm_yume := false
var _original_custom_difficulty := "stage1"


func _enter_tree() -> void:
	get_window().size = VIEWPORT_SIZE
	get_window().content_scale_size = VIEWPORT_SIZE


func _ready() -> void:
	_original_stage = GameState.current_stage
	_original_language = SaveData.language_code
	_original_timer_enabled = SaveData.custom_timer_enabled
	_original_timer_seconds = SaveData.custom_timer_seconds
	_original_question_count = SaveData.custom_question_count
	_original_bgm_yume = SaveData.custom_bgm_yume
	_original_custom_difficulty = SaveData.custom_difficulty
	GameState.current_stage = "custom"
	SaveData.language_code = "en"
	SaveData.custom_timer_enabled = true
	SaveData.custom_timer_seconds = 10
	SaveData.custom_question_count = 10
	SaveData.custom_bgm_yume = true
	SaveData.custom_difficulty = "stage1"

	_game = GAME_SCENE.instantiate() as Control
	_assert(_game != null, "game scene instantiates for top-band capture")
	if _game == null:
		await _finish()
		return
	add_child(_game)
	await get_tree().process_frame
	(_game.get_node("StageIntro/IntroPanel") as Control).visible = false
	_game.set("timer_enabled", true)
	_game.set("time_left", 9.9)
	_game.call("setup_timer_display")
	_game.call("update_timer_display")
	(_game.get_node("TimerLabel") as Label).visible = true
	(_game.get_node("ScoreDisplay") as Control).visible = true
	(_game.get_node("FaceBoss") as TextureRect).visible = true
	_game.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().process_frame
	RenderingServer.force_draw(false)
	_capture_top_band()
	await _finish()


func _capture_top_band() -> void:
	var viewport_image := get_viewport().get_texture().get_image()
	_assert(viewport_image != null and not viewport_image.is_empty(), "offscreen viewport produces an image")
	if viewport_image == null or viewport_image.is_empty():
		return
	_assert(viewport_image.get_size() == VIEWPORT_SIZE, "offscreen viewport is exactly 480x854")
	if viewport_image.get_size() != VIEWPORT_SIZE:
		return
	var timer := _game.get_node("TimerLabel") as Label
	var score := _game.get_node("ScoreDisplay") as Control
	var face := _game.get_node("FaceBoss") as TextureRect
	_assert(timer.text == "Time left: 9.9s", "capture uses the longest English timer sample")
	_assert(Rect2(timer.position, timer.size) == Rect2(12.0, 1.0, 182.0, 45.0), "capture keeps the corrected TimerLabel rectangle")
	_assert(Rect2(score.position, score.size) == Rect2(204.0, 18.0, 266.0, 45.0), "capture keeps the ScoreDisplay rectangle")
	_assert(Rect2(face.position, face.size) == Rect2(10.0, 40.0, 173.0, 173.0), "capture keeps the FaceBoss rectangle")
	var top_band := viewport_image.get_region(CAPTURE_RECT)
	var absolute_output := ProjectSettings.globalize_path(OUTPUT_PATH)
	var output_dir := absolute_output.get_base_dir()
	var mkdir_error := DirAccess.make_dir_recursive_absolute(output_dir)
	_assert(mkdir_error == OK, "capture output directory is available")
	if mkdir_error != OK:
		return
	var save_error := top_band.save_png(absolute_output)
	_assert(save_error == OK, "top-band PNG saves successfully")
	if save_error == OK:
		print("CAPTURE timer_top_band path=%s viewport=480x854 crop=480x240 locale=en timer=%s score=%s face=%s" % [absolute_output, Rect2(timer.position, timer.size), Rect2(score.position, score.size), Rect2(face.position, face.size)])


func _finish() -> void:
	SaveData.language_code = _original_language
	SaveData.custom_timer_enabled = _original_timer_enabled
	SaveData.custom_timer_seconds = _original_timer_seconds
	SaveData.custom_question_count = _original_question_count
	SaveData.custom_bgm_yume = _original_bgm_yume
	SaveData.custom_difficulty = _original_custom_difficulty
	GameState.current_stage = _original_stage
	if AudioManager != null:
		AudioManager.stop_bgm()
	if _game != null and is_instance_valid(_game):
		_game.queue_free()
		_game = null
		await get_tree().process_frame
		await get_tree().process_frame
	if _failed:
		get_tree().quit(1)
		return
	print("PASS game_timer_top_band_capture viewport=480x854 crop=480x240 locale=en")
	get_tree().quit(0)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
