class_name BurnEffect
extends StatusEffect

# =============================================================================
# HONK MAGIC - Burn Effect (Fuego)
# =============================================================================
# Daño por segundo durante la duracion.

@export var damage_per_second: float = 5.0
@export var tick_rate: float = 1.0

var time_since_last_tick: float = 0.0


func _init(p_duration: float = 3.0, p_damage: float = 5.0):
	super(p_duration)
	effect_name = "Quemadura"
	damage_per_second = p_damage
	effect_color = Color("#e63946")  # Rojo fuego


func on_tick(target: Node2D, delta: float) -> void:
	time_since_last_tick += delta
	if time_since_last_tick >= tick_rate:
		time_since_last_tick -= tick_rate

		# Buscar componente de salud o propiedad hp
		if target.has_node("HealthComponent"):
			target.get_node("HealthComponent").take_damage(damage_per_second * tick_rate)
		elif "hp" in target:
			target.hp -= int(damage_per_second * tick_rate)
