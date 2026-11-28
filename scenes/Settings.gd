extends Control

@onready var master: HSlider = $Root/VBox/MasterSlider
@onready var music: HSlider = $Root/VBox/MusicSlider
@onready var sfx: HSlider = $Root/VBox/SfxSlider
@onready var reset_btn: Button = $Root/VBox/ResetButton
@onready var back_btn: Button = $Root/VBox/BackButton

func _ready() -> void:
	master.value = AudioManager.master_volume
	music.value = AudioManager.music_volume
	sfx.value = AudioManager.sfx_volume
	master.value_changed.connect(func(v): AudioManager.set_master_volume(v))
	music.value_changed.connect(func(v): AudioManager.set_music_volume(v))
	sfx.value_changed.connect(func(v): AudioManager.set_sfx_volume(v))
	reset_btn.pressed.connect(_on_reset)
	back_btn.pressed.connect(_on_back)

func _on_reset() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Reset garden?"
	dialog.dialog_text = "This permanently deletes your garden, hybrids and backup saves."
	dialog.ok_button_text = "Reset garden"
	add_child(dialog)
	dialog.confirmed.connect(func():
		SaveManager.reset_game()
		AudioManager.play_sfx("tick")
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(360, 180))

func _on_back() -> void:
	SceneRouter.go_to(SceneRouter.MENU, true)
