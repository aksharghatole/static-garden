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
	if failures == 0:
		print("Gameplay regression tests passed")
	get_tree().quit(0 if failures == 0 else 1)
