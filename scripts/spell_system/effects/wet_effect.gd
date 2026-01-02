class_name WetEffect
extends StatusEffect

# =============================================================================
# HONK MAGIC - Wet Effect (Agua)
# =============================================================================
# Ralentiza al objetivo mientras esta mojado.

@export var speed_multiplier: float = 0.5


func _init(p_duration: float = 3.0, p_multiplier: float = 0.5):
	super(p_duration)
	effect_name = "Mojado"
	speed_multiplier = p_multiplier
	effect_color = Color("#0077b6")  # Azul agua


func on_apply(target: Node2D) -> void:
	if target.has_method("apply_speed_modifier"):
		target.apply_speed_modifier(speed_multiplier)
	elif "speed" in target:
		target.set_meta("original_speed", target.speed)
		target.speed *= speed_multiplier


func on_remove(target: Node2D) -> void:
	if target.has_method("remove_speed_modifier"):
		target.remove_speed_modifier(speed_multiplier)
	elif "speed" in target and target.has_meta("original_speed"):
		target.speed = target.get_meta("original_speed")
		target.remove_meta("original_speed")
