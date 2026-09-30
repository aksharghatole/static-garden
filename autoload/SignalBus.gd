extends Node

signal model_changed
signal tick_advanced(new_tick: int)
signal plant_planted(plot_index: int, plant_id: String)
signal plant_harvested(plot_index: int, plant_id: String, fragments: int)
signal fragments_changed(amount: int)
signal antenna_changed(axis: String, value: int)
signal log_added(message: String)
signal game_loaded
signal game_reset
