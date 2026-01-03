class_name Player
extends CharacterBody2D

# =============================================================================
# HONK MAGIC - Player (RTS Version)
# =============================================================================
# Jugador con seleccion visual y movimiento RTS.

signal hp_changed(current: int, max_hp: int)
signal mp_changed(current: int, max_mp: int)

@export var speed: float = 300.0
@export var player_color: Color = Color(0.88, 0.88, 0.88)
@export var selection_color: Color = Color(0, 0.961, 0.831, 0.8)
@export var player_size: float = 30.0

@export var max_hp: int = 100
@export var max_mp: int = 100

var hp: int = 100:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)

var mp: int = 100:
	set(value):
		mp = clampi(value, 0, max_mp)
		mp_changed.emit(mp, max_mp)

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_selected: bool = false:
	set(value):
		is_selected = value
		_update_selection_visual()

@onready var visual: Polygon2D = $Visual
@onready var selection_visual: Node2D = $SelectionVisual


func _ready() -> void:
	add_to_group("selectable")
	add_to_group("player")
	target_position = global_position
	_create_hexagon_visual()
	_update_selection_visual()

	print("[Player] Posicion inicial: %s" % global_position)

	# Inicializar HP/MP desde SaveManager si existe
	if SaveManager.current_data:
		print("[Player] Cargando desde SaveManager - posicion guardada: %s" % SaveManager.current_data.position)
		hp = SaveManager.current_data.hp_actual
		mp = SaveManager.current_data.mp_actual
		global_position = SaveManager.current_data.position
		target_position = global_position
		print("[Player] Nueva posicion: %s" % global_position)

		# Resetear smoothing de la camara para evitar el "salto" visual
		var camera := get_node_or_null("Camera2D") as Camera2D
		if camera:
			print("[Player] Reseteando smoothing de camara")
			camera.reset_smoothing()

	# Emitir valores iniciales
	hp_changed.emit(hp, max_hp)
	mp_changed.emit(mp, max_mp)


func _create_hexagon_visual() -> void:
	if not visual:
		return

	var points: PackedVector2Array = []
	for i in range(6):
		var angle := i * TAU / 6.0 - PI / 6.0
		points.append(Vector2(cos(angle), sin(angle)) * player_size)

	visual.polygon = points
	visual.color = player_color


func _update_selection_visual() -> void:
	if selection_visual:
		selection_visual.visible = is_selected
		selection_visual.queue_redraw()


func set_selected(value: bool) -> void:
	is_selected = value


func move_to(pos: Vector2) -> void:
	target_position = pos
	is_moving = true


func _physics_process(_delta: float) -> void:
	if not is_moving:
		return

	var direction := (target_position - global_position).normalized()
	var distance := global_position.distance_to(target_position)

	if distance > 5.0:
		velocity = direction * speed
		move_and_slide()

		# Rotar suavemente hacia la direccion
		visual.rotation = lerp_angle(visual.rotation, direction.angle() + PI / 2, 0.1)
	else:
		velocity = Vector2.ZERO
		is_moving = false


func save_state() -> void:
	"""Guarda el estado actual en SaveManager"""
	if SaveManager.current_data:
		SaveManager.current_data.hp_actual = hp
		SaveManager.current_data.mp_actual = mp
		SaveManager.current_data.position = global_position


func take_damage(amount: float, from: Node2D = null) -> void:
	"""Recibe daño de una fuente externa"""
	var damage := int(amount)
	hp -= damage
	print("[Player] Recibio %d de dano de %s. HP: %d/%d" % [damage, from.name if from else "unknown", hp, max_hp])

	# Efecto visual de daño
	_flash_damage()

	# Verificar muerte
	if hp <= 0:
		_on_death()


func _flash_damage() -> void:
	var original_modulate := modulate
	modulate = Color.RED
	var tween := create_tween()
	tween.tween_property(self, "modulate", original_modulate, 0.15)


func _on_death() -> void:
	print("[Player] Murio!")
	# TODO: Implementar game over en Entregable 13
