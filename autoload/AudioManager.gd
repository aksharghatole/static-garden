extends Node

var _ambient: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx := 0
const SFX_POOL := 4

const AMBIENT_PATH := "res://audio/ambient_hum.ogg"
const SFX_PATHS := {
	"plant": "res://audio/plant_pop.ogg",
	"harvest": "res://audio/harvest.ogg",
	"tick": "res://audio/dial_tick.ogg",
}

var master_volume: float = 0.8
var sfx_volume: float = 1.0

func _ready() -> void:
	_ambient = AudioStreamPlayer.new()
	_ambient.volume_db = linear_to_db(master_volume * 0.6)
	add_child(_ambient)
	if ResourceLoader.exists(AMBIENT_PATH):
		_ambient.stream = load(AMBIENT_PATH)
		_ambient.play()

	for i in SFX_POOL:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sfx_players.append(p)

func play_sfx(key: String) -> void:
	if not SFX_PATHS.has(key):
		return
	var path: String = SFX_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	var p := _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % SFX_POOL
	p.stream = load(path)
	p.volume_db = linear_to_db(master_volume * sfx_volume)
	p.play()

func set_master_volume(v: float) -> void:
	master_volume = clamp(v, 0.0, 1.0)
	if _ambient:
		_ambient.volume_db = linear_to_db(master_volume * 0.6)

func set_sfx_volume(v: float) -> void:
	sfx_volume = clamp(v, 0.0, 1.0)
