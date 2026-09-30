extends Control

@onready var play_button: Button = $VBox/PlayButton
@onready var journal_button: Button = $VBox/JournalButton
@onready var settings_button: Button = $VBox/SettingsButton
@onready var quit_button: Button = $VBox/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play)
	journal_button.pressed.connect(_on_journal)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)

func _on_play() -> void:
	if SaveManager.save_exists():
		SaveManager.load_game()
	else:
		GameState.new_game()
	get_tree().change_scene_to_file("res://scenes/Garden.tscn")

func _on_journal() -> void:
	get_tree().change_scene_to_file("res://scenes/Journal.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_quit() -> void:
	SaveManager.save_now()
	get_tree().quit()
