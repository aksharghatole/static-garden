extends Node

const SAVE_PATH := "user://save.json"
const TMP_PATH := "user://save.tmp"
const BAK_PATH := "user://save.bak.json"
const BAK_TMP_PATH := "user://save.bak.tmp"
const SCHEMA := preload("res://data/SaveSchema.gd")

var _save_timer: Timer
var _pending_save := false
var _loading := false
var writes_blocked := false
var recovery_status := ""

func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 1.0
	_save_timer.timeout.connect(_flush_save)
	add_child(_save_timer)
	SignalBus.model_changed.connect(_queue_save)
	if save_exists():
		load_game()

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(TMP_PATH) or FileAccess.file_exists(BAK_PATH)

func _read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	# Avoid excessive allocations if a file is damaged.
	if file.get_length() > 1048576:
		file.close()
		return null
	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	file.close()
	return json.data if result == OK else null

func load_game() -> bool:
	recovery_status = ""
	if not save_exists():
		writes_blocked = false
		return false
	for path in [SAVE_PATH, TMP_PATH, BAK_PATH]:
		var candidate = _read(path)
		if SCHEMA.future_version(candidate):
			writes_blocked = true
			recovery_status = "Save requires a newer version. Progress protected."
			return false
		if not SCHEMA.valid(candidate):
			continue
		_loading = true
		GameState.from_dict(candidate)
		_loading = false
		writes_blocked = false
		_pending_save = false
		_save_timer.stop()
		if path != SAVE_PATH:
			recovery_status = "Garden recovered from an earlier save."
			# Re-promote a valid temporary file without truncating the only copy.
			if path == TMP_PATH:
				if _replace(TMP_PATH, SAVE_PATH) != OK:
					writes_blocked = true
					recovery_status = "Temporary save recovered but could not be restored. Restart to retry."
			elif not save_now():
				writes_blocked = true
				recovery_status = "Backup recovered but could not be restored. Restart to retry."
		return true
	writes_blocked = true
	recovery_status = "Save could not be recovered. Existing files protected."
	return false

func _write(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	var ok := file.get_error() == OK
	file.close()
	return ok

func _replace(source: String, destination: String) -> Error:
	# Same-directory rename replaces the file without a delete-first gap.
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(destination))

func save_now() -> bool:
	if writes_blocked or _loading:
		return false
	var data := GameState.to_dict()
	if not SCHEMA.valid(data):
		push_warning("Refusing to save invalid garden data")
		return false
	var previous = _read(SAVE_PATH)
	# Only rotate a validated primary; never overwrite a healthy backup with corruption.
	if SCHEMA.valid(previous):
		if not _write(BAK_TMP_PATH, JSON.stringify(previous, "  ")) or _replace(BAK_TMP_PATH, BAK_PATH) != OK:
			push_warning("Could not rotate garden backup")
			return false
	if not _write(TMP_PATH, JSON.stringify(data, "  ")) or not SCHEMA.valid(_read(TMP_PATH)):
		push_warning("Could not write valid temporary garden save")
		return false
	if _replace(TMP_PATH, SAVE_PATH) != OK:
		push_warning("Could not replace garden save")
		return false
	_pending_save = false
	_save_timer.stop()
	return true

func reset_game() -> void:
	for path in [SAVE_PATH, BAK_PATH, TMP_PATH, BAK_TMP_PATH]:
		if FileAccess.file_exists(path):
			if DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) != OK:
				writes_blocked = true
				recovery_status = "Reset could not remove old save files."
				return
	writes_blocked = false
	recovery_status = ""
	GameState.new_game()
	save_now()

func _queue_save() -> void:
	if _loading or writes_blocked:
		return
	_pending_save = true
	_save_timer.start()

func _flush_save() -> void:
	if _pending_save and not save_now() and not writes_blocked:
		_save_timer.start()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_now()
