extends RefCounted

const ALL_IDS := ["moss", "fern", "lily", "orchid"]

const HYBRID_IDS := ["mist", "dewbell", "voidmoss", "fernlily", "thornfern", "moonflower"]
const HYBRID_TABLE := {
	"fern:moss": "mist",
	"lily:moss": "dewbell",
	"moss:orchid": "voidmoss",
	"fern:lily": "fernlily",
	"fern:orchid": "thornfern",
	"lily:orchid": "moonflower"
}
const HYBRIDS := {
	"mist": {"id": "mist", "name": "Mist", "color": Color("#91cfc0"), "reward": 5, "parents": ["fern", "moss"]},
	"dewbell": {"id": "dewbell", "name": "Dewbell", "color": Color("#b5dfae"), "reward": 6, "parents": ["lily", "moss"]},
	"voidmoss": {"id": "voidmoss", "name": "Voidmoss", "color": Color("#9479cc"), "reward": 9, "parents": ["moss", "orchid"]},
	"fernlily": {"id": "fernlily", "name": "Fernlily", "color": Color("#d0e8b3"), "reward": 8, "parents": ["fern", "lily"]},
	"thornfern": {"id": "thornfern", "name": "Thornfern", "color": Color("#dc9fbc"), "reward": 11, "parents": ["fern", "orchid"]},
	"moonflower": {"id": "moonflower", "name": "Moonflower", "color": Color("#e4d5ff"), "reward": 12, "parents": ["lily", "orchid"]}
}

static func hybrid_of(a: String, b: String) -> String:
	var pair: Array[String] = [a, b]
	pair.sort()
	return HYBRID_TABLE.get(":".join(pair), "")

static func get_plant(id: String) -> Dictionary:
	if HYBRIDS.has(id):
		return HYBRIDS[id].duplicate(true)
	match id:
		"moss":
			return {"id":"moss","name":"Moss","color":Color(0.35,0.75,0.45),"reward":1,"signal":{"frequency":0,"amplitude":0,"phase":0}}
		"fern":
			return {"id":"fern","name":"Fern","color":Color(0.30,0.65,0.35),"reward":2,"signal":{"frequency":1,"amplitude":1,"phase":0}}
		"lily":
			return {"id":"lily","name":"Lily","color":Color(0.85,0.85,0.95),"reward":3,"signal":{"frequency":2,"amplitude":1,"phase":2}}
		"orchid":
			return {"id":"orchid","name":"Orchid","color":Color(0.85,0.55,0.85),"reward":5,"signal":{"frequency":3,"amplitude":3,"phase":3}}
	return {"id":id,"name":id,"color":Color.WHITE,"reward":1,"signal":{}}

static func display_name(id: String) -> String:
	return get_plant(id).get("name", id)

static func color_of(id: String) -> Color:
	return get_plant(id).get("color", Color.WHITE)

static func reward_of(id: String) -> int:
	return int(get_plant(id).get("reward", 1))
