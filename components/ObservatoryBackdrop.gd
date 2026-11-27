extends Control

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0b1715"))
	var center := Vector2(size.x * 0.5, size.y * 0.30)
	var radius := minf(size.x, size.y) * 0.36
	for i in range(4):
		draw_arc(center, radius + float(i) * 22, -PI, PI, 96, Color(0.25, 0.46, 0.36, 0.19), 1.0, true)
	for i in range(48):
		var x := fposmod(float(i) * 137.508, maxf(1, size.x))
		var y := fposmod(float(i) * 93.17, maxf(1, size.y))
		draw_circle(Vector2(x, y), 1.2 if i % 7 == 0 else 0.65, Color(0.83, 0.9, 0.71, 0.25))
	# A quiet orbital signal in the greenhouse sky.
	draw_arc(center, radius, -2.8, -0.7, 40, Color("#83af78"), 2, true)
	draw_circle(center + Vector2.RIGHT.rotated(-0.7) * radius, 4, Color("#e9bb78"))
