class_name JumpDots
extends Node2D

# Three little dots under Jelly in Sky Climb: one greys out for each air jump.

var total := 3
var used := 0


func set_used(value: int) -> void:
	if value != used:
		used = value
		queue_redraw()


func _draw() -> void:
	var spacing := 16.0
	var start := -spacing * float(total - 1) * 0.5
	for i in range(total):
		var at := Vector2(start + spacing * float(i), 0.0)
		var available := i < total - used
		draw_circle(at, 6.5, Color(1.0, 1.0, 1.0, 0.95))
		draw_circle(at, 4.5, Color("3fd3b0") if available else Color(0.62, 0.66, 0.72, 0.9))
