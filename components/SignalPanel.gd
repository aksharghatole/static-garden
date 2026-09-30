extends Control

@onready var target_label: Label = $VBox/Target
@onready var match_label: Label = $VBox/Match

func refresh() -> void:
	var t: Dictionary = GameState.current_signal()
	var strength := int(round(GameState.signal_match_strength() * 100.0))
	target_label.text = "Target  F:%d A:%d P:%d" % [t["frequency"], t["amplitude"], t["phase"]]
	match_label.text = "Match: %d%%" % strength
