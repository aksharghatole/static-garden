extends Node

const SAVE_PATH := "user://save.json"
const TMP_PATH := "user://save.tmp"
const BAK_PATH := "user://save.bak.json"

var _save_timer: Timer
var _pending_save := false

func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 1.0
	_save_timer.timeout.connect(_flush_save)
	add_child(_save_timer)
	SignalBus.model_changed.connect(_queue_save)

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> bool:
	if not save_exists():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	if int(parsed.get("version", 0)) > 1:
		return false
	GameState.from_dict(parsed)
	return true

func save_now() -> void:
	var data := GameState.to_dict()
	var text := JSON.stringify(data, "  ")

	if FileAccess.file_exists(SAVE_PATH):
		var src := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if src:
			var bak := FileAccess.open(BAK_PATH, FileAccess.WRITE)
			if bak:
				bak.store_string(src.get_as_text())
				bak.close()
			src.close()

	var tmp := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if tmp == null:
		return
	tmp.store_string(text)
	tmp.close()

	var dir := DirAccess.open("user://")
	if dir:
		if dir.file_exists("save.json"):
			dir.remove("save.json")
		dir.rename("save.tmp", "save.json")

func reset_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if FileAccess.file_exists(BAK_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BAK_PATH))
	GameState.new_game()

func _queue_save() -> void:
	_pending_save = true
	if _save_timer:
		_save_timer.start()

func _flush_save() -> void:
	if _pending_save:
		_pending_save = false
		save_now()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_now()
