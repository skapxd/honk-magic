class_name EnemyBase
extends EntityBase

# =============================================================================
# HONK MAGIC - Enemy Base
# =============================================================================
# Clase base para todos los enemigos con IA.

@export var idle_wander_range: float = 100.0
@export var idle_wait_time: float = 2.0
@export var chase_give_up_range: float = 500.0
@export var show_debug_ranges: bool = true  # Mostrar rangos en debug

var _idle_timer: float = 0.0
var _wander_target: Vector2 = Vector2.ZERO
var _spawn_position: Vector2 = Vector2.ZERO

@onready var visual: Node2D = $Visual


func _setup_entity() -> void:
	team = Team.ENEMY
	add_to_group("enemies")
	_spawn_position = global_position
	_wander_target = global_position
	queue_redraw()  # Para dibujar rangos de debug


func _draw() -> void:
	if not show_debug_ranges:
		return

	# Rango de detección (amarillo)
	draw_arc(Vector2.ZERO, detection_range, 0, TAU, 32, Color(1, 1, 0, 0.3), 2.0)

	# Rango de ataque (rojo)
	draw_arc(Vector2.ZERO, attack_range, 0, TAU, 24, Color(1, 0, 0, 0.5), 2.0)

	# Línea hacia el objetivo (verde)
	if is_instance_valid(target):
		var to_target: Vector2 = target.global_position - global_position
		draw_line(Vector2.ZERO, to_target, Color(0, 1, 0, 0.7), 2.0)


func _update_state(_delta: float) -> void:
	# Redibujar para actualizar línea al objetivo
	if show_debug_ranges:
		queue_redraw()

	match current_state:
		State.IDLE:
			_check_for_targets()
		State.CHASE:
			_validate_chase()
		State.ATTACK:
			_validate_attack()


func _process_state(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)


func _check_for_targets() -> void:
	# Buscar jugador o aliados en rango de deteccion
	var potential_targets: Array[Node2D] = []

	var players := get_tree().get_nodes_in_group("player")
	for p in players:
		if p is Node2D and is_instance_valid(p):
			potential_targets.append(p as Node2D)

	var allies := get_tree().get_nodes_in_group("allies")
	for a in allies:
		if a is Node2D and is_instance_valid(a):
			potential_targets.append(a as Node2D)

	target = find_nearest_target(potential_targets)

	if is_instance_valid(target) and is_target_in_range(detection_range):
		_change_state(State.CHASE)
		print("[%s] Detectado objetivo: %s" % [name, target.name])


func _validate_chase() -> void:
	if not is_instance_valid(target):
		_change_state(State.IDLE)
		return

	# Si el objetivo esta muy lejos, abandonar persecucion
	if not is_target_in_range(chase_give_up_range):
		target = null
		_change_state(State.IDLE)
		return

	# Si esta en rango de ataque, atacar
	if is_target_in_range(attack_range):
		_change_state(State.ATTACK)


func _validate_attack() -> void:
	if not is_instance_valid(target):
		_change_state(State.IDLE)
		return

	# Si el objetivo salio del rango de ataque, perseguir
	if not is_target_in_range(attack_range * 1.5):
		_change_state(State.CHASE)


func _process_idle(delta: float) -> void:
	_idle_timer -= delta

	if _idle_timer <= 0:
		# Elegir nuevo punto de vagabundeo
		var random_offset := Vector2(
			randf_range(-idle_wander_range, idle_wander_range),
			randf_range(-idle_wander_range, idle_wander_range)
		)
		_wander_target = _spawn_position + random_offset
		_idle_timer = idle_wait_time + randf_range(0, 1)

	# Moverse hacia el punto de vagabundeo
	var dist := global_position.distance_to(_wander_target)
	if dist > 10:
		var direction := (_wander_target - global_position).normalized()
		velocity = direction * speed * 0.3  # Movimiento lento al vagabundear
		move_and_slide()
		_rotate_visual(direction)
	else:
		velocity = Vector2.ZERO


func _process_chase(_delta: float) -> void:
	if not is_instance_valid(target):
		return

	var direction := (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	_rotate_visual(direction)


func _process_attack(_delta: float) -> void:
	if not is_instance_valid(target):
		return

	# Mirar hacia el objetivo
	var direction := (target.global_position - global_position).normalized()
	_rotate_visual(direction)

	# Intentar atacar
	if can_attack():
		perform_attack()


func _do_attack() -> void:
	if not is_instance_valid(target):
		return

	# Ataque basico cuerpo a cuerpo
	if target.has_method("take_damage"):
		target.take_damage(attack_damage, self)
	elif target is EntityBase:
		target.take_damage(attack_damage, self)
	elif "hp" in target:
		target.hp -= int(attack_damage)

	print("[%s] Ataco a %s por %d" % [name, target.name, int(attack_damage)])
	_attack_effect()


func _attack_effect() -> void:
	# Override para efectos visuales de ataque
	pass


func _rotate_visual(direction: Vector2) -> void:
	if visual:
		visual.rotation = direction.angle()


func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	var old_state := current_state
	current_state = new_state
	_on_state_changed(old_state, new_state)


func _on_state_changed(old_state: State, new_state: State) -> void:
	# Override para reaccionar a cambios de estado
	pass
