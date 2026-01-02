extends CanvasLayer

# =============================================================================
# HONK MAGIC - Scene Transition (Autoload)
# Maneja transiciones visuales entre escenas
# =============================================================================

signal transition_started
signal transition_midpoint
signal transition_finished

@export var transition_duration: float = 0.4

var _color_rect: ColorRect
var _is_transitioning: bool = false

func _ready() -> void:
	layer = 100  # Siempre encima de todo
	_create_overlay()


func _create_overlay() -> void:
	_color_rect = ColorRect.new()
	_color_rect.color = Color(0.059, 0.059, 0.102, 1.0)  # FONDO_PROFUNDO
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color_rect.modulate.a = 0.0
	add_child(_color_rect)


# -----------------------------------------------------------------------------
# Public API
# -----------------------------------------------------------------------------

## Cambia de escena con fade
func change_scene(scene_path: String) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	transition_started.emit()

	# Fade out
	var tween := create_tween()
	tween.tween_property(_color_rect, "modulate:a", 1.0, transition_duration)
	await tween.finished

	transition_midpoint.emit()

	# Cambiar escena
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("SceneTransition: Failed to change scene to: " + scene_path)
		_is_transitioning = false
		return

	# Esperar un frame para que la escena cargue
	await get_tree().process_frame

	# Fade in
	var tween_in := create_tween()
	tween_in.tween_property(_color_rect, "modulate:a", 0.0, transition_duration)
	await tween_in.finished

	_is_transitioning = false
	transition_finished.emit()


## Fade out sin cambiar escena (útil para efectos)
func fade_out(duration: float = -1.0) -> void:
	if duration < 0:
		duration = transition_duration

	var tween := create_tween()
	tween.tween_property(_color_rect, "modulate:a", 1.0, duration)
	await tween.finished


## Fade in sin cambiar escena
func fade_in(duration: float = -1.0) -> void:
	if duration < 0:
		duration = transition_duration

	var tween := create_tween()
	tween.tween_property(_color_rect, "modulate:a", 0.0, duration)
	await tween.finished


## Verifica si hay una transición en progreso
func is_transitioning() -> bool:
	return _is_transitioning
