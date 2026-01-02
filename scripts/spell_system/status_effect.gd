class_name StatusEffect
extends Resource

# =============================================================================
# HONK MAGIC - Status Effect Base
# =============================================================================
# Clase base para efectos de estado (quemadura, mojado, etc.)

@export var effect_name: String = "Effect"
@export var duration: float = 0.0
@export var effect_color: Color = Color.WHITE

var time_remaining: float = 0.0
var is_finished: bool = false


func _init(p_duration: float = 0.0):
	duration = p_duration
	time_remaining = p_duration


func on_apply(target: Node2D) -> void:
	pass


func on_tick(target: Node2D, delta: float) -> void:
	pass


func on_remove(target: Node2D) -> void:
	pass
