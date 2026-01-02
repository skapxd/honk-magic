extends Node

# =============================================================================
# HONK MAGIC - Save Manager (Autoload)
# Sistema de guardado con 3 slots
# =============================================================================

signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)

const SAVE_DIR := "user://saves/"
const SAVE_VERSION := 1
const MAX_SLOTS := 3

# Datos de partida actual en memoria
var current_slot: int = -1
var current_data: SaveData = null


# =============================================================================
# SaveData Class
# =============================================================================

class SaveData:
	# Player data
	var player_name: String = ""
	var hp_actual: int = 100
	var mp_actual: int = 100
	var position: Vector2 = Vector2.ZERO
	var current_map: String = "forest_01"

	# Monsters
	var reserve: Array = []  # Array of MonstruoData
	var active: Array = []   # Array of MonstruoActivo (max 24)

	# Metadata
	var play_time: float = 0.0
	var save_date: String = ""
	var save_version: int = SAVE_VERSION

	func to_dict() -> Dictionary:
		return {
			"player_name": player_name,
			"hp_actual": hp_actual,
			"mp_actual": mp_actual,
			"position": {"x": position.x, "y": position.y},
			"current_map": current_map,
			"reserve": reserve,
			"active": active,
			"play_time": play_time,
			"save_date": save_date,
			"save_version": save_version
		}

	static func from_dict(data: Dictionary) -> SaveData:
		var save := SaveData.new()
		save.player_name = data.get("player_name", "")
		save.hp_actual = data.get("hp_actual", 100)
		save.mp_actual = data.get("mp_actual", 100)
		var pos: Dictionary = data.get("position", {"x": 0, "y": 0})
		save.position = Vector2(pos.get("x", 0), pos.get("y", 0))
		save.current_map = data.get("current_map", "forest_01")
		save.reserve = data.get("reserve", [])
		save.active = data.get("active", [])
		save.play_time = data.get("play_time", 0.0)
		save.save_date = data.get("save_date", "")
		save.save_version = data.get("save_version", 1)
		return save


# =============================================================================
# Lifecycle
# =============================================================================

func _ready() -> void:
	_ensure_save_directory()


func _ensure_save_directory() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")


# =============================================================================
# Slot Management
# =============================================================================

func get_slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(get_slot_path(slot))


func get_slot_info(slot: int) -> Dictionary:
	"""Returns basic info for slot preview (name, play time, date)"""
	if not slot_exists(slot):
		return {}

	var data := load_slot_data(slot)
	if data == null:
		return {}

	return {
		"player_name": data.player_name,
		"play_time": data.play_time,
		"save_date": data.save_date,
		"current_map": data.current_map
	}


func get_all_slots_info() -> Array:
	"""Returns info for all 3 slots"""
	var slots: Array = []
	for i in range(MAX_SLOTS):
		slots.append(get_slot_info(i))
	return slots


# =============================================================================
# Save / Load
# =============================================================================

func create_new_game(slot: int, player_name: String) -> bool:
	"""Creates a new save in the specified slot"""
	var data := SaveData.new()
	data.player_name = player_name
	data.save_date = Time.get_datetime_string_from_system()

	current_slot = slot
	current_data = data

	return save_game()


func save_game() -> bool:
	"""Saves current game data to current slot"""
	if current_slot < 0 or current_data == null:
		push_error("SaveManager: No active game to save")
		return false

	current_data.save_date = Time.get_datetime_string_from_system()

	var file := FileAccess.open(get_slot_path(current_slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Could not open save file for writing")
		save_completed.emit(current_slot, false)
		return false

	var json_string := JSON.stringify(current_data.to_dict(), "\t")
	file.store_string(json_string)
	file.close()

	save_completed.emit(current_slot, true)
	return true


func load_game(slot: int) -> bool:
	"""Loads game from specified slot"""
	var data := load_slot_data(slot)
	if data == null:
		load_completed.emit(slot, false)
		return false

	current_slot = slot
	current_data = data

	load_completed.emit(slot, true)
	return true


func load_slot_data(slot: int) -> SaveData:
	"""Loads and returns SaveData from slot without setting as current"""
	if not slot_exists(slot):
		return null

	var file := FileAccess.open(get_slot_path(slot), FileAccess.READ)
	if file == null:
		push_error("SaveManager: Could not open save file for reading")
		return null

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("SaveManager: JSON parse error: " + json.get_error_message())
		return null

	return SaveData.from_dict(json.data)


func delete_slot(slot: int) -> bool:
	"""Deletes save data in specified slot"""
	if not slot_exists(slot):
		return true

	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return false

	var error := dir.remove("slot_%d.json" % slot)

	if current_slot == slot:
		current_slot = -1
		current_data = null

	return error == OK


# =============================================================================
# Play Time Tracking
# =============================================================================

func add_play_time(delta: float) -> void:
	"""Call from gameplay to track play time"""
	if current_data:
		current_data.play_time += delta


func get_formatted_play_time(seconds: float) -> String:
	"""Returns formatted play time string (HH:MM:SS)"""
	var hours := int(seconds / 3600)
	var minutes := int(fmod(seconds, 3600) / 60)
	var secs := int(fmod(seconds, 60))
	return "%02d:%02d:%02d" % [hours, minutes, secs]
