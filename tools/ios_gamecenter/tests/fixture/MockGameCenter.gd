class_name MockGameCenter
extends RefCounted

var authenticated := false
var game_player_id := "player-a"
var player_id_persistent := true
var authenticate_result: Variant = OK
var post_score_result: Variant = OK
var show_result: Variant = OK
var pending_events: Array[Dictionary] = []
var calls: Array[Dictionary] = []


func authenticate(payload: Dictionary = {}) -> Variant:
	calls.append({"method": "authenticate", "payload": payload.duplicate(true)})
	return authenticate_result


func is_authenticated() -> bool:
	return authenticated


func get_player_identity() -> Dictionary:
	return {
		"authenticated": authenticated,
		"persistent": player_id_persistent,
		"game_player_id": game_player_id,
	}


func post_score(payload: Dictionary) -> Variant:
	calls.append({"method": "post_score", "payload": payload.duplicate(true)})
	if str(payload.get("expected_game_player_id", "")) != game_player_id:
		return ERR_UNAUTHORIZED
	return post_score_result


func show_game_center(payload: Dictionary) -> Variant:
	calls.append({"method": "show_game_center", "payload": payload.duplicate(true)})
	return show_result


func get_pending_event_count() -> int:
	return pending_events.size()


func pop_pending_event() -> Variant:
	if pending_events.is_empty():
		return {}
	return pending_events.pop_front()


func push_event(event: Dictionary) -> void:
	pending_events.append(event.duplicate(true))


func push_authentication_result(call_index: int, result: String = "ok", error_description: String = "") -> void:
	var authentication_calls := calls_for("authenticate")
	if call_index < 0 or call_index >= authentication_calls.size():
		return
	var payload: Dictionary = authentication_calls[call_index]["payload"]
	var event := {
		"type": "authentication",
		"result": result,
		"request_id": str(payload.get("request_id", "")),
	}
	if error_description != "":
		event["error_description"] = error_description
	push_event(event)


func push_score_result(call_index: int, result: String = "ok", error_description: String = "") -> void:
	var score_calls := calls_for("post_score")
	if call_index < 0 or call_index >= score_calls.size():
		return
	var payload: Dictionary = score_calls[call_index]["payload"]
	var event := {
		"type": "post_score",
		"result": result,
		"category": str(payload.get("category", "")),
		"score": int(payload.get("score", 0)),
		"game_player_id": str(payload.get("expected_game_player_id", "")),
		"request_id": str(payload.get("request_id", "")),
	}
	if error_description != "":
		event["error_description"] = error_description
	push_event(event)


func push_show_result(call_index: int, result: String = "ok", error_description: String = "") -> void:
	var show_calls := calls_for("show_game_center")
	if call_index < 0 or call_index >= show_calls.size():
		return
	var payload: Dictionary = show_calls[call_index]["payload"]
	var event := {
		"type": "show_game_center",
		"result": result,
		"request_id": str(payload.get("request_id", "")),
	}
	if error_description != "":
		event["error_description"] = error_description
	push_event(event)


func calls_for(method_name: String) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	for call in calls:
		if str(call.get("method", "")) == method_name:
			matches.append(call)
	return matches
