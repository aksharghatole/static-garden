shader_type canvas_item;

uniform float scanline_strength : hint_range(0.0, 1.0) = 0.15;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.6;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float scan = sin(UV.y * 900.0) * 0.5 + 0.5;
	c.rgb *= (1.0 - scan * scanline_strength);
	vec2 d = UV - 0.5;
	float v = 1.0 - dot(d, d) * vignette_strength;
	c.rgb *= clamp(v, 0.0, 1.0);
	COLOR = c;
}
