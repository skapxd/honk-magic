extends Node2D

# =============================================================================
# HONK MAGIC - Debug Grid
# =============================================================================
# Visual grid for debug scenes to help visualize movement.

@export var grid_size: float = 100.0
@export var grid_color: Color = Color(0.2, 0.25, 0.35, 0.3)
@export var origin_color: Color = Color(0.988, 0.639, 0.067, 0.5)
@export var extent: float = 2000.0


func _draw() -> void:
	# Grid lines
	var start := -extent
	var end := extent

	# Vertical lines
	var x := start
	while x <= end:
		var color := origin_color if x == 0 else grid_color
		var width := 2.0 if x == 0 else 1.0
		draw_line(Vector2(x, start), Vector2(x, end), color, width)
		x += grid_size

	# Horizontal lines
	var y := start
	while y <= end:
		var color := origin_color if y == 0 else grid_color
		var width := 2.0 if y == 0 else 1.0
		draw_line(Vector2(start, y), Vector2(end, y), color, width)
		y += grid_size
