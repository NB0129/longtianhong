extends Node
var bgm_player: AudioStreamPlayer
var se_players: Array = []
const SE_PLAYER_COUNT: int = 4
var bgm_volume: float = 0.3
var se_volume: float = 0.5
var current_bgm: String = ""

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
	
	var path = "res://assets/audio/bgm/" + filename + ".wav"
	print("読み込むパス: ", path)
	var stream = load(path)
	print("ロード結果: ", stream)
	
	if stream == null:
		print("stream が null だった")
		push_warning("BGMファイルが見つかりません: " + path)
		return
	
	if stream is AudioStreamWAV:
		stream = stream.duplicate()
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	
	bgm_player.stream = stream
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.play()
	print("play() を呼んだ。playing: ", bgm_player.playing)
	current_bgm = filename

func play_bgm_once(filename: String) -> void:
	var path = "res://assets/audio/bgm/" + filename + ".wav"
	var stream = load(path)
	if stream == null:
		push_warning("BGMファイルが見つかりません: " + path)
		return
	bgm_player.stream = stream
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.play()
	current_bgm = filename

func stop_bgm() -> void:
	bgm_player.stop()
	current_bgm = ""

func play_se(filename: String) -> void:
	var se_path = "res://assets/audio/se/" + filename + ".wav"
	var stream = load(se_path)
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
