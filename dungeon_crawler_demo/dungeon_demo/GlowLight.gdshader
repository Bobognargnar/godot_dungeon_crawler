shader_type canvas_item;
render_mode blend_add;

uniform vec2 center = vec2(0.5);
uniform float size : hint_range(0.0, 5.0) = 1.0;
uniform vec2 squishness = vec2(1.0);

uniform vec4 color1;
uniform vec4 color2;
uniform vec4 color3;
uniform vec4 color4;
uniform vec4 color5;
uniform vec4 color6;

uniform float step1 : hint_range(0.0, 1.0) = 0.159;
uniform float step2 : hint_range(0.0, 1.0) = 0.182;
uniform float step3 : hint_range(0.0, 1.0) = 0.233;
uniform float step4 : hint_range(0.0, 1.0) = 0.264;
uniform float step5 : hint_range(0.0, 1.0) = 0.265;
uniform float step6 : hint_range(0.0, 1.0) = 0.266;

void fragment() {
    // Calculate normalized distance to control size
    float dist = distance(center * squishness, UV * squishness) / size;

    // Blend colors based on distance from center
    vec4 color = mix(color1, color2, smoothstep(step1, step2, dist));
    color = mix(color, color3, smoothstep(step2, step3, dist));
    color = mix(color, color4, smoothstep(step3, step4, dist));
    color = mix(color, color5, smoothstep(step4, step5, dist));
    color = mix(color, color6, smoothstep(step5, step6, dist));

    // Assign the result to COLOR; blend_add mode will brighten the underlying texture
    COLOR = color;
}
