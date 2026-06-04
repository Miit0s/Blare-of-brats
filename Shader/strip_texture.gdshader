shader_type canvas_item;

// --- COULEURS ---
uniform vec4 color_border : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Blanc
uniform vec4 color_stripe1 : source_color = vec4(0.6, 0.1, 0.9, 1.0); // Violet clair
uniform vec4 color_stripe2 : source_color = vec4(0.4, 0.05, 0.7, 1.0); // Violet foncé

// --- RÉGLAGES DES RAYURES ---
uniform float stripe_density = 20.0; // Nombre de rayures
uniform float stripe_slant = 0.5; // Mets à 0.0 pour des lignes 100% verticales !
uniform float speed = 1.0; // Vitesse de l'animation vers la droite

// --- RÉGLAGES DE LA BORDURE ---
// Ajuste ces valeurs selon les proportions de ton rectangle
uniform float border_size_x = 0.01; 
uniform float border_size_y = 0.08; 

void fragment() {
    vec2 uv = UV;

    // 1. Dessiner la bordure
    bool is_border = uv.x < border_size_x || uv.x > 1.0 - border_size_x || 
                     uv.y < border_size_y || uv.y > 1.0 - border_size_y;

    if (is_border) {
        COLOR = color_border;
    } else {
        // 2. Calculer l'espace intérieur (sans la bordure)
        float inner_x = (uv.x - border_size_x) / (1.0 - 2.0 * border_size_x);

        // Partie remplie (avec les rayures)
        
        // On soustrait TIME * speed pour que le mouvement aille de gauche à droite
        float stripe_uv = uv.x - (uv.y * stripe_slant) - (TIME * speed * 0.1);

        // La fonction fract() permet de répéter le motif à l'infini
        float pattern = fract(stripe_uv * stripe_density);

        // On alterne entre les deux couleurs de rayures
        if (pattern < 0.5) {
            COLOR = color_stripe1;
        } else {
            COLOR = color_stripe2;
        }
    }
}