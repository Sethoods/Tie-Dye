shader_type canvas_item;

uniform vec4 primary_color : source_color;
uniform vec4 secondary_color : source_color;
uniform float strength : hint_range(0.0, 1.0) = 1.0; // Simple hash noise for per-pixel offsets
uniform float onetwo = 1.0;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float brightness = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

	if (brightness > 0.1) { // Moving boundary position
		float front = fract(TIME); // Per-pixel offset so the boundary wiggles
		float offset = hash(UV * front) * 0.2; // Compare pixel position to boundary
		float t = fract(UV.y + offset*1.5);
		float edge = 0.05;
		float mask = smoothstep(front - edge, front + edge, t); // Choose color based on mask
		if (UV.y > 0.5){
			vec3 col = mix(primary_color.rgb, secondary_color.rgb, mask);

		    tex.rgb = mix(tex.rgb, col * brightness, strength);
		}else{
						vec3 col = mix(secondary_color.rgb, primary_color.rgb, mask);

		    tex.rgb = mix(tex.rgb, col * brightness, strength);
		}

		}
		COLOR = tex;
}