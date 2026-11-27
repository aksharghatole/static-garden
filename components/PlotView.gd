extends Button

const PLANTS := preload("res://data/plants.gd")
const STAGES: Array[String] = ["Seed", "Sprout", "Ready"]
var plant_id: String = ""
var stage: int = 0
const HARVEST_EFFECT := preload("res://components/HarvestEffect.gd")
var harvest_effect: Control

@onready var art: Control = $Content/PlantArt
@onready var name_label: Label = $Content/PlantName
@onready var stage_label: Label = $Content/Stage

func _ready() -> void:
	harvest_effect = HARVEST_EFFECT.new()
	harvest_effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(harvest_effect)
	harvest_effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_plot({})

func celebrate_harvest(pid: String, amount: int) -> void:
	harvest_effect.play(amount, PLANTS.color_of(pid))

func set_plot(plot: Dictionary) -> void:
	plant_id = str(plot.get("plant_id", ""))
	stage = clampi(int(plot.get("stage", 0)), 0, 2)
	var occupied := not plant_id.is_empty()
	name_label.text = PLANTS.display_name(plant_id) if occupied else "Empty"
	stage_label.text = STAGES[stage] if occupied else "Tap to plant"
	stage_label.modulate = Color("#bbec9e") if occupied and stage == 2 else Color("#a1b7aa")
	tooltip_text = "%s — %s" % [name_label.text, stage_label.text]
	art.set_plant(plant_id, stage)
