extends Node

const PLANT_DEFS := preload("res://data/plants.gd")
const PLOT_COUNT := 6
const ANTENNA_MAX := 3
const TICKS_PER_STAGE := 3

var rng_seed: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var tick: int = 0
var fragments: int = 0
var antenna := {"frequency": 0, "amplitude": 0, "phase": 0}
var plots: Array = []
var unlocked_plants: Array = []
var unlocked_hybrids: Array = []
var log_history: Array = []

func _ready() -> void:
	new_game()

func new_game() -> void:
	rng_seed = int(Time.get_unix_time_from_system())
	rng.seed = rng_seed
	tick = 0
	fragments = 0
	antenna = {"frequency": 0, "amplitude": 0, "phase": 0}
	plots.clear()
	for i in PLOT_COUNT:
		plots.append({"plant_id": "", "stage": 0, "ticks": 0})
	unlocked_plants = ["moss", "fern"]
	unlocked_hybrids = []
	log_history.clear()
	add_log("Signal acquired.")
	SignalBus.game_reset.emit()
	SignalBus.model_changed.emit()

func current_signal() -> Dictionary:
	var t := tick
	var freq := (rng_seed + t * 7) % (ANTENNA_MAX + 1)
	var amp  := (rng_seed + t * 13) % (ANTENNA_MAX + 1)
	var ph   := (rng_seed + t * 29) % (ANTENNA_MAX + 1)
	return {"frequency": freq, "amplitude": amp, "phase": ph}

func signal_match_strength() -> float:
	var target := current_signal()
	var total := 0
	var max_total := 0
	for axis in target.keys():
		var diff: int = abs(int(antenna[axis]) - int(target[axis]))
		max_total += ANTENNA_MAX
		total += max(0, ANTENNA_MAX - diff)
	if max_total == 0:
		return 0.0
	return float(total) / float(max_total)

func adjust_antenna(axis: String, delta: int) -> void:
	if not antenna.has(axis):
		return
	var v: int = clamp(int(antenna[axis]) + delta, 0, ANTENNA_MAX)
	if v == antenna[axis]:
		return
	antenna[axis] = v
	SignalBus.antenna_changed.emit(axis, v)
	SignalBus.model_changed.emit()

func can_plant(plot_index: int, plant_id: String) -> bool:
	if plot_index < 0 or plot_index >= plots.size():
		return false
	if plots[plot_index]["plant_id"] != "":
		return false
	if not unlocked_plants.has(plant_id):
		return false
	return true

func plant(plot_index: int, plant_id: String) -> bool:
	if not can_plant(plot_index, plant_id):
		return false
	plots[plot_index]["plant_id"] = plant_id
	plots[plot_index]["stage"] = 0
	plots[plot_index]["ticks"] = 0
	SignalBus.plant_planted.emit(plot_index, plant_id)
	SignalBus.model_changed.emit()
	return true

func advance_tick() -> void:
	tick += 1
	for i in plots.size():
		var p: Dictionary = plots[i]
		if p["plant_id"] == "":
			continue
		if p["stage"] >= 2:
			continue
		var strength := signal_match_strength()
		var needed := 0.35 + 0.5 * (1.0 - strength)
		if rng.randf() > needed:
			continue
		p["ticks"] += 1
		if p["ticks"] >= TICKS_PER_STAGE:
			p["ticks"] = 0
			p["stage"] += 1
	SignalBus.tick_advanced.emit(tick)
	SignalBus.model_changed.emit()

func harvest(plot_index: int) -> void:
	if plot_index < 0 or plot_index >= plots.size():
		return
	var p: Dictionary = plots[plot_index]
	if p["plant_id"] == "" or p["stage"] < 2:
		return
	var def: Dictionary = PLANT_DEFS.get_plant(p["plant_id"])
	var reward: int = int(def.get("reward", 1))
	fragments += reward
	SignalBus.plant_harvested.emit(plot_index, p["plant_id"], reward)
	SignalBus.fragments_changed.emit(fragments)
	add_log("%s harvested. +%d fragments." % [def.get("name", p["plant_id"]), reward])
	p["plant_id"] = ""
	p["stage"] = 0
	p["ticks"] = 0
	SignalBus.model_changed.emit()

func unlock_plant(plant_id: String) -> void:
	if not unlocked_plants.has(plant_id):
		unlocked_plants.append(plant_id)
		SignalBus.model_changed.emit()

func try_unlock_with_fragments() -> bool:
	var cost := 5
	if fragments < cost:
		return false
	for pid in PLANT_DEFS.ALL_IDS:
		if not unlocked_plants.has(pid):
			fragments -= cost
			unlock_plant(pid)
			SignalBus.fragments_changed.emit(fragments)
			add_log("New seed unlocked: %s." % PLANT_DEFS.get_plant(pid).get("name", pid))
			return true
	return false

func add_log(msg: String) -> void:
	log_history.push_front(msg)
	if log_history.size() > 20:
		log_history.resize(20)
	SignalBus.log_added.emit(msg)

func to_dict() -> Dictionary:
	return {
		"version": 1,
		"rng_seed": rng_seed,
		"tick": tick,
		"fragments": fragments,
		"antenna": antenna.duplicate(),
		"plots": plots.duplicate(true),
		"unlocked_plants": unlocked_plants.duplicate(),
		"unlocked_hybrids": unlocked_hybrids.duplicate(),
		"log_history": log_history.duplicate(),
	}

func from_dict(d: Dictionary) -> void:
	rng_seed = int(d.get("rng_seed", 0))
	rng.seed = rng_seed
	tick = int(d.get("tick", 0))
	fragments = int(d.get("fragments", 0))
	var a: Dictionary = d.get("antenna", {})
	antenna = {
		"frequency": int(a.get("frequency", 0)),
		"amplitude": int(a.get("amplitude", 0)),
		"phase": int(a.get("phase", 0)),
	}
	plots = d.get("plots", [])
	while plots.size() < PLOT_COUNT:
		plots.append({"plant_id": "", "stage": 0, "ticks": 0})
	unlocked_plants = d.get("unlocked_plants", ["moss", "fern"])
	unlocked_hybrids = d.get("unlocked_hybrids", [])
	log_history = d.get("log_history", [])
	SignalBus.game_loaded.emit()
	SignalBus.model_changed.emit()
