extends Node2D

# =============================================================================
# HONK MAGIC - Selection Visual
# =============================================================================
# Dibuja un círculo de selección alrededor de la unidad.

@export var color: Color = Color(0, 0.961, 0.831, 0.8)
@export var radius: float = 40.0
@export var line_width: float = 2.0
@export var pulse_speed: float = 2.0
@export var pulse_amount: float = 0.15

var _time: float = 0.0


func _process(delta: float) -> void:
	if visible:
		_time += delta
		queue_redraw()


func _draw() -> void:
	# Efecto de pulso
	var pulse := 1.0 + sin(_time * pulse_speed) * pulse_amount
	var current_radius := radius * pulse

	# Círculo exterior
	draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, color, line_width, true)

	# Pequeños marcadores en los puntos cardinales
	var marker_size := 5.0
	for i in range(4):
		var angle := i * TAU / 4.0
		var pos := Vector2(cos(angle), sin(angle)) * current_radius
		var inner := Vector2(cos(angle), sin(angle)) * (current_radius - marker_size)
		draw_line(inner, pos, color, line_width)
