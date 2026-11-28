extends RefCounted

const PLANTS := preload("res://data/plants.gd")
const VERSION := 1

static func integer(value: Variant, low: int, high: int) -> bool:
	if not (value is int or value is float):
		return false
	return is_finite(float(value)) and value >= low and value <= high and floor(float(value)) == float(value)

static func future_version(value: Variant) -> bool:
	return value is Dictionary and integer(value.get("version"), VERSION + 1, 2147483647)

static func valid(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	if not integer(value.get("version"), VERSION, VERSION):
		return false
	for key in ["tick", "fragments", "rng_seed"]:
		if not integer(value.get(key), 0, 9007199254740991):
			return false
	if value.has("rng_state"):
		if not value.rng_state is String or not value.rng_state.is_valid_int():
			return false
	var antenna = value.get("antenna")
	if not antenna is Dictionary:
		return false
	for axis in ["frequency", "amplitude", "phase"]:
		if not integer(antenna.get(axis), 0, 3):
			return false
	var unlocked = value.get("unlocked_plants")
	var hybrids = value.get("unlocked_hybrids", [])
	var known: Array = PLANTS.ALL_IDS + PLANTS.HYBRID_IDS
	if not valid_ids(unlocked, known) or not valid_ids(hybrids, PLANTS.HYBRID_IDS):
		return false
	if not unlocked.has("moss") or not unlocked.has("fern"):
		return false
	for pid in PLANTS.HYBRID_IDS:
		if hybrids.has(pid) != unlocked.has(pid):
			return false
	var plots = value.get("plots")
	if not plots is Array or plots.size() != 6:
		return false
	for plot in plots:
		if not plot is Dictionary:
			return false
		var pid = plot.get("plant_id")
		if not pid is String or (pid != "" and not unlocked.has(pid)):
			return false
		if not integer(plot.get("stage"), 0, 2) or not integer(plot.get("ticks"), 0, 2):
			return false
		if pid == "" and (plot.stage != 0 or plot.ticks != 0):
			return false
	var logs = value.get("log_history", [])
	if not logs is Array or logs.size() > 20:
		return false
	for line in logs:
		if not line is String:
			return false
	return true

static func valid_ids(ids: Variant, allowed: Array) -> bool:
	if not ids is Array:
		return false
	var seen: Array = []
	for pid in ids:
		if not pid is String or not allowed.has(pid) or seen.has(pid):
			return false
		seen.append(pid)
	return true
