extends Control

@onready var resume_button: Button = $Center/Panel/Content/Resume
@onready var menu_button: Button = $Center/Panel/Content/Menu
@onready var quit_button: Button = $Center/Panel/Content/Quit

func _ready() -> void:
	resume_button.pressed.connect(close_pause)
	menu_button.pressed.connect(_on_menu)
	quit_button.pressed.connect(_on_quit)
	hide()

func open_pause() -> void:
	if visible:
		return
	SaveManager.save_now()
	show()
	get_tree().paused = true
	resume_button.grab_focus()

func close_pause() -> void:
	if not visible:
		return
	resume_button.release_focus()
	hide()
	get_tree().paused = false

func toggle() -> void:
	if visible:
		close_pause()
	else:
		open_pause()

func _on_menu() -> void:
	SceneRouter.go_to(SceneRouter.MENU, true)

func _on_quit() -> void:
	SceneRouter.quit_saved()
