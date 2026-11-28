extends Control

@onready var play_button: Button = $VBox/PlayButton
@onready var journal_button: Button = $VBox/JournalButton
@onready var settings_button: Button = $VBox/SettingsButton
@onready var quit_button: Button = $VBox/QuitButton

func _ready() -> void:
	if not SaveManager.recovery_status.is_empty():
		$VBox/Tagline.text = SaveManager.recovery_status
		$VBox/Tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	play_button.disabled = SaveManager.writes_blocked
	play_button.pressed.connect(_on_play)
	journal_button.pressed.connect(_on_journal)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)

func _on_play() -> void:
	if not SaveManager.writes_blocked:
		SceneRouter.go_to(SceneRouter.GARDEN)

func _on_journal() -> void:
	SceneRouter.go_to(SceneRouter.JOURNAL)

func _on_settings() -> void:
	SceneRouter.go_to(SceneRouter.SETTINGS)

func _on_quit() -> void:
	SceneRouter.quit_saved()
