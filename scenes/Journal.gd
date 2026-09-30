extends Control

const PLANT_DEFS := preload("res://data/plants.gd")

@onready var list: VBoxContainer = $Root/Scroll/List
@onready var back_button: Button = $Root/TopBar/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	_populate()

func _populate() -> void:
	for pid in PLANT_DEFS.ALL_IDS:
		var lbl := Label.new()
		if GameState.unlocked_plants.has(pid):
			lbl.text = "- %s  (reward %d)" % [PLANT_DEFS.display_name(pid), PLANT_DEFS.reward_of(pid)]
		else:
			lbl.text = "- ???  (locked)"
		list.add_child(lbl)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
