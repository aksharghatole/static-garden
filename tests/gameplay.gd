extends Node

var failures: int = 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func prepare(seed_value: int, matched: bool) -> void:
	GameState.new_game()
	GameState.rng_seed = 0
	GameState.rng.seed = seed_value
	GameState.antenna = {"frequency": 0, "amplitude": 0, "phase": 0} if matched else {"frequency": 3, "amplitude": 3, "phase": 3}
	check(GameState.plant(0, "moss"), "Planting moss should succeed")

func _ready() -> void:
	# Find a deterministic RNG draw that distinguishes 35% from 85% growth.
	var probe := RandomNumberGenerator.new()
	var seed_value: int = -1
	for candidate in range(1000):
		probe.seed = candidate
		var roll := probe.randf()
		if roll > 0.35 and roll < 0.85:
			seed_value = candidate
			break
	check(seed_value >= 0, "Expected a suitable RNG draw")
	if seed_value >= 0:
		prepare(seed_value, true)
		check(is_equal_approx(GameState.signal_match_strength(), 1.0), "Matched antenna")
		GameState.advance_tick()
		check(GameState.plots[0]["ticks"] == 1, "Matched signal should grow on displayed tick")
		check(GameState.tick == 1, "Tick should advance once")
		prepare(seed_value, false)
		check(is_zero_approx(GameState.signal_match_strength()), "Mismatched antenna")
		GameState.advance_tick()
		check(GameState.plots[0]["ticks"] == 0, "Mismatched signal should not grow on this draw")

	prepare(123456, true)
	GameState.advance_tick()
	var snapshot = JSON.parse_string(JSON.stringify(GameState.to_dict()))
	var expected_state := GameState.rng.state
	var expected_draw := GameState.rng.randf()
	GameState.from_dict(snapshot)
	check(GameState.rng.state == expected_state, "64-bit RNG state must survive JSON round-trip")
	check(is_equal_approx(GameState.rng.randf(), expected_draw), "Next random draw must survive save/load")
	snapshot.erase("rng_state")
	GameState.from_dict(snapshot)
	check(GameState.tick == 1, "Legacy saves must remain readable")
	GameState.new_game()
	var garden = preload("res://scenes/Garden.tscn").instantiate()
	add_child(garden)
	var grid = garden.get_node("Root/CenterPanel/Plots")
	check(grid.get_child_count() == 6, "Garden should contain six plot views")
	var plot = grid.get_child(0)
	check(plot.plant_id == "", "Empty plot should be visible")
	plot.pressed.emit()
	check(GameState.plots[0]["plant_id"] == "moss", "Plot tap should plant selected seed")
	check(plot.plant_id == "moss" and plot.stage == 0, "View should display seed")
	GameState.plots[0]["stage"] = 1
	SignalBus.model_changed.emit()
	check(plot.stage == 1 and plot.stage_label.text == "Sprout", "View should display sprout")
	GameState.plots[0]["stage"] = 2
	SignalBus.model_changed.emit()
	check(plot.stage == 2 and plot.stage_label.text == "Ready", "View should display mature plant")
	plot.pressed.emit()
	check(plot.plant_id == "" and GameState.fragments == 1, "Mature plot tap should harvest")
	check(SceneRouter.back_action(SceneRouter.MENU) == "quit", "Main menu back saves and quits")
	check(SceneRouter.back_action(SceneRouter.JOURNAL) == "menu", "Journal back returns to menu")
	check(SceneRouter.back_action(SceneRouter.SETTINGS) == "menu", "Settings back returns to menu")
	for attempt in range(3):
		SceneRouter.handle_back(garden)
		check(garden.pause_overlay.visible and get_tree().paused, "Back opens and pauses garden")
		SceneRouter.handle_back(garden)
		check(not garden.pause_overlay.visible and not get_tree().paused, "Second back resumes garden")
	garden.menu_button.pressed.emit()
	check(garden.pause_overlay.visible, "Menu button opens pause overlay")
	garden.pause_overlay.resume_button.pressed.emit()
	check(not get_tree().paused, "Resume button unpauses")
	garden.queue_free()
	_test_hybrids()
	if failures == 0:
		print("Gameplay regression tests passed")
	get_tree().quit(0 if failures == 0 else 1)

func _test_hybrids() -> void:
	var defs := preload("res://data/plants.gd")
	check(defs.HYBRID_IDS.size() == 6, "Six unique hybrids")
	check(defs.hybrid_of("moss", "fern") == "mist", "Parent order independent")
	check(defs.hybrid_of("fern", "moss") == "mist", "Reverse parent order")
	check(defs.hybrid_of("fern", "fern") == "", "Same species cannot hybridize")
	check(not GameState.adjacent_plots(2).has(3), "No row wrapping")
	var probe := RandomNumberGenerator.new()
	var winning_seed := -1
	for candidate in range(1000):
		probe.seed = candidate
		if probe.randf() < GameState.HYBRID_CHANCE:
			winning_seed = candidate
			break
	check(winning_seed >= 0, "Find deterministic hybrid roll")
	if winning_seed < 0:
		return
	GameState.new_game()
	GameState.plots[0] = {"plant_id": "moss", "stage": 2, "ticks": 0}
	GameState.plots[4] = {"plant_id": "fern", "stage": 2, "ticks": 0}
	GameState.rng.seed = winning_seed
	check(GameState.try_hybrid(0) == "", "Diagonal neighbors do not qualify")
	GameState.plots[1] = {"plant_id": "fern", "stage": 1, "ticks": 0}
	check(GameState.try_hybrid(0) == "", "Immature neighbor does not qualify")
	GameState.plots[1]["stage"] = 2
	GameState.rng.seed = winning_seed
	GameState.harvest(0)
	check(GameState.unlocked_hybrids.has("mist"), "Harvest discovers hybrid")
	check(GameState.unlocked_plants.has("mist"), "Hybrid is plantable")
	check(GameState.fragments == 1, "Harvest retains base reward")
	check(GameState.plant(0, "mist"), "Discovered seed can be planted")
	GameState.plots[0]["stage"] = 2
	GameState.harvest(0)
	check(GameState.fragments == 6, "Hybrid reward applied")
	var saved = JSON.parse_string(JSON.stringify(GameState.to_dict()))
	GameState.new_game()
	GameState.from_dict(saved)
	check(GameState.unlocked_hybrids.has("mist"), "Hybrid survives save round trip")
	var journal = preload("res://scenes/Journal.tscn").instantiate()
	add_child(journal)
	var found := false
	for child in journal.get_node("Root/Scroll/List").get_children():
		if child is Label and child.text.begins_with("Mist"):
			found = true
	check(found, "Journal shows discovered hybrid")
	journal.queue_free()
