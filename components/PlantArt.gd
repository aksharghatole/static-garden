extends Control

const PLANTS := preload("res://data/plants.gd")
var plant_id: String = ""
var stage: int = 0

func set_plant(id: String, growth_stage: int) -> void:
	plant_id = id
	stage = clampi(growth_stage, 0, 2)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var scale_factor := minf(size.x, size.y) / 64.0
	if plant_id.is_empty():
		draw_arc(center, 13.0 * scale_factor, 0.0, TAU, 32, Color("#506d5b"), 1.5, true)
		draw_line(center - Vector2(5, 0), center + Vector2(5, 0), Color("#506d5b"), 1.5, true)
		draw_line(center - Vector2(0, 5), center + Vector2(0, 5), Color("#506d5b"), 1.5, true)
		return
	var tint: Color = PLANTS.color_of(plant_id)
	var radius: float = [5.0, 13.0, 20.0][stage] * scale_factor
	if stage == 2:
		for i in range(3, 0, -1):
			draw_circle(center, radius + i * 3.0 * scale_factor, Color(tint, 0.06))
	draw_circle(center, radius, Color(tint, [0.2, 0.5, 1.0][stage]))
	if stage >= 1:
		draw_arc(center, radius * 0.75, -2.7, -0.9, 16, Color(1, 1, 1, 0.25), 1.5, true)
