shader_type canvas_item;

uniform vec4 fill_color : source_color;
uniform float strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Keep outlines (dark pixels)
    float brightness = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    // Only recolor pixels above a brightness threshold (your gray fill)
    if (brightness > 0.1) {
        tex.rgb = mix(tex.rgb, fill_color.rgb * brightness, strength);
    }

    COLOR = tex;
}
