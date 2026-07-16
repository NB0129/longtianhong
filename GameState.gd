extends Node

var current_stage: String = ""
var two_row_layout: bool = false
var debug_mode: bool = false
var came_from_stage3: bool = false
var came_from_ex: bool = false
var endless_block: int = 0
var endless_total_question: int = 0
var is_instant_mode: bool = false
var phase_entry_fade_pending: bool = false
var talk_scene_id: String = ""
var talk_return_scene: String = ""
var run_total_score: int = 0
var run_time_bonus_total: int = 0
var run_answer_times: Array[float] = []
var run_wait_bonus_counts: Dictionary = {4: 0, 5: 0, 6: 0, 7: 0}

func reset_run_score() -> void:
	run_total_score = 0
	run_time_bonus_total = 0
	run_answer_times.clear()
	run_wait_bonus_counts = {4: 0, 5: 0, 6: 0, 7: 0}
