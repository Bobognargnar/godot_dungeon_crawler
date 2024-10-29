shader_type canvas_item;

uniform sampler2D gradient_texture;
uniform int amount = 3; // Pixelation amount

void fragment() {
    // Round only the x component of the UVs to create the pixelation effect
    float pixelated_x = round(UV.x * float(amount)) / float(amount);
    
    // Sample the color from the texture at the pixelated x coordinate
    vec4 tex_color = texture(gradient_texture, vec2(pixelated_x, UV.y));
    
    COLOR = tex_color;
}