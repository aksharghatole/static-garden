extends Control

const PLANT_DEFS := preload("res://data/plants.gd")

@onready var list: VBoxContainer = $Root/Scroll/List
@onready var back_button: Button = $Root/TopBar/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	_populate()

func heading(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	list.add_child(label)

func entry(pid: String, discovered: bool, hint: String = "") -> void:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if discovered:
		label.text = "%s · %d fragments%s" % [PLANT_DEFS.display_name(pid), PLANT_DEFS.reward_of(pid), hint]
		label.modulate = PLANT_DEFS.color_of(pid).lightened(0.22)
	else:
		label.text = "Undiscovered%s" % hint
		label.modulate = Color("#a1b7aa")
	list.add_child(label)

func _populate() -> void:
	heading("Base species")
	for pid in PLANT_DEFS.ALL_IDS:
		entry(pid, GameState.unlocked_plants.has(pid))
	heading("Hybrids · %d / %d" % [GameState.unlocked_hybrids.size(), PLANT_DEFS.HYBRID_IDS.size()])
	for pid in PLANT_DEFS.HYBRID_IDS:
		var parents: Array = PLANT_DEFS.get_plant(pid)["parents"]
		var hint := "\n%s + %s" % [PLANT_DEFS.display_name(parents[0]), PLANT_DEFS.display_name(parents[1])]
		entry(pid, GameState.unlocked_hybrids.has(pid), hint)
	var instruction := Label.new()
	instruction.text = "Harvest adjacent mature base plants for a 25% chance of discovering a new hybrid. Diagonal plots do not count."
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list.add_child(instruction)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
