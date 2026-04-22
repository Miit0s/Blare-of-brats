shader_type spatial;
render_mode cull_disabled;

uniform sampler2D sprite_texture: source_color;

uniform vec4 color_to_swap: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 new_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float threshold: hint_range(0.0, 1.0) = 0.01;

void fragment() {
	vec4 texture_color = texture(sprite_texture, UV);
	
	if (distance(texture_color, color_to_swap) < threshold) {
		ALBEDO = new_color.rgb;
		ALPHA = new_color.a;
	} else {
		ALBEDO = texture_color.rgb;
		ALPHA = texture_color.a;
	}
}
