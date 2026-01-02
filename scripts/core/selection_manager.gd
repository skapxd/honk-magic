class_name SelectionManager
extends Node2D

# =============================================================================
# HONK MAGIC - Selection Manager
# =============================================================================
# Sistema de selección RTS: click para seleccionar, arrastrar para caja.

signal selection_changed(units: Array)
signal move_command(position: Vector2, units: Array)

@export var box_fill_color: Color = Color(0, 0.961, 0.831, 0.15)
@export var box_border_color: Color = Color(0, 0.961, 0.831, 0.8)
@export var selection_group: String = "selectable"

var _dragging: bool = false
var _start_pos: Vector2 = Vector2.ZERO
var _end_pos: Vector2 = Vector2.ZERO
var _selected_units: Array = []


func _ready() -> void:
	# Asegurar que se dibuja encima de todo
	z_index = 100
	print("SelectionManager ready!")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Mouse button event: ", event.button_index, " pressed: ", event.pressed)
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _dragging:
		_end_pos = event.position
		queue_redraw()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	# Click izquierdo: selección
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag(event.position)

	# Click derecho: mover unidades seleccionadas
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if _selected_units.size() > 0:
			var world_pos := _screen_to_world(event.position)
			move_command.emit(world_pos, _selected_units.duplicate())


func _start_drag(pos: Vector2) -> void:
	_dragging = true
	_start_pos = pos
	_end_pos = pos


func _end_drag(pos: Vector2) -> void:
	if not _dragging:
		return

	_dragging = false
	_end_pos = pos
	queue_redraw()
	_perform_selection()


func _draw() -> void:
	if _dragging:
		var rect := _get_selection_rect()
		draw_rect(rect, box_fill_color)
		draw_rect(rect, box_border_color, false, 2.0)


func _get_selection_rect() -> Rect2:
	var top_left := Vector2(min(_start_pos.x, _end_pos.x), min(_start_pos.y, _end_pos.y))
	var size := (_end_pos - _start_pos).abs()
	return Rect2(top_left, size)


func _perform_selection() -> void:
	var rect := _get_selection_rect()

	# Limpiar selección previa
	_deselect_all()

	# Click simple vs arrastrar
	if rect.size.length() < 10:
		_single_select(_end_pos)
	else:
		_box_select(rect)

	selection_changed.emit(_selected_units.duplicate())


func _deselect_all() -> void:
	for unit in _selected_units:
		if is_instance_valid(unit) and unit.has_method("set_selected"):
			unit.set_selected(false)
	_selected_units.clear()


func _single_select(screen_pos: Vector2) -> void:
	var world_pos := _screen_to_world(screen_pos)
	print("Single select at screen: ", screen_pos, " -> world: ", world_pos)

	var space := get_world_2d().direct_space_state
	if not space:
		print("ERROR: No direct_space_state")
		return

	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_bodies = true
	query.collision_mask = 0xFFFFFFFF  # All layers

	var results := space.intersect_point(query)
	print("Found ", results.size(), " colliders")

	for result in results:
		var collider = result.collider
		print("  Collider: ", collider.name, " groups: ", collider.get_groups())
		if collider.is_in_group(selection_group):
			_select_unit(collider)
			break


func _box_select(screen_rect: Rect2) -> void:
	var space := get_world_2d().direct_space_state
	if not space:
		return

	# Convertir esquinas a coordenadas del mundo
	var world_top_left := _screen_to_world(screen_rect.position)
	var world_bottom_right := _screen_to_world(screen_rect.position + screen_rect.size)
	var world_center := (world_top_left + world_bottom_right) / 2.0
	var world_size := (world_bottom_right - world_top_left).abs()

	print("Box select - center: ", world_center, " size: ", world_size)

	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = world_size
	query.shape = shape
	query.transform = Transform2D(0, world_center)
	query.collide_with_bodies = true
	query.collision_mask = 0xFFFFFFFF

	var results := space.intersect_shape(query)
	print("Box found ", results.size(), " colliders")

	for result in results:
		var collider = result.collider
		if collider.is_in_group(selection_group):
			_select_unit(collider)


func _select_unit(unit: Node) -> void:
	if unit.has_method("set_selected"):
		unit.set_selected(true)
	_selected_units.append(unit)


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	# Usar el canvas transform del viewport para convertir correctamente
	var canvas_transform := get_viewport().get_canvas_transform()
	return canvas_transform.affine_inverse() * screen_pos


func get_selected_units() -> Array:
	return _selected_units.duplicate()


func clear_selection() -> void:
	_deselect_all()
	selection_changed.emit([])
