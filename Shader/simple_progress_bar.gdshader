shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    
    float visible = step(UV.x, progress);
    
    COLOR = base_color * COLOR;
    COLOR.a = base_color.a * visible;
}