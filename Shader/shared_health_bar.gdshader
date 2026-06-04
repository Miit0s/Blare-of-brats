shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 0.5;

uniform vec4 color_left: source_color = vec4(0, 0, 1, 1);
uniform vec4 color_right: source_color = vec4(1, 0, 0, 1);

uniform float shear_angle : hint_range(-1.0, 1.0) = 0.0;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	
	float adjusted_x = UV.x + (UV.y - 0.5) * shear_angle;
	
	float mask = progress - adjusted_x;
	float edge = smoothstep(-0.005, 0.005, mask);
	
	vec4 final_color = mix(color_right, color_left, edge);
	
	COLOR = final_color;
	COLOR.a = texture_color.a;
}
