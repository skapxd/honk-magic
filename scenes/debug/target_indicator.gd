extends Node2D

# =============================================================================
# HONK MAGIC - Target Indicator
# =============================================================================
# Visual indicator for movement target (click position).

@export var color: Color = Color(0, 0.961, 0.831, 0.8)
@export var radius: float = 15.0
@export var duration: float = 0.5

var _current_radius: float = 0.0
var _current_alpha: float = 1.0
var _tween: Tween = null


func _draw() -> void:
	if _current_alpha <= 0.0:
		return

	var draw_color := Color(color.r, color.g, color.b, _current_alpha * color.a)
	draw_arc(Vector2.ZERO, _current_radius, 0, TAU, 32, draw_color, 2.0, true)

	# Cruz central
	var cross_size := 5.0
	draw_line(Vector2(-cross_size, 0), Vector2(cross_size, 0), draw_color, 2.0)
	draw_line(Vector2(0, -cross_size), Vector2(0, cross_size), draw_color, 2.0)


func start_animation() -> void:
	if _tween:
		_tween.kill()

	_current_radius = 0.0
	_current_alpha = 1.0
	visible = true

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "_current_radius", radius, duration).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "_current_alpha", 0.0, duration).set_delay(duration * 0.3)
	_tween.set_parallel(false)
	_tween.tween_callback(_on_animation_finished)


func _on_animation_finished() -> void:
	visible = false


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()
