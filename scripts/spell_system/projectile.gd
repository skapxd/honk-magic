class_name Projectile
extends Area2D

# =============================================================================
# HONK MAGIC - Projectile Base
# =============================================================================
# Proyectil magico que viaja y colisiona con entidades.

signal hit_target(target: Node2D)

@export var speed: float = 400.0
@export var damage: float = 10.0
@export var life_time: float = 5.0
@export var knockback_force: float = 0.0
@export var element: String = ""

var direction: Vector2 = Vector2.RIGHT
var caster: Node2D = null
var effect: StatusEffect = null
var _spawn_time: float = 0.0
const COLLISION_DELAY := 0.05


func _ready() -> void:
	add_to_group("spell")
	_spawn_time = Time.get_ticks_msec() / 1000.0
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Auto-destruir despues de life_time
	var timer := get_tree().create_timer(life_time)
	timer.timeout.connect(queue_free)


func _can_collide() -> bool:
	var current_time := Time.get_ticks_msec() / 1000.0
	return (current_time - _spawn_time) > COLLISION_DELAY


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func setup(p_caster: Node2D, p_direction: Vector2, p_speed: float = 400.0, p_damage: float = 10.0) -> void:
	caster = p_caster
	direction = p_direction.normalized()
	speed = p_speed
	damage = p_damage
	rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if not _can_collide():
		return
	_handle_collision(body)


func _on_area_entered(area: Area2D) -> void:
	if not _can_collide():
		return

	# No colisionar consigo mismo
	if area == self:
		return

	# Colision con otro proyectil/hechizo - ambos se destruyen
	if area.is_in_group("spell"):
		_spawn_impact_particles()
		queue_free()
		return

	# Para colisionar con otras areas (como enemigos que usan Area2D)
	var parent := area.get_parent()
	if parent and parent != caster and parent != self:
		_handle_collision(parent)


func _handle_collision(target: Node2D) -> void:
	if target == caster:
		return

	# Si es un StaticBody2D (como muro), solo destruir el proyectil
	if target is StaticBody2D:
		on_impact(target)
		return

	# Aplicar dano
	if target.has_node("HealthComponent"):
		target.get_node("HealthComponent").take_damage(damage)
	elif "hp" in target:
		target.hp -= int(damage)

	# Aplicar efecto de estado
	if effect and target.has_node("StatusManager"):
		target.get_node("StatusManager").apply_effect(effect, target)

	# Aplicar knockback
	if knockback_force > 0:
		if target.has_method("take_knockback"):
			target.take_knockback(direction * knockback_force)
		elif target is CharacterBody2D:
			target.velocity = direction * knockback_force

	hit_target.emit(target)
	on_impact(target)


func on_impact(_target: Node2D) -> void:
	# Crear particulas de impacto
	_spawn_impact_particles()
	queue_free()


func _spawn_impact_particles() -> void:
	# Particulas simples al impactar
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 8
	particles.lifetime = 0.3
	particles.direction = -direction
	particles.spread = 45.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = modulate

	get_tree().root.add_child(particles)
	particles.global_position = global_position

	# Auto-destruir particulas
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(particles.queue_free)
