extends Control

signal value_changed(axis: String, value: int)

@export var axis: String = "frequency"
@export var label_text: String = "FREQ"
@export var max_value: int = 3

var value: int = 0

@onready var label: Label = $VBox/Label
@onready var value_label: Label = $VBox/ValueLabel
@onready var bar: ProgressBar = $VBox/Bar

func _ready() -> void:
	label.text = label_text
	_refresh()

func set_value(v: int) -> void:
	value = clamp(v, 0, max_value)
	_refresh()

func _refresh() -> void:
	if bar:
		bar.max_value = max_value
		bar.value = value
	if value_label:
		value_label.text = str(value)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_handle_tap(event.position.x)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_tap(event.position.x)

func _handle_tap(x: float) -> void:
	var mid := size.x * 0.5
	if x < mid:
		value = max(0, value - 1)
	else:
		value = min(max_value, value + 1)
	_refresh()
	value_changed.emit(axis, value)
