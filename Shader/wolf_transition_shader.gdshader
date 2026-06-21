shader_type canvas_item;

uniform sampler2D video_mask : filter_linear_mipmap;

// Paramètres pour le Vert (Transparence)
uniform float green_threshold = 0.4;
uniform float green_smoothing = 0.1;

// Paramètres pour le Blanc (Scène actuelle)
uniform float white_threshold = 0.8;
uniform float white_smoothing = 0.1;

void fragment() {
    // 1. Couleurs de base
    vec4 original_color = texture(TEXTURE, UV);
    vec4 video_color = texture(video_mask, SCREEN_UV);
    
    // 2. Est-ce que le pixel de la vidéo est VERT ? (Valeur de 0.0 à 1.0)
    float green_diff = video_color.g - max(video_color.r, video_color.b);
    float is_green = smoothstep(green_threshold - green_smoothing, green_threshold + green_smoothing, green_diff);
    
    // 3. Est-ce que le pixel de la vidéo est BLANC ? (Valeur de 0.0 à 1.0)
    // On prend la valeur minimum entre Rouge, Vert et Bleu. 
    // Si le minimum est proche de 1, ça veut dire que les 3 couleurs sont à 1, donc c'est du blanc.
    float whiteness = min(video_color.r, min(video_color.g, video_color.b));
    float is_white = smoothstep(white_threshold - white_smoothing, white_threshold + white_smoothing, whiteness);
    
    // 4. LE MÉLANGE (Compositing)
    // On commence par dire : la couleur finale EST la couleur de la vidéo (tes autres couleurs).
    // MAIS, on la mélange avec ta scène actuelle en fonction de "is_white".
    // Si is_white = 1 (c'est blanc), la scène actuelle remplace la vidéo.
    vec4 final_color = mix(video_color, original_color, is_white);
    
    // 5. LA TRANSPARENCE
    // Enfin, si c'est vert (is_green = 1), on multiplie l'opacité par 0.
    final_color.a *= (1.0 - is_green);
    
    COLOR = final_color;
}