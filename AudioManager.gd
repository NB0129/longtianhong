extends Node
var bgm_player: AudioStreamPlayer
var se_players: Array = []
const SE_PLAYER_COUNT: int = 4
var bgm_volume: float = 0.3
var se_volume: float = 0.5
var current_bgm: String = ""
var _se_stream_cache: Dictionary = {}

func _ready() -> void:
	print("AudioManager._ready が呼ばれた")
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)
	
	for i in range(SE_PLAYER_COUNT):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		se_players.append(player)
	
	print("AudioManager._ready 完了。子ノード数: ", get_child_count())

func play_bgm(filename: String) -> void:
	print("play_bgm 呼ばれた、ファイル名: ", filename)
	
	if current_bgm == filename and bgm_player.playing:
		print("既に同じBGMが鳴ってるのでスキップ")
		return
	
	var path = "res://assets/audio/bgm/" + filename + ".ogg"
	print("読み込むパス: ", path)
	var stream = _load_bgm_stream(filename, true)
	print("ロード結果: ", stream)
	
	if stream == null:
		print("stream が null だった")
		push_warning("BGMファイルが見つかりません: " + path)
		return
	
	bgm_player.stream = stream
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.play()
	print("play() を呼んだ。playing: ", bgm_player.playing)
	current_bgm = filename

func play_bgm_once(filename: String) -> void:
	var path = "res://assets/audio/bgm/" + filename + ".ogg"
	var stream = _load_bgm_stream(filename, false)
	if stream == null:
		push_warning("BGMファイルが見つかりません: " + path)
		return
	bgm_player.stream = stream
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.play()
	current_bgm = filename

func _load_bgm_stream(filename: String, should_loop: bool) -> AudioStream:
	var path = "res://assets/audio/bgm/" + filename + ".ogg"
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return null

	stream = stream.duplicate()
	_apply_loop_setting(stream, should_loop)
	return stream

func _apply_loop_setting(stream: AudioStream, should_loop: bool) -> void:
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if should_loop else AudioStreamWAV.LOOP_DISABLED
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate) if should_loop else -1
	elif stream is AudioStreamOggVorbis:
		stream.loop = should_loop
		stream.loop_offset = 0.0
	elif stream is AudioStreamMP3:
		stream.loop = should_loop
		stream.loop_offset = 0.0

func stop_bgm() -> void:
	bgm_player.stop()
	current_bgm = ""

func play_se(filename: String) -> void:
	var se_path: String = "res://assets/audio/se/" + filename + ".wav"
	if not ResourceLoader.exists(se_path):
		se_path = "res://assets/audio/se/" + filename + ".mp3"
	var stream: AudioStream = _get_cached_se_stream(filename, se_path)
	if stream == null:
		push_warning("SEファイルが見つかりません: " + se_path)
		return
	
	for player in se_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(se_volume)
			player.play()
			return
	
	se_players[0].stream = stream
	se_players[0].volume_db = linear_to_db(se_volume)
	se_players[0].play()

func _get_cached_se_stream(filename: String, se_path: String) -> AudioStream:
	if _se_stream_cache.has(filename):
		return _se_stream_cache[filename] as AudioStream

	var stream: AudioStream = load(se_path) as AudioStream if ResourceLoader.exists(se_path) else null
	if stream != null:
		_se_stream_cache[filename] = stream
	return stream
