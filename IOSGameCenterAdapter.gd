class_name IOSGameCenterAdapter
extends RefCounted

signal login_state_changed(logged_in: bool)
signal player_identity_changed(player_id: String)
signal score_submit_finished(player_id: String, leaderboard_id: String, score: int, submitted_online: bool, message: String)
signal leaderboard_show_finished(leaderboard_id: String, success: bool, message: String)

const EVENT_DRAIN_LIMIT := 128
const AUTHENTICATION_TIMEOUT_SECONDS := 120.0
const SCORE_TIMEOUT_SECONDS := 30.0
const LEADERBOARD_TIMEOUT_SECONDS := 180.0
const REQUIRED_METHODS: Array[String] = [
	"authenticate",
	"is_authenticated",
	"get_player_identity",
	"post_score",
	"show_game_center",
	"get_pending_event_count",
	"pop_pending_event",
]

var _native: Object = null
var _authenticated := false
var _player_id := ""
var _authentication_initialized := false
var _authentication_in_flight := false
var _authentication_elapsed := 0.0
var _active_authentication_request_id := ""
var _submission_queue: Array[Dictionary] = []
var _active_submission: Dictionary = {}
var _active_submission_elapsed := 0.0
var _submissions_paused := false
var _show_pending := false
var _pending_show_leaderboard_id := ""
var _overlay_open := false
var _active_show_leaderboard_id := ""
var _active_show_request_id := ""
var _overlay_elapsed := 0.0
var _next_request_id := 0
var _next_show_request_id := 0
var _next_authentication_request_id := 0


func configure(native_singleton: Object) -> bool:
	_native = null
	if native_singleton == null:
		return false
	for method_name in REQUIRED_METHODS:
		if not native_singleton.has_method(method_name):
			push_error("[IOSGameCenterAdapter] GameCenter is missing method: %s" % method_name)
			return false
	_native = native_singleton
	refresh_authentication_state()
	return true


func is_available() -> bool:
	return _native != null


func is_logged_in() -> bool:
	return _authenticated and _player_id != ""


func get_player_id() -> String:
	return _player_id if is_logged_in() else ""


func login() -> bool:
	if not is_available():
		return false
	refresh_authentication_state()
	if is_logged_in():
		_authentication_initialized = true
		_authentication_in_flight = false
		_active_authentication_request_id = ""
		return true
	if _authentication_in_flight:
		return true
	var request_id := _new_authentication_request_id()
	_active_authentication_request_id = request_id
	var result: Variant = _native.call("authenticate", {"request_id": request_id})
	if not _is_accepted_result(result):
		_active_authentication_request_id = ""
		print("[IOSGameCenterAdapter] authenticate rejected result=", result)
		return false
	_authentication_initialized = true
	_authentication_in_flight = true
	_authentication_elapsed = 0.0
	return true


func submit_score(leaderboard_id: String, score: int, expected_player_id: String) -> bool:
	if not is_available() or leaderboard_id == "":
		return false
	var normalized_expected_player_id := expected_player_id.strip_edges()
	if not _is_valid_player_id(normalized_expected_player_id):
		return false
	if not login():
		return false
	if not is_logged_in() or _player_id != normalized_expected_player_id:
		return false
	_enqueue_submission(normalized_expected_player_id, leaderboard_id, maxi(0, score))
	_pump_operations()
	return true


func show_leaderboard(leaderboard_id: String = "") -> bool:
	if not is_available():
		return false
	if _overlay_open:
		return true
	if _show_pending:
		_pending_show_leaderboard_id = leaderboard_id
		if not is_logged_in() and not login():
			_show_pending = false
			_pending_show_leaderboard_id = ""
			return false
		return true
	_show_pending = true
	_pending_show_leaderboard_id = leaderboard_id
	if not login():
		_show_pending = false
		_pending_show_leaderboard_id = ""
		return false
	_pump_operations()
	return true


func poll(delta: float = 0.0) -> void:
	if not is_available():
		return
	_drain_events()
	if _authentication_in_flight:
		_authentication_elapsed += maxf(0.0, delta)
		if _authentication_elapsed >= AUTHENTICATION_TIMEOUT_SECONDS:
			_authentication_in_flight = false
			_authentication_initialized = false
			_authentication_elapsed = 0.0
			_active_authentication_request_id = ""
			refresh_authentication_state()
			if not is_logged_in() and _show_pending:
				var leaderboard_id := _pending_show_leaderboard_id
				_show_pending = false
				_pending_show_leaderboard_id = ""
				leaderboard_show_finished.emit(leaderboard_id, false, "authentication_timeout")
			_pump_operations()
	if not _active_submission.is_empty():
		_active_submission_elapsed += maxf(0.0, delta)
		if _active_submission_elapsed >= SCORE_TIMEOUT_SECONDS:
			var timed_out := _active_submission.duplicate(true)
			_active_submission.clear()
			_active_submission_elapsed = 0.0
			_submissions_paused = str(timed_out.get("player_id", "")) == _player_id
			score_submit_finished.emit(
				str(timed_out.get("player_id", "")),
				str(timed_out.get("leaderboard_id", "")),
				int(timed_out.get("score", 0)),
				false,
				"timeout"
			)
			_pump_operations()
	if _overlay_open:
		_overlay_elapsed += maxf(0.0, delta)
		if _overlay_elapsed >= LEADERBOARD_TIMEOUT_SECONDS:
			var timed_out_leaderboard_id := _active_show_leaderboard_id
			_overlay_open = false
			_active_show_leaderboard_id = ""
			_active_show_request_id = ""
			_overlay_elapsed = 0.0
			leaderboard_show_finished.emit(timed_out_leaderboard_id, false, "leaderboard_timeout")
			_pump_operations()


func on_application_resumed() -> void:
	if not is_available():
		return
	_drain_events()
	var should_retry_authentication := _authentication_in_flight or _show_pending
	_authentication_in_flight = false
	_authentication_initialized = false
	_authentication_elapsed = 0.0
	_active_authentication_request_id = ""
	_submissions_paused = false
	refresh_authentication_state()
	if should_retry_authentication and not is_logged_in() and not login():
		if _show_pending:
			var leaderboard_id := _pending_show_leaderboard_id
			_show_pending = false
			_pending_show_leaderboard_id = ""
			leaderboard_show_finished.emit(leaderboard_id, false, "authentication_failed")
	_pump_operations()


func refresh_authentication_state() -> bool:
	if not is_available():
		_set_player_identity(false, "")
		return false
	var identity: Variant = _native.call("get_player_identity")
	if not (identity is Dictionary):
		_set_player_identity(false, "")
		return false
	var identity_data: Dictionary = identity
	var player_id := str(identity_data.get("game_player_id", identity_data.get("player_id", ""))).strip_edges()
	var valid := (
		bool(identity_data.get("authenticated", false))
		and bool(identity_data.get("persistent", false))
		and _is_valid_player_id(player_id)
	)
	_set_player_identity(valid, player_id if valid else "")
	return is_logged_in()


func get_queued_submission_count() -> int:
	return _submission_queue.size() + (0 if _active_submission.is_empty() else 1)


func cancel_pending_leaderboard() -> void:
	_show_pending = false
	_pending_show_leaderboard_id = ""


func is_leaderboard_request_pending() -> bool:
	return _show_pending or _overlay_open


func _enqueue_submission(player_id: String, leaderboard_id: String, score: int) -> void:
	if (
		not _active_submission.is_empty()
		and str(_active_submission.get("player_id", "")) == player_id
		and str(_active_submission.get("leaderboard_id", "")) == leaderboard_id
	):
		if int(_active_submission.get("score", 0)) >= score:
			return
	for i in range(_submission_queue.size()):
		var queued: Dictionary = _submission_queue[i]
		if str(queued.get("player_id", "")) != player_id or str(queued.get("leaderboard_id", "")) != leaderboard_id:
			continue
		if score > int(queued.get("score", 0)):
			queued["score"] = score
			_submission_queue[i] = queued
		return
	_submission_queue.append({
		"player_id": player_id,
		"leaderboard_id": leaderboard_id,
		"score": score,
		"request_id": _new_request_id(player_id),
	})


func _pump_operations() -> void:
	if not is_available() or not is_logged_in() or _overlay_open:
		return
	if not _active_submission.is_empty():
		return
	if _show_pending:
		var priority_index := _find_pending_show_submission_index()
		if priority_index >= 0:
			var priority_submission: Dictionary = _submission_queue.pop_at(priority_index)
			_submission_queue.push_front(priority_submission)
			_start_next_submission()
		else:
			_present_pending_leaderboard()
		return
	if not _submissions_paused and not _submission_queue.is_empty():
		_start_next_submission()
		return


func _find_pending_show_submission_index() -> int:
	if _pending_show_leaderboard_id == "":
		return -1
	for i in range(_submission_queue.size()):
		var queued: Dictionary = _submission_queue[i]
		if (
			str(queued.get("player_id", "")) == _player_id
			and str(queued.get("leaderboard_id", "")) == _pending_show_leaderboard_id
		):
			return i
	return -1


func _start_next_submission() -> void:
	if _submission_queue.is_empty():
		return
	refresh_authentication_state()
	if _submission_queue.is_empty() or not is_logged_in():
		return
	_active_submission = _submission_queue.pop_front()
	_active_submission_elapsed = 0.0
	var payload := {
		"score": int(_active_submission.get("score", 0)),
		"category": str(_active_submission.get("leaderboard_id", "")),
		"expected_game_player_id": str(_active_submission.get("player_id", "")),
		"request_id": str(_active_submission.get("request_id", "")),
	}
	var result: Variant = _native.call("post_score", payload)
	if _is_accepted_result(result):
		return
	var rejected := _active_submission.duplicate(true)
	_active_submission.clear()
	_submissions_paused = true
	score_submit_finished.emit(
		str(rejected.get("player_id", "")),
		str(rejected.get("leaderboard_id", "")),
		int(rejected.get("score", 0)),
		false,
		"post_score_rejected:%s" % str(result)
	)
	_pump_operations()


func _present_pending_leaderboard() -> void:
	var leaderboard_id := _pending_show_leaderboard_id
	var request_id := _new_show_request_id()
	var payload := {"view": "leaderboards", "request_id": request_id}
	if leaderboard_id != "":
		payload["leaderboard_name"] = leaderboard_id
	_show_pending = false
	_pending_show_leaderboard_id = ""
	var result: Variant = _native.call("show_game_center", payload)
	if _is_accepted_result(result):
		_overlay_open = true
		_active_show_leaderboard_id = leaderboard_id
		_active_show_request_id = request_id
		_overlay_elapsed = 0.0
		return
	leaderboard_show_finished.emit(leaderboard_id, false, _show_rejection_message(result))


func _drain_events() -> void:
	var drained := 0
	while drained < EVENT_DRAIN_LIMIT:
		var count: int = int(_native.call("get_pending_event_count"))
		if count <= 0:
			break
		var event: Variant = _native.call("pop_pending_event")
		if event is Dictionary:
			_handle_event(event)
		drained += 1
	if drained == EVENT_DRAIN_LIMIT and int(_native.call("get_pending_event_count")) > 0:
		push_warning("[IOSGameCenterAdapter] Event drain limit reached")


func _handle_event(event: Dictionary) -> void:
	match str(event.get("type", "")):
		"authentication":
			_handle_authentication_event(event)
		"post_score":
			_handle_score_event(event)
		"show_game_center":
			_handle_show_event(event)


func _handle_authentication_event(event: Dictionary) -> void:
	var callback_request_id := str(event.get("request_id", ""))
	if callback_request_id == "" or callback_request_id != _active_authentication_request_id:
		print("[IOSGameCenterAdapter] Ignoring uncorrelated authentication event: ", event)
		return
	_authentication_in_flight = false
	_authentication_elapsed = 0.0
	_active_authentication_request_id = ""
	var succeeded := str(event.get("result", "")) == "ok"
	if succeeded:
		succeeded = refresh_authentication_state()
	else:
		succeeded = refresh_authentication_state()
		if not succeeded:
			_set_player_identity(false, "")
	if not succeeded and _show_pending:
		var leaderboard_id := _pending_show_leaderboard_id
		_show_pending = false
		_pending_show_leaderboard_id = ""
		var fallback := "player_identity_unavailable" if str(event.get("result", "")) == "ok" else "authentication_failed"
		leaderboard_show_finished.emit(leaderboard_id, false, _event_error_message(event, fallback))
	_pump_operations()


func _handle_score_event(event: Dictionary) -> void:
	var callback_id := str(event.get("leaderboard_id", event.get("category", "")))
	var callback_player_id := str(event.get("game_player_id", event.get("player_id", "")))
	var callback_request_id := str(event.get("request_id", ""))
	var callback_has_score := event.has("score")
	var callback_score := int(event.get("score", 0))
	if _active_submission.is_empty():
		_handle_late_score_event(event, callback_player_id, callback_request_id, callback_id, callback_score, callback_has_score)
		return
	var active_player_id := str(_active_submission.get("player_id", ""))
	var active_request_id := str(_active_submission.get("request_id", ""))
	var active_id := str(_active_submission.get("leaderboard_id", ""))
	var active_score := int(_active_submission.get("score", 0))
	if (
		callback_player_id != active_player_id
		or callback_request_id != active_request_id
		or callback_id != active_id
		or not callback_has_score
		or callback_score != active_score
	):
		_handle_late_score_event(event, callback_player_id, callback_request_id, callback_id, callback_score, callback_has_score)
		return
	var completed := _active_submission.duplicate(true)
	_active_submission.clear()
	_active_submission_elapsed = 0.0
	var leaderboard_id := str(completed.get("leaderboard_id", ""))
	var player_id := str(completed.get("player_id", ""))
	var score := int(completed.get("score", 0))
	var succeeded := str(event.get("result", "")) == "ok"
	if not succeeded and player_id == _player_id:
		_submissions_paused = true
	var message := "" if succeeded else _event_error_message(event, "post_score_failed")
	score_submit_finished.emit(player_id, leaderboard_id, score, succeeded, message)
	_pump_operations()


func _handle_late_score_event(
	event: Dictionary,
	callback_player_id: String,
	callback_request_id: String,
	callback_id: String,
	callback_score: int,
	callback_has_score: bool
) -> void:
	if callback_player_id == "" or callback_request_id == "" or callback_id == "" or not callback_has_score:
		print("[IOSGameCenterAdapter] Ignoring uncorrelated score event: ", event)
		return
	var succeeded := str(event.get("result", "")) == "ok"
	var message := "" if succeeded else _event_error_message(event, "post_score_failed")
	score_submit_finished.emit(callback_player_id, callback_id, callback_score, succeeded, message)


func _handle_show_event(event: Dictionary) -> void:
	var callback_request_id := str(event.get("request_id", ""))
	if not _overlay_open or callback_request_id == "" or callback_request_id != _active_show_request_id:
		print("[IOSGameCenterAdapter] Ignoring uncorrelated leaderboard event: ", event)
		return
	var leaderboard_id := _active_show_leaderboard_id
	_overlay_open = false
	_active_show_leaderboard_id = ""
	_active_show_request_id = ""
	_overlay_elapsed = 0.0
	var succeeded := str(event.get("result", "")) == "ok"
	leaderboard_show_finished.emit(leaderboard_id, succeeded, "" if succeeded else _event_error_message(event, "show_failed"))
	_pump_operations()


func _set_player_identity(authenticated: bool, player_id: String) -> void:
	var normalized_player_id := player_id.strip_edges() if authenticated else ""
	var old_logged_in := is_logged_in()
	var old_player_id := _player_id
	var identity_changed := old_player_id != normalized_player_id
	_authenticated = authenticated and normalized_player_id != ""
	_player_id = normalized_player_id if _authenticated else ""
	if identity_changed:
		_submission_queue.clear()
		_submissions_paused = false
		player_identity_changed.emit(_player_id)
	var new_logged_in := is_logged_in()
	if old_logged_in != new_logged_in:
		login_state_changed.emit(new_logged_in)
	if not new_logged_in:
		if _overlay_open:
			var interrupted_leaderboard_id := _active_show_leaderboard_id
			_overlay_open = false
			_active_show_leaderboard_id = ""
			_active_show_request_id = ""
			_overlay_elapsed = 0.0
			leaderboard_show_finished.emit(interrupted_leaderboard_id, false, "authentication_lost")
		_overlay_open = false


func _new_request_id(player_id: String) -> String:
	_next_request_id += 1
	return "%s:%d" % [player_id, _next_request_id]


func _new_show_request_id() -> String:
	_next_show_request_id += 1
	return "leaderboard:%d" % _next_show_request_id


func _new_authentication_request_id() -> String:
	_next_authentication_request_id += 1
	return "authentication:%d" % _next_authentication_request_id


static func _is_valid_player_id(player_id: String) -> bool:
	return player_id != "" and player_id != "GKPlayerIDNoLongerAvailable"


static func _show_rejection_message(result: Variant) -> String:
	if result is int:
		if int(result) == ERR_BUSY:
			return "native_ui_busy"
		if int(result) == ERR_UNAUTHORIZED:
			return "authentication_failed"
	return "show_rejected:%s" % str(result)


static func _is_accepted_result(result: Variant) -> bool:
	if result is bool:
		return bool(result)
	if result is int:
		return int(result) == OK
	return false


static func _event_error_message(event: Dictionary, fallback: String) -> String:
	var description := str(event.get("error_description", "")).strip_edges()
	var code := str(event.get("error_code", "")).strip_edges()
	if description != "" and code != "":
		return "%s:%s" % [code, description]
	if description != "":
		return description
	if code != "":
		return code
	return fallback
