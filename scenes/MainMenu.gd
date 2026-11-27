extends Control

@onready var play_button: Button = $VBox/PlayButton
@onready var journal_button: Button = $VBox/JournalButton
@onready var settings_button: Button = $VBox/SettingsButton
@onready var quit_button: Button = $VBox/QuitButton

func _ready() -> void:
	if SaveManager.save_exists():
		SaveManager.load_game()
	play_button.pressed.connect(_on_play)
	journal_button.pressed.connect(_on_journal)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)

func _on_play() -> void:
	if SaveManager.save_exists():
		SaveManager.load_game()
	else:
		GameState.new_game()
	SceneRouter.go_to(SceneRouter.GARDEN)

func _on_journal() -> void:
	SceneRouter.go_to(SceneRouter.JOURNAL)

func _on_settings() -> void:
	SceneRouter.go_to(SceneRouter.SETTINGS)

func _on_quit() -> void:
	SceneRouter.quit_saved()
