shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, depth_prepass_alpha;

uniform sampler2D main_texture : source_color;

uniform vec4 original_0 : source_color;
uniform vec4 original_1 : source_color;
uniform vec4 original_2 : source_color;
uniform vec4 original_3 : source_color;
uniform vec4 original_4 : source_color;
uniform vec4 original_5 : source_color;
uniform vec4 original_6 : source_color;

uniform vec4 replace_0 : source_color;
uniform vec4 replace_1 : source_color;
uniform vec4 replace_2 : source_color;
uniform vec4 replace_3 : source_color;
uniform vec4 replace_4 : source_color;
uniform vec4 replace_5 : source_color;
uniform vec4 replace_6 : source_color;

// Contrôle de la détection
uniform float tolerance : hint_range(0.0, 1.0) = 0.1;
// Contrôle du lissage (plus c'est haut, plus la transition est douce)
uniform float softness : hint_range(0.0, 1.0) = 0.05;

uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec4 color_override : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float blend_delta : hint_range(0.0, 1.0, 0.02) = 0.0;

uniform float emission_energy : hint_range(0.0, 16.0) = 1.0;

uniform float saturation : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	vec2 real_uv = uv_offset + (UV * uv_scale);
    vec4 tex_color = texture(main_texture, real_uv);
	
	vec3 base_pixel_rgb = tex_color.rgb;
	
    vec3 current_rgb = tex_color.rgb;
    
    vec4 originals[7] = vec4[7](original_0, original_1, original_2, original_3, original_4, original_5, original_6);
    vec4 replacements[7] = vec4[7](replace_0, replace_1, replace_2, replace_3, replace_4, replace_5, replace_6);
    
    for (int i = 0; i < 7; i++) {
        float d = distance(base_pixel_rgb, originals[i].rgb);
        float mask = 1.0 - smoothstep(tolerance - softness, tolerance + softness, d);
		
        current_rgb = mix(current_rgb, replacements[i].rgb, mask);
    }
	
	vec3 final_rgb = mix(current_rgb, color_override.rgb, blend_delta);
	
	float luminance = dot(final_rgb, vec3(0.299, 0.587, 0.114));
	vec3 grayscale = vec3(luminance);
	
	final_rgb = mix(grayscale, final_rgb, saturation);
    
    ALBEDO = final_rgb;
    ALPHA = tex_color.a * COLOR.a;
	EMISSION = final_rgb * emission_energy * ALPHA;
}