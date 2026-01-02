class_name KnockbackEffect
extends StatusEffect

# =============================================================================
# HONK MAGIC - Knockback Effect (Viento)
# =============================================================================
# Empuja al objetivo en una direccion.

@export var knockback_force: float = 300.0

var knockback_direction: Vector2 = Vector2.ZERO


func _init(p_direction: Vector2 = Vector2.ZERO, p_force: float = 300.0):
	super(0.0)  # Efecto instantaneo
	effect_name = "Empuje"
	knockback_direction = p_direction
	knockback_force = p_force
	effect_color = Color("#90e0ef")  # Cyan viento


func on_apply(target: Node2D) -> void:
	if target.has_method("take_knockback"):
		target.take_knockback(knockback_direction * knockback_force)
	elif target is CharacterBody2D:
		target.velocity = knockback_direction * knockback_force
