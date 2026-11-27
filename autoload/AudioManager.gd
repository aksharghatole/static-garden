extends Node

const SYNTH := preload("res://audio/Soundscape.gd")
const SFX_POOL := 4
const SETTINGS_PATH := "user://audio.cfg"

var _ambient: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx := 0
var _sounds: Dictionary = {}
var master_volume: float = 0.8
var music_volume: float = 0.65
var sfx_volume: float = 1.0

func _ready() -> void:
	_load_preferences()
	_sounds = {
		"tick": SYNTH.chime([440.0], 0.09, 0.0, 0.13),
		"plant": SYNTH.chime([392.0, 523.25], 0.18, 0.05),
		"harvest": SYNTH.chime([523.25, 659.25, 783.99], 0.28, 0.065),
		"advance": SYNTH.chime([293.66, 392.0], 0.20, 0.08, 0.15),
		"unlock": SYNTH.chime([440.0, 554.37, 659.25, 880.0], 0.36, 0.09, 0.22),
		"hybrid": SYNTH.chime([392.0, 523.25, 659.25, 783.99, 1046.5], 0.48, 0.10, 0.22),
	}
	_ambient = AudioStreamPlayer.new()
	_ambient.stream = SYNTH.ambient()
	add_child(_ambient)
	for i in range(SFX_POOL):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_players.append(player)
	_apply_volume()
	_ambient.play()
	SignalBus.hybrid_discovered.connect(_on_hybrid_discovered)

func _on_hybrid_discovered(_pid: String) -> void:
	play_sfx("hybrid")

func play_sfx(key: String) -> void:
	if not _sounds.has(key) or master_volume <= 0.0 or sfx_volume <= 0.0:
		return
	var player := _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % SFX_POOL
	player.stop()
	player.stream = _sounds[key]
	player.play()

func _volume_db(value: float) -> float:
	return linear_to_db(maxf(value, 0.00001))

func _apply_volume() -> void:
	if is_instance_valid(_ambient):
		_ambient.volume_db = _volume_db(master_volume * music_volume)
		_ambient.stream_paused = master_volume <= 0.0 or music_volume <= 0.0
	for player in _sfx_players:
		player.volume_db = _volume_db(master_volume * sfx_volume)
		if master_volume <= 0.0 or sfx_volume <= 0.0:
			player.stop()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_volume()
	_save_preferences()

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_volume()
	_save_preferences()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_volume()
	_save_preferences()

func _load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		master_volume = clampf(float(config.get_value("audio", "master", 0.8)), 0.0, 1.0)
		music_volume = clampf(float(config.get_value("audio", "music", 0.65)), 0.0, 1.0)
		sfx_volume = clampf(float(config.get_value("audio", "sfx", 1.0)), 0.0, 1.0)

func _save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	if config.save(SETTINGS_PATH) != OK:
		push_warning("Could not save audio preferences")
