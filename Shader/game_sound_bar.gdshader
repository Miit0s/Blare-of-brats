shader_type canvas_item;

// Paramètres de progression
uniform float progress : hint_range(0.0, 1.0) = 0.5; // La position de remplissage
uniform float progress_range : hint_range(0.0, 1.0) = 0.1; // La largeur de la zone de transition (fondue)

// Paramètres des arcs de cercle (netteté et fréquence)
uniform float frequency: hint_range(0, 30, 0.1) = 15.0; // Fréquence des arcs (plus élevé = plus rapprochés)
uniform float rippleRate : hint_range(0.5, 150.0, 0.1) = 8.0; // Vitesse de propagation
uniform float ripple_amplitude : hint_range(0.0, 2.0, 0.01) = 1.0; // Intensité de l'alpha des arcs
uniform vec4 base_color: source_color = vec4(1.0, 1.0, 1.0, 1.0); // Couleur des arcs

// Contrôle de l'alpha (fondu)
uniform float alpha_falloff_power : hint_range(1.0, 10.0) = 2.0; // Puissance de la courbe de fondu

uniform vec2 rect_size = vec2(200.0, 50.0);

void fragment() {
	float aspect = rect_size.x / rect_size.y;
	vec2 corrected_uv = vec2(UV.x * aspect, UV.y);
	
	float dist_x = corrected_uv.x;
	
	float ripple = sin(dist_x * -frequency * PI + rippleRate * TIME) * ripple_amplitude;
	
	float curve_amount = (corrected_uv.y - 0.5) * (corrected_uv.y - 0.5);
	dist_x += curve_amount * 0.2;
	
	ripple = sin(dist_x * -frequency * PI + rippleRate * TIME) * ripple_amplitude;
	
	float mask = smoothstep(progress, progress - progress_range, UV.x);
	
	vec4 color = base_color;
	
	float alpha = mask * ripple; 
	alpha = pow(alpha, alpha_falloff_power); 
	color.a = clamp(alpha, 0.0, 1.0);
	
	COLOR = color;
}