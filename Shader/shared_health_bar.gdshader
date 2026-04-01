shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 0.5;

uniform vec4 color_left: source_color = vec4(0, 0, 1, 1);
uniform vec4 color_right: source_color = vec4(1, 0, 0, 1);

uniform float wave_amplitude: hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency: hint_range(0.0, 20.0) = 10.0;
uniform float wave_speed: hint_range(0.0, 10.0) = 5.0;

uniform float transition_blur: hint_range(0.0, 0.1) = 0.001;

void fragment() {
	float wave1 = sin(UV.y * wave_frequency + TIME * wave_speed);
	float wave2 = cos(UV.y * wave_frequency * 2.3 - TIME * wave_speed * 1.7);
	float combined_wave = (wave1 + wave2) * 0.5 * wave_amplitude;
	
	float threshold = progress + combined_wave;
	float edge = smoothstep(threshold - transition_blur, threshold + transition_blur, UV.x);
	
	vec4 final_color = mix(color_left, color_right, edge);
	COLOR = final_color;
}
