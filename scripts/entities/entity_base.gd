class_name EntityBase
extends CharacterBody2D

# =============================================================================
# HONK MAGIC - Entity Base
# =============================================================================
# Clase base para todas las entidades del juego (player, enemigos, aliados).

signal hp_changed(current: int, max_hp: int)
signal died()
signal took_damage(amount: int, from: Node2D)

enum Team { PLAYER, ENEMY, NEUTRAL }
enum State { IDLE, CHASE, ATTACK, DEAD }

@export var max_hp: int = 100
@export var speed: float = 200.0
@export var team: Team = Team.NEUTRAL
@export var detection_range: float = 300.0
@export var attack_range: float = 50.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0

var hp: int = 100:
	set(value):
		var old_hp := hp
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0 and old_hp > 0:
			_on_death()

var current_state: State = State.IDLE
var target: Node2D = null
var _attack_timer: float = 0.0
var _is_dead: bool = false


func _ready() -> void:
	hp = max_hp
	_setup_entity()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_attack_timer -= delta
	_update_state(delta)
	_process_state(delta)


func _setup_entity() -> void:
	# Override en subclases para configuracion especifica
	pass


func _update_state(_delta: float) -> void:
	# Override en subclases para logica de estados
	pass


func _process_state(_delta: float) -> void:
	# Override en subclases para procesar estado actual
	pass


func take_damage(amount: float, from: Node2D = null) -> void:
	if _is_dead:
		return

	var damage := int(amount)
	hp -= damage
	took_damage.emit(damage, from)
	print("[%s] Recibio %d de dano. HP: %d/%d" % [name, damage, hp, max_hp])

	_on_take_damage(damage, from)


func _on_take_damage(_amount: int, _from: Node2D) -> void:
	# Override para efectos visuales de dano
	_flash_damage()


func _flash_damage() -> void:
	# Efecto de flash rojo al recibir dano
	var original_modulate := modulate
	modulate = Color.RED

	var tween := create_tween()
	tween.tween_property(self, "modulate", original_modulate, 0.15)


func _on_death() -> void:
	if _is_dead:
		return

	_is_dead = true
	current_state = State.DEAD
	print("[%s] Murio!" % name)

	died.emit()
	_spawn_death_particles()

	# Desvanecer y eliminar
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


func _spawn_death_particles() -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 16
	particles.lifetime = 0.5
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = Vector2(0, 100)
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 150.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0
	particles.color = modulate

	get_tree().root.add_child(particles)
	particles.global_position = global_position

	# Auto-destruir particulas
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)


func is_alive() -> bool:
	return not _is_dead


func get_hp_percent() -> float:
	return float(hp) / float(max_hp)


func can_attack() -> bool:
	return _attack_timer <= 0.0 and not _is_dead


func perform_attack() -> void:
	if not can_attack():
		return

	_attack_timer = attack_cooldown
	_do_attack()


func _do_attack() -> void:
	# Override en subclases para ataque especifico
	pass


func find_nearest_target(targets: Array[Node2D]) -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := INF

	for t in targets:
		if not is_instance_valid(t):
			continue
		var dist := global_position.distance_to(t.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = t

	return nearest


func move_toward_target(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var direction := (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()


func is_target_in_range(range_distance: float) -> bool:
	if not is_instance_valid(target):
		return false
	return global_position.distance_to(target.global_position) <= range_distance
