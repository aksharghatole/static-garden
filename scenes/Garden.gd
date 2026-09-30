extends Control

const PLANT_DEFS := preload("res://data/plants.gd")
const STAGE_LABELS: Array[String] = ["seed", "sprout", "ready"]

@onready var dials_box: VBoxContainer = $Root/LeftPanel/Dials
@onready var signal_panel: Control = $Root/RightPanel/SignalPanel
@onready var plots_grid: GridContainer = $Root/CenterPanel/Plots
@onready var tick_button: Button = $Root/BottomBar/TickButton
@onready var harvest_button: Button = $Root/BottomBar/HarvestButton
@onready var unlock_button: Button = $Root/BottomBar/UnlockButton
@onready var menu_button: Button = $Root/TopBar/MenuButton
@onready var fragments_label: Label = $Root/TopBar/FragmentsLabel
@onready var tick_label: Label = $Root/TopBar/TickLabel
@onready var log_label: Label = $Root/LogPanel/LogLabel
@onready var seed_picker: OptionButton = $Root/BottomBar/SeedPicker

func _ready() -> void:
	tick_button.pressed.connect(_on_tick)
	harvest_button.pressed.connect(_on_harvest)
	unlock_button.pressed.connect(_on_unlock)
	menu_button.pressed.connect(_on_menu)
	seed_picker.item_selected.connect(_on_seed_selected)

	_build_dials()
	_build_plots()
	_refresh_seed_picker()

	SignalBus.model_changed.connect(_refresh)
	SignalBus.log_added.connect(_on_log)
	_refresh()

func _build_dials() -> void:
	var dial_scene := preload("res://components/AntennaDial.tscn")
	for axis in ["frequency", "amplitude", "phase"]:
		var dial = dial_scene.instantiate()
		dial.axis = axis
		dial.label_text = axis.to_upper()
		dials_box.add_child(dial)
		dial.value_changed.connect(_on_dial_changed)

func _build_plots() -> void:
	for i in GameState.PLOT_COUNT:
		var b := Button.new()
		b.custom_minimum_size = Vector2(120, 120)
		b.text = "Empty"
		b.pressed.connect(_on_plot_pressed.bind(i))
		plots_grid.add_child(b)

func _refresh_seed_picker() -> void:
	seed_picker.clear()
	for i in GameState.unlocked_plants.size():
		var pid: String = GameState.unlocked_plants[i]
		seed_picker.add_item(PLANT_DEFS.display_name(pid), i)
		seed_picker.set_item_metadata(i, pid)

func _refresh() -> void:
	fragments_label.text = "Fragments: %d" % GameState.fragments
	tick_label.text = "Tick: %d" % GameState.tick

	for i in plots_grid.get_child_count():
		if i >= GameState.plots.size():
			break
		var plot: Dictionary = GameState.plots[i]
		var btn: Button = plots_grid.get_child(i)
		if plot["plant_id"] == "":
			btn.text = "Empty"
		else:
			var stage: int = int(plot["stage"])
			var pname: String = PLANT_DEFS.display_name(plot["plant_id"])
			var state: String = STAGE_LABELS[stage]
			btn.text = "%s\n(%s)" % [pname, state]

	if signal_panel and signal_panel.has_method("refresh"):
		signal_panel.refresh()

	if log_label and GameState.log_history.size() > 0:
		log_label.text = GameState.log_history[0]

func _on_dial_changed(axis: String, value: int) -> void:
	AudioManager.play_sfx("tick")
	var current: int = int(GameState.antenna.get(axis, 0))
	var delta: int = value - current
	if delta != 0:
		GameState.adjust_antenna(axis, delta)

func _on_plot_pressed(index: int) -> void:
	var plot: Dictionary = GameState.plots[index]
	if plot["plant_id"] != "" and int(plot["stage"]) >= 2:
		GameState.harvest(index)
		AudioManager.play_sfx("harvest")
		return
	if plot["plant_id"] != "":
		GameState.add_log("Still growing...")
		return
	var idx := seed_picker.get_selected_id()
	if idx < 0:
		return
	var pid: String = seed_picker.get_item_metadata(idx)
	if GameState.plant(index, pid):
		AudioManager.play_sfx("plant")
		GameState.add_log("Planted %s." % PLANT_DEFS.display_name(pid))

func _on_seed_selected(_i: int) -> void:
	pass

func _on_tick() -> void:
	GameState.advance_tick()

func _on_harvest() -> void:
	for i in GameState.plots.size():
		if GameState.plots[i]["plant_id"] != "" and int(GameState.plots[i]["stage"]) >= 2:
			GameState.harvest(i)
			AudioManager.play_sfx("harvest")
			return
	GameState.add_log("Nothing ready to harvest.")

func _on_unlock() -> void:
	if GameState.try_unlock_with_fragments():
		_refresh_seed_picker()
	else:
		GameState.add_log("Need 5 fragments to unlock a new seed.")

func _on_log(msg: String) -> void:
	log_label.text = msg

func _on_menu() -> void:
	SaveManager.save_now()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
