extends Control

@onready var master: HSlider = $Root/VBox/MasterSlider
@onready var sfx: HSlider = $Root/VBox/SfxSlider
@onready var reset_btn: Button = $Root/VBox/ResetButton
@onready var back_btn: Button = $Root/VBox/BackButton

func _ready() -> void:
	master.value = AudioManager.master_volume
	sfx.value = AudioManager.sfx_volume
	master.value_changed.connect(func(v): AudioManager.set_master_volume(v))
	sfx.value_changed.connect(func(v): AudioManager.set_sfx_volume(v))
	reset_btn.pressed.connect(_on_reset)
	back_btn.pressed.connect(_on_back)

func _on_reset() -> void:
	SaveManager.reset_game()
	AudioManager.play_sfx("tick")

func _on_back() -> void:
	SaveManager.save_now()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
