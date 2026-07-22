extends Node

var ranking_best_scores: Dictionary = {}
var ranking_pending_scores: Dictionary = {}
var ios_ranking_pending_scores_by_player: Dictionary = {}
var ios_ranking_unowned_scores: Dictionary = {}


func reset() -> void:
	ranking_best_scores.clear()
	ranking_pending_scores.clear()
	ios_ranking_pending_scores_by_player.clear()
	ios_ranking_unowned_scores.clear()


func get_ranking_best_score(stage_key: String) -> int:
	return int(ranking_best_scores.get(stage_key, 0))


func record_ranking_score(stage_key: String, score: int) -> bool:
	var changed := false
	if score > get_ranking_best_score(stage_key):
		ranking_best_scores[stage_key] = score
		changed = true
	if score > int(ranking_pending_scores.get(stage_key, 0)):
		ranking_pending_scores[stage_key] = score
		changed = true
	return changed


func get_pending_ranking_scores() -> Dictionary:
	return ranking_pending_scores.duplicate(true)


func clear_pending_ranking_score(stage_key: String, score: int = -1) -> void:
	if not ranking_pending_scores.has(stage_key):
		return
	if score >= 0 and int(ranking_pending_scores.get(stage_key, 0)) > score:
		return
	ranking_pending_scores.erase(stage_key)


func record_ios_ranking_score(player_id: String, stage_key: String, score: int) -> bool:
	if stage_key == "":
		return false
	var changed := false
	if score > get_ranking_best_score(stage_key):
		ranking_best_scores[stage_key] = score
		changed = true
	if player_id == "":
		if score > int(ios_ranking_unowned_scores.get(stage_key, 0)):
			ios_ranking_unowned_scores[stage_key] = score
			changed = true
		return changed
	var bucket: Dictionary = ios_ranking_pending_scores_by_player.get(player_id, {})
	if score > int(bucket.get(stage_key, 0)):
		bucket[stage_key] = score
		ios_ranking_pending_scores_by_player[player_id] = bucket
		changed = true
	return changed


func get_ios_pending_ranking_scores(player_id: String) -> Dictionary:
	if player_id == "":
		return {}
	var bucket: Variant = ios_ranking_pending_scores_by_player.get(player_id, {})
	return bucket.duplicate(true) if bucket is Dictionary else {}


func get_ios_unowned_ranking_scores() -> Dictionary:
	return ios_ranking_unowned_scores.duplicate(true)


func clear_ios_pending_ranking_score(player_id: String, stage_key: String, score: int = -1) -> void:
	if player_id == "" or not ios_ranking_pending_scores_by_player.has(player_id):
		return
	var bucket: Dictionary = ios_ranking_pending_scores_by_player[player_id]
	if not bucket.has(stage_key):
		return
	if score >= 0 and int(bucket.get(stage_key, 0)) > score:
		return
	bucket.erase(stage_key)
	if bucket.is_empty():
		ios_ranking_pending_scores_by_player.erase(player_id)
	else:
		ios_ranking_pending_scores_by_player[player_id] = bucket
