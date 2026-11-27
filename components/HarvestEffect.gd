extends Control

var progress: float = 1.0:
	set(value):
		progress = value
		queue_redraw()
var reward: int = 0
var tint: Color = Color.WHITE
var animation: Tween

func play(amount: int, color: Color) -> void:
	reward = amount
	tint = color
	if animation and animation.is_valid():
		animation.kill()
	progress = 0.0
	animation = create_tween()
	animation.tween_property(self, "progress", 1.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	if progress >= 1.0:
		return
	var origin := Vector2(size.x * 0.5, size.y * 0.4)
	var alpha := 1.0 - progress
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var distance := (8.0 + progress * 35.0) * (0.7 + float(i % 3) * 0.15)
		var point := origin + Vector2.RIGHT.rotated(angle) * distance - Vector2(0, progress * 15)
		draw_circle(point, 1.4 + float(i % 3) * 0.7, Color(tint.lightened(0.25), alpha))
	draw_arc(origin, 8.0 + 30.0 * progress, 0, TAU, 40, Color("#e9bb78", alpha * 0.65), 1.5, true)
	var font := get_theme_default_font()
	var label := "+%d" % reward
	var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
	var pos := origin + Vector2(-width * 0.5, -8.0 - progress * 22)
	draw_string(font, pos + Vector2(1, 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.03, 0.06, 0.05, alpha))
	draw_string(font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#e9bb78", alpha))
