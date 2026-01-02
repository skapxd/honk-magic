class_name StatusManager
extends Node

# =============================================================================
# HONK MAGIC - Status Manager
# =============================================================================
# Maneja los efectos de estado activos en una entidad.

signal effect_applied(effect: StatusEffect)
signal effect_removed(effect: StatusEffect)

var active_effects: Array[StatusEffect] = []
var default_color: Color = Color.WHITE
var visual_node: CanvasItem


func _ready() -> void:
	var parent := get_parent()
	# Buscar nodo visual para aplicar color
	if parent.has_node("Visual"):
		visual_node = parent.get_node("Visual")
		default_color = visual_node.modulate
	elif parent.has_node("Sprite2D"):
		visual_node = parent.get_node("Sprite2D")
		default_color = visual_node.modulate


func apply_effect(effect: StatusEffect, target: Node2D) -> void:
	# Duplicar el efecto para tener una instancia unica
	var new_effect := effect.duplicate() as StatusEffect
	new_effect.time_remaining = new_effect.duration
	new_effect.on_apply(target)

	if new_effect.duration > 0:
		active_effects.append(new_effect)
		effect_applied.emit(new_effect)
		_update_visuals()
	else:
		# Efecto instantaneo
		new_effect.on_remove(target)


func has_effect_of_type(effect_type: String) -> bool:
	for effect in active_effects:
		if effect.effect_name == effect_type:
			return true
	return false


func remove_effects_of_type(effect_type: String, target: Node2D) -> void:
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].effect_name == effect_type:
			active_effects[i].on_remove(target)
			effect_removed.emit(active_effects[i])
			active_effects.remove_at(i)
	_update_visuals()


func clear_all_effects(target: Node2D) -> void:
	for effect in active_effects:
		effect.on_remove(target)
		effect_removed.emit(effect)
	active_effects.clear()
	_update_visuals()


func _update_visuals() -> void:
	if not visual_node:
		return

	if active_effects.is_empty():
		visual_node.modulate = default_color
		return

	# El ultimo efecto con color valido define el color visual
	var final_color := default_color
	for effect in active_effects:
		if effect.effect_color != Color.WHITE:
			final_color = effect.effect_color

	visual_node.modulate = final_color


func _process(delta: float) -> void:
	var target := get_parent() as Node2D
	if not target:
		return

	# Procesar efectos de atras hacia adelante para poder eliminar
	for i in range(active_effects.size() - 1, -1, -1):
		var effect := active_effects[i]
		effect.on_tick(target, delta)
		effect.time_remaining -= delta

		if effect.time_remaining <= 0:
			effect.on_remove(target)
			effect_removed.emit(effect)
			active_effects.remove_at(i)
			_update_visuals()
