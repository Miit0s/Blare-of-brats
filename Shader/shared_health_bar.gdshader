shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 0.5;

uniform vec4 color_left: source_color = vec4(0, 0, 1, 1);
uniform vec4 color_right: source_color = vec4(1, 0, 0, 1);

uniform vec2 rect_size = vec2(200.0, 50.0);

uniform sampler2D noise_texture: repeat_enable;
uniform float noise_intensity: hint_range(0.0, 1.0) = 0.4;

uniform float transition_blur: hint_range(0.0, 0.5) = 0.001;

uniform vec2 uv_offset = vec2(0.0, 0.0);

void fragment() {
	float aspect = rect_size.x / rect_size.y;
	vec2 corrected_uv = vec2(UV.x * aspect, UV.y);
	
	vec2 moving_uv = corrected_uv + uv_offset;
	
	float mask = (1.0 - UV.x) + (progress * 2.0 - 1.0);
	float noise = texture(noise_texture, moving_uv).r;
	
	float combined = mask + (noise - 0.5) * noise_intensity;
	
	float edge = smoothstep(0.5 - transition_blur, 0.5 + transition_blur, combined);
	
	vec4 final_color = mix(color_right, color_left, edge);
	COLOR = final_color;
}
