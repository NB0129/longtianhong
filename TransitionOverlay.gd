extends CanvasLayer

var _fade_rect: ColorRect
var _fade_tween: Tween

func _ready() -> void:
	layer = 1000
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_fade_rect.visible = false
	add_child(_fade_rect)
	_resize_fade_rect()
	get_viewport().size_changed.connect(_resize_fade_rect)

func _resize_fade_rect() -> void:
	if is_instance_valid(_fade_rect):
		_fade_rect.position = Vector2.ZERO
		_fade_rect.size = get_viewport().get_visible_rect().size

func fade_to_black(duration: float) -> void:
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
	_fade_rect.visible = true
	_fade_tween = create_tween()
	_fade_tween.set_ease(Tween.EASE_IN)
	_fade_tween.set_trans(Tween.TRANS_SINE)
	_fade_tween.tween_property(_fade_rect, "color:a", 1.0, duration)
	await _fade_tween.finished

func fade_from_black(duration: float) -> void:
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
	_fade_rect.visible = true
	_fade_rect.color.a = 1.0
	_fade_tween = create_tween()
	_fade_tween.set_ease(Tween.EASE_OUT)
	_fade_tween.set_trans(Tween.TRANS_SINE)
	_fade_tween.tween_property(_fade_rect, "color:a", 0.0, duration)
	await _fade_tween.finished
	_fade_rect.visible = false
