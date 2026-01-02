extends Node

# =============================================================================
# HONK MAGIC - Game Manager (Autoload)
# Estado global del juego
# =============================================================================

signal scene_changed(scene_name: String)
signal game_paused(is_paused: bool)

enum GameState {
	TITLE,
	MENU,
	GAMEPLAY,
	PAUSED
}

var current_state: GameState = GameState.TITLE
var _is_transitioning: bool = false

const CONFIG_PATH := "user://settings.cfg"
var _config := ConfigFile.new()

# -----------------------------------------------------------------------------
# Lifecycle
# -----------------------------------------------------------------------------

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()
	_apply_settings()


func _load_settings() -> void:
	var err := _config.load(CONFIG_PATH)
	if err != OK:
		# Create defaults
		_config.set_value("audio", "master_volume", 1.0)
		_config.set_value("video", "fullscreen", not OS.has_feature("editor"))
		_config.set_value("game", "locale", OS.get_locale_language())
		_config.save(CONFIG_PATH)


func _apply_settings() -> void:
	# Apply language
	var locale: String = _config.get_value("game", "locale", OS.get_locale_language())
	TranslationServer.set_locale(locale)

	# Apply fullscreen (only in export, not in editor)
	if not OS.has_feature("editor"):
		var fullscreen: bool = _config.get_value("video", "fullscreen", true)
		if fullscreen:
			if OS.has_feature("web"):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# -----------------------------------------------------------------------------
# Scene Management
# -----------------------------------------------------------------------------

func change_scene(scene_path: String) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true

	# TODO: Agregar transición visual (fade)
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to change scene to: " + scene_path)

	_is_transitioning = false
	scene_changed.emit(scene_path)


func go_to_title() -> void:
	current_state = GameState.TITLE
	change_scene("res://scenes/ui/title_screen.tscn")


func go_to_menu() -> void:
	current_state = GameState.MENU
	change_scene("res://scenes/ui/main_menu.tscn")


func go_to_gameplay() -> void:
	current_state = GameState.GAMEPLAY
	change_scene("res://scenes/gameplay/main_world.tscn")


func quit_game() -> void:
	get_tree().quit()


# -----------------------------------------------------------------------------
# Pause Management
# -----------------------------------------------------------------------------

func pause_game() -> void:
	if current_state != GameState.GAMEPLAY:
		return

	current_state = GameState.PAUSED
	get_tree().paused = true
	game_paused.emit(true)


func resume_game() -> void:
	if current_state != GameState.PAUSED:
		return

	current_state = GameState.GAMEPLAY
	get_tree().paused = false
	game_paused.emit(false)


func toggle_pause() -> void:
	if current_state == GameState.PAUSED:
		resume_game()
	elif current_state == GameState.GAMEPLAY:
		pause_game()
