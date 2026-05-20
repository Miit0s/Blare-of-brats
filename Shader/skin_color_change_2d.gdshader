shader_type canvas_item;

uniform sampler2D main_texture : source_color;

uniform vec4 original_0 : source_color;
uniform vec4 original_1 : source_color;
uniform vec4 original_2 : source_color;
uniform vec4 original_3 : source_color;
uniform vec4 original_4 : source_color;

uniform vec4 replace_0 : source_color;
uniform vec4 replace_1 : source_color;
uniform vec4 replace_2 : source_color;
uniform vec4 replace_3 : source_color;
uniform vec4 replace_4 : source_color;

// Contrôle de la détection
uniform float tolerance : hint_range(0.0, 1.0) = 0.1;
// Contrôle du lissage (plus c'est haut, plus la transition est douce)
uniform float softness : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 tex_color = texture(main_texture, UV);
	
    vec3 current_rgb = tex_color.rgb;
    
    vec4 originals[5] = vec4[5](original_0, original_1, original_2, original_3, original_4);
    vec4 replacements[5] = vec4[5](replace_0, replace_1, replace_2, replace_3, replace_4);
    
    for (int i = 0; i < 5; i++) {
        float d = distance(current_rgb, originals[i].rgb);
        float mask = 1.0 - smoothstep(tolerance - softness, tolerance + softness, d);
		
        current_rgb = mix(current_rgb, replacements[i].rgb, mask);
    }
    
    COLOR = vec4(current_rgb, COLOR.a);
}