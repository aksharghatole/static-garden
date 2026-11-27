extends Control

const PLANTS := preload("res://data/plants.gd")
var plant_id: String = ""
var stage: int = 0
var reveal: float = 1.0:
	set(value):
		reveal = value
		queue_redraw()
var transition: Tween

func set_plant(id: String, growth_stage: int) -> void:
	var next_stage := clampi(growth_stage, 0, 2)
	if plant_id == id and stage == next_stage:
		return
	plant_id = id
	stage = next_stage
	if transition and transition.is_valid():
		transition.kill()
	reveal = 1.0
	if is_inside_tree() and not plant_id.is_empty():
		reveal = 0.76
		transition = create_tween()
		transition.tween_property(self, "reveal", 1.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	queue_redraw()

func _ready() -> void:
	resized.connect(queue_redraw)

func leaf(center: Vector2, length: float, width: float, angle: float, tint: Color) -> void:
	var points := PackedVector2Array()
	for i in range(20):
		var t := TAU * float(i) / 20.0
		points.append(center + Vector2(cos(t) * length, sin(t) * width).rotated(angle))
	draw_colored_polygon(points, tint)
	var direction := Vector2.RIGHT.rotated(angle)
	draw_line(center - direction * length * 0.7, center + direction * length * 0.7, tint.darkened(0.24), 0.75, true)

func _draw() -> void:
	var unit := minf(size.x, size.y) / 80.0
	if unit <= 0.0:
		return
	draw_set_transform(size * 0.5, 0.0, Vector2.ONE * unit)
	draw_circle(Vector2(0, 9), 32, Color("#102920"))
	draw_arc(Vector2(0, 9), 30, 0, TAU, 48, Color("#345245"), 1.0, true)
	draw_arc(Vector2(0, 9), 25, 0, TAU, 48, Color("#28473a"), 0.7, true)
	if plant_id.is_empty():
		draw_arc(Vector2.ZERO, 10, 0, TAU, 24, Color("#63816e"), 1.0, true)
		draw_line(Vector2(-4, 0), Vector2(4, 0), Color("#63816e"), 1.5, true)
		draw_line(Vector2(0, -4), Vector2(0, 4), Color("#63816e"), 1.5, true)
		return
	var tint: Color = PLANTS.color_of(plant_id)
	draw_set_transform(size * 0.5, 0.0, Vector2.ONE * unit * reveal)
	if stage == 0:
		leaf(Vector2(0, 7), 6, 4, -0.6, tint.darkened(0.25))
		draw_circle(Vector2(-1, 5), 1.3, Color("#e5ce93"))
		return
	if stage == 2:
		for i in range(4, 0, -1):
			draw_circle(Vector2(0, -4), 17 + i * 4, Color(tint, 0.035))
	draw_line(Vector2(0, 20), Vector2(0, -7 if stage == 1 else -20), Color("#8cb68a"), 2.0, true)
	leaf(Vector2(-7, 5), 9, 4, 0.5, Color("#79a976"))
	leaf(Vector2(7, -2), 9, 4, -0.6, Color("#9abf80"))
	if stage == 1:
		leaf(Vector2(0, -8), 6, 3, -1.1, tint)
		return
	match plant_id:
		"moss":
			for i in range(7):
				var angle := TAU * float(i) / 7.0
				draw_circle(Vector2(cos(angle) * 12, sin(angle) * 7 + 7), 8, tint.darkened(0.15 + float(i % 3) * 0.12))
			draw_circle(Vector2(-3, 2), 9, tint.lightened(0.16))
		"fern":
			for i in range(4):
				var y := 9.0 - float(i) * 8.0
				var extent := 13.0 - float(i) * 2.0
				leaf(Vector2(-extent * 0.6, y), extent, 3.2, 0.65, tint)
				leaf(Vector2(extent * 0.6, y - 2), extent, 3.2, -0.65, tint.lightened(0.13))
			leaf(Vector2(0, -23), 8, 3, -PI / 2, tint)
		"lily", "orchid":
			var petals := 6 if plant_id == "lily" else 5
			for i in range(petals):
				var angle := TAU * float(i) / float(petals) - PI / 2.0
				var offset := Vector2.RIGHT.rotated(angle) * 9
				leaf(Vector2(0, -15) + offset, 10, 5, angle, tint.lightened(0.12))
			draw_circle(Vector2(0, -15), 4.2, Color("#e9bb78"))
		"mist":
			for i in range(6):
				var angle := TAU * float(i) / 6.0
				var point := Vector2(cos(angle) * 12, sin(angle) * 8 + 5)
				draw_circle(point, 7, tint.darkened(0.14))
				leaf(point + Vector2(0, -6), 8, 3, angle, tint.lightened(0.2))
			for i in range(3):
				draw_circle(Vector2(-13 + i * 13, -17 - (i % 2) * 6), 2, Color(tint, 0.65))
		"dewbell":
			for i in range(3):
				var x := float(i - 1) * 15.0
				var y := -12.0 - float(i % 2) * 9.0
				draw_line(Vector2(0, 12), Vector2(x, y), Color("#8cb68a"), 1.4, true)
				leaf(Vector2(x, y + 4), 7, 5, PI / 2, tint)
				draw_circle(Vector2(x, y + 10), 2.8, Color("#d5e5b5"))
		"voidmoss":
			for i in range(8):
				var angle := TAU * float(i) / 8.0
				var point := Vector2(cos(angle) * 15, sin(angle) * 10 + 4)
				draw_circle(point, 7, tint.darkened(0.35))
				draw_circle(point + Vector2(0, -3), 2.2, tint.lightened(0.3))
			draw_circle(Vector2(0, 2), 8, Color("#30264d"))
			draw_arc(Vector2(0, 2), 10, 0, TAU, 36, tint, 1.8, true)
		"fernlily":
			for i in range(4):
				var y := 12.0 - float(i) * 8.0
				leaf(Vector2(-9, y), 11 - i, 3, 0.55, Color("#83af78"))
				leaf(Vector2(9, y), 11 - i, 3, -0.55, tint)
			for i in range(6):
				var angle := TAU * float(i) / 6.0
				leaf(Vector2(0, -20) + Vector2.RIGHT.rotated(angle) * 6, 7, 3, angle, tint.lightened(0.22))
			draw_circle(Vector2(0, -20), 3, Color("#e9bb78"))
		"thornfern":
			for i in range(5):
				var y := 14.0 - float(i) * 8.0
				var span := 19.0 - float(i) * 2.2
				for side in [-1.0, 1.0]:
					var points := PackedVector2Array([Vector2(0, y + 3), Vector2(side * span, y - 9), Vector2(side * 5, y - 4)])
					draw_colored_polygon(points, tint.darkened(float(i % 2) * 0.18))
			draw_circle(Vector2(0, -23), 3.4, tint.lightened(0.25))
		"moonflower":
			for i in range(9):
				var angle := TAU * float(i) / 9.0
				leaf(Vector2(0, -13) + Vector2.RIGHT.rotated(angle) * 10, 12, 4.5, angle, tint.darkened(0.12))
			draw_circle(Vector2(0, -13), 7, Color("#e9bb78"))
			draw_circle(Vector2(3, -16), 6, Color("#574867"))
		_:
			for i in range(5):
				var angle := TAU * float(i) / 5.0
				leaf(Vector2(0, -13) + Vector2.RIGHT.rotated(angle) * 8, 10, 4, angle, tint)
			draw_circle(Vector2(0, -13), 3, Color("#e9bb78"))
	draw_circle(Vector2(-22, -18), 1.2, Color("#e9bb78"))
	draw_circle(Vector2(22, -7), 1.0, Color("#d5e5b5"))
