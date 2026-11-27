extends Node

const MENU := "res://scenes/MainMenu.tscn"
const GARDEN := "res://scenes/Garden.tscn"
const JOURNAL := "res://scenes/Journal.tscn"
const SETTINGS := "res://scenes/Settings.tscn"
var navigating := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().set_quit_on_go_back(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_inside_tree():
		handle_back()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		handle_back()
		get_viewport().set_input_as_handled()

func back_action(scene_path: String) -> String:
	match scene_path:
		GARDEN: return "pause"
		JOURNAL, SETTINGS: return "menu"
		MENU: return "quit"
	return ""

func handle_back(scene: Node = null) -> void:
	if navigating:
		return
	if scene == null:
		scene = get_tree().current_scene
	if not is_instance_valid(scene):
		return
	match back_action(scene.scene_file_path):
		"pause":
			scene.toggle_pause()
		"menu":
			go_to(MENU, true)
		"quit":
			quit_saved()

func go_to(path: String, save_first: bool = false) -> void:
	if navigating:
		return
	navigating = true
	if save_first:
		SaveManager.save_now()
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Scene navigation failed: %s" % path)
	navigating = false

func quit_saved() -> void:
	if navigating:
		return
	navigating = true
	SaveManager.save_now()
	get_tree().paused = false
	get_tree().quit()
