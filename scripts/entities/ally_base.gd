class_name AllyBase
extends EntityBase

# =============================================================================
# HONK MAGIC - Ally Base
# =============================================================================
# Clase base para aliados controlables por el jugador.

signal selection_changed(is_selected: bool)

@export var auto_attack_range: float = 150.0
@export var show_debug_ranges: bool = true

var is_selected: bool = false:
	set(value):
		is_selected = value
		_update_selection_visual()
		selection_changed.emit(is_selected)

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var _idle_timer: float = 0.0

@onready var visual: Node2D = $Visual
@onready var selection_visual: Node2D = $SelectionVisual


func _setup_entity() -> void:
	team = Team.PLAYER
	add_to_group("allies")
	add_to_group("selectable")
	target_position = global_position
	queue_redraw()


func _draw() -> void:
	if not show_debug_ranges:
		return

	# Rango de auto-ataque (cyan)
	draw_arc(Vector2.ZERO, auto_attack_range, 0, TAU, 24, Color(0, 1, 1, 0.2), 1.5)

	# Rango de ataque (rojo)
	draw_arc(Vector2.ZERO, attack_range, 0, TAU, 16, Color(1, 0.5, 0, 0.3), 1.5)

	# Línea hacia el objetivo de movimiento (azul)
	if is_moving:
		var to_target: Vector2 = target_position - global_position
		draw_line(Vector2.ZERO, to_target, Color(0, 0.5, 1, 0.5), 1.5)

	# Línea hacia el enemigo (verde)
	if is_instance_valid(target):
		var to_enemy: Vector2 = target.global_position - global_position
		draw_line(Vector2.ZERO, to_enemy, Color(0, 1, 0, 0.7), 2.0)


func _update_state(_delta: float) -> void:
	if show_debug_ranges:
		queue_redraw()

	match current_state:
		State.IDLE:
			_check_for_enemies()
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


func _check_for_enemies() -> void:
	# Buscar enemigos en rango de auto-ataque
	var enemies := get_tree().get_nodes_in_group("enemies")
	var potential_targets: Array[Node2D] = []

	for e in enemies:
		if e is Node2D and is_instance_valid(e):
			var enemy := e as Node2D
			if enemy.has_method("is_alive") and not enemy.is_alive():
				continue
			potential_targets.append(enemy)

	target = find_nearest_target(potential_targets)

	if is_instance_valid(target) and is_target_in_range(auto_attack_range):
		_change_state(State.CHASE)


func _validate_chase() -> void:
	if not is_instance_valid(target):
		_change_state(State.IDLE)
		return

	# Verificar si el enemigo sigue vivo
	if target.has_method("is_alive") and not target.is_alive():
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

	# Verificar si el enemigo sigue vivo
	if target.has_method("is_alive") and not target.is_alive():
		target = null
		_change_state(State.IDLE)
		return

	# Si el objetivo salio del rango de ataque, perseguir
	if not is_target_in_range(attack_range * 1.5):
		_change_state(State.CHASE)


func _process_idle(delta: float) -> void:
	# Moverse hacia target_position si hay comando de movimiento
	if is_moving:
		_move_to_target_position(delta)


func _process_chase(delta: float) -> void:
	if not is_instance_valid(target):
		return

	# Moverse hacia el enemigo
	var direction := (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	_rotate_visual(direction)


func _process_attack(delta: float) -> void:
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

	# Ataque cuerpo a cuerpo
	if target.has_method("take_damage"):
		target.take_damage(attack_damage, self)
	elif "hp" in target:
		target.hp -= int(attack_damage)

	_attack_effect()


func _attack_effect() -> void:
	# Efecto visual de ataque
	if visual:
		var original_pos := visual.position
		var direction := Vector2.RIGHT.rotated(visual.rotation - PI/2)
		var tween := create_tween()
		tween.tween_property(visual, "position", original_pos + direction * 15, 0.1)
		tween.tween_property(visual, "position", original_pos, 0.1)


func _move_to_target_position(_delta: float) -> void:
	var direction := (target_position - global_position).normalized()
	var distance := global_position.distance_to(target_position)

	if distance > 10.0:
		velocity = direction * speed
		move_and_slide()
		_rotate_visual(direction)
	else:
		velocity = Vector2.ZERO
		is_moving = false


func _rotate_visual(direction: Vector2) -> void:
	if visual:
		visual.rotation = lerp_angle(visual.rotation, direction.angle() + PI / 2, 0.15)


func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state


func _update_selection_visual() -> void:
	if selection_visual:
		selection_visual.visible = is_selected


# ==================== Public API ====================

func set_selected(value: bool) -> void:
	is_selected = value


func move_to(pos: Vector2) -> void:
	"""Comando de movimiento desde Selection Manager"""
	target_position = pos
	is_moving = true
	# Cancelar persecución si estamos moviendo manualmente
	if current_state == State.CHASE:
		target = null
		_change_state(State.IDLE)
