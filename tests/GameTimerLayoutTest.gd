extends Control

const GAME_SCENE := preload("res://game.tscn")

const TIMER_TEXT := {
	"ja": "残り：9.9秒",
	"en": "Time left: 9.9s",
	"zh_CN": "剩余：9.9秒",
	"zh_TW": "剩餘：9.9秒",
	"ko": "남은 시간: 9.9초",
}

var _failed := false
var _game: Control = null
var _original_stage := ""
var _original_language := "ja"
var _original_timer_enabled := false
var _original_timer_seconds := 0
var _original_question_count := 0
var _original_bgm_yume := false


func _ready() -> void:
	_original_stage = GameState.current_stage
	_original_language = SaveData.language_code
	_original_timer_enabled = SaveData.custom_timer_enabled
	_original_timer_seconds = SaveData.custom_timer_seconds
	_original_question_count = SaveData.custom_question_count
	_original_bgm_yume = SaveData.custom_bgm_yume
	GameState.current_stage = "custom"
	SaveData.language_code = "ja"
	SaveData.custom_timer_enabled = true
	SaveData.custom_timer_seconds = 10
	SaveData.custom_question_count = 10
	SaveData.custom_bgm_yume = true

	_game = GAME_SCENE.instantiate() as Control
	_assert(_game != null, "game scene instantiates for timer layout")
	if _game == null:
		await _finish()
		return
	add_child(_game)
	await get_tree().process_frame
	await get_tree().process_frame
	_validate_fixed_rectangles()
	_validate_locale_containment()
	await _finish()


func _validate_fixed_rectangles() -> void:
	var timer := _game.get_node("TimerLabel") as Label
	var score := _game.get_node("ScoreDisplay") as Control
	var face := _game.get_node("FaceBoss") as TextureRect
	var timer_rect := Rect2(timer.position, timer.size)
	var score_rect := Rect2(score.position, score.size)
	var face_rect := Rect2(face.position, face.size)
	var face_visible_rect := _texture_visible_alpha_rect(face)
	var face_visible_overlap := timer_rect.intersection(face_visible_rect)
	print("CHECK game_timer_rects timer=%s score=%s gap=%.1f face_control=%s face_visible_alpha=%s visible_overlap=%s" % [timer_rect, score_rect, score_rect.position.x - timer_rect.end.x, face_rect, face_visible_rect, face_visible_overlap])
	_assert(timer_rect == Rect2(12.0, 1.0, 182.0, 45.0), "TimerLabel is exactly (12,1,182,45)")
	_assert(score_rect == Rect2(204.0, 18.0, 266.0, 45.0), "ScoreDisplay remains exactly (204,18,266,45)")
	_assert(is_equal_approx(score_rect.position.x - timer_rect.end.x, 10.0), "TimerLabel keeps a 10px gap before ScoreDisplay")
	_assert(not timer_rect.intersects(score_rect), "TimerLabel and ScoreDisplay do not overlap")
	_assert(face_rect == Rect2(10.0, 40.0, 173.0, 173.0), "FaceBoss control rectangle remains exactly (10,40,173,173)")
	_assert(not timer_rect.intersects(face_visible_rect), "TimerLabel does not overlap visible FaceBoss texture alpha")
	_assert((_game.get_node("TopBar") as Control).position.y == 780.0, "timer layout does not move TopBar")
	_assert((_game.get_node("Keypad") as Control).position == Vector2(51.0, 470.0), "timer layout does not move Keypad")


func _texture_visible_alpha_rect(texture_rect: TextureRect) -> Rect2:
	_assert(texture_rect.texture != null, "FaceBoss has a runtime texture")
	_assert(texture_rect.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "FaceBoss uses deterministic keep-aspect-centered rendering")
	if texture_rect.texture == null:
		return Rect2()
	var image := texture_rect.texture.get_image()
	_assert(image != null and not image.is_empty(), "FaceBoss runtime texture decodes to an image")
	if image == null or image.is_empty():
		return Rect2()
	var used_pixels := image.get_used_rect()
	_assert(used_pixels.size.x > 0 and used_pixels.size.y > 0, "FaceBoss runtime texture contains visible alpha")
	if used_pixels.size.x <= 0 or used_pixels.size.y <= 0:
		return Rect2()
	var source_size := Vector2(image.get_width(), image.get_height())
	var draw_scale := minf(texture_rect.size.x / source_size.x, texture_rect.size.y / source_size.y)
	var draw_size := source_size * draw_scale
	var draw_offset := (texture_rect.size - draw_size) * 0.5
	var visible_rect := Rect2(
		texture_rect.position + draw_offset + Vector2(used_pixels.position) * draw_scale,
		Vector2(used_pixels.size) * draw_scale
	)
	print("CHECK game_face_alpha source=%sx%s used_pixels=%s draw_scale=%.6f draw_offset=%s visible_rect=%s" % [image.get_width(), image.get_height(), used_pixels, draw_scale, draw_offset, visible_rect])
	return visible_rect


func _validate_locale_containment() -> void:
	var timer := _game.get_node("TimerLabel") as Label
	_game.set("timer_enabled", true)
	_game.set("time_left", 9.9)
	_game.call("setup_timer_display")
	var font_size := timer.get_theme_font_size("font_size")
	_assert(font_size == 22, "TimerLabel uses the preferred font size 22")
	_assert(timer.autowrap_mode == TextServer.AUTOWRAP_OFF, "TimerLabel remains one line")
	_assert(not timer.clip_text, "TimerLabel does not clip text")
	_assert(timer.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "TimerLabel does not trim or ellipsize text")
	_assert(timer.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "TimerLabel vertically centers its text")
	for locale: String in TIMER_TEXT:
		SaveData.language_code = locale
		_game.call("update_timer_display")
		_assert(timer.text == str(TIMER_TEXT[locale]), "%s TimerLabel keeps the existing localized copy" % locale)
		var font := timer.get_theme_font("font")
		var rendered_size := font.get_string_size(timer.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
		var rendered_height := font.get_height(font_size)
		_assert(rendered_size.x <= timer.size.x, "%s TimerLabel rendered width fits 182px" % locale)
		_assert(rendered_height <= timer.size.y, "%s TimerLabel rendered height fits 45px" % locale)
	print("CHECK game_timer_locales locales=5 font=%d containment=1 one_line=1 clip=0" % font_size)


func _finish() -> void:
	SaveData.language_code = _original_language
	SaveData.custom_timer_enabled = _original_timer_enabled
	SaveData.custom_timer_seconds = _original_timer_seconds
	SaveData.custom_question_count = _original_question_count
	SaveData.custom_bgm_yume = _original_bgm_yume
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
	print("PASS game_timer_layout rect=12,1,182,45 score_fixed=1 gap=10 locales=5 font=22 containment=1 face_visible_alpha_clear=1")
	get_tree().quit(0)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
