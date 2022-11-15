shader_type spatial;

const float MAX_DISTANCE = 5.0;
const float MIN_DISTANCE = 0.0;

uniform float fox_distance:hint_range(0.0, 20.0) = 1.0;
uniform vec4 color:source_color;


void fragment() {
	// 0.0 for nearest (full color), 1.0 for furthest (no color)
	float desaturate_diff = (max(fox_distance - 5.0, 0.0) / MAX_DISTANCE);
	
	
	float r_modified = min(color.r + desaturate_diff, 1.0);
	float g_modified = min(color.g + desaturate_diff, 1.0);
	float b_modified = min(color.b + desaturate_diff, 1.0);
	
	ALBEDO = vec3(r_modified, g_modified, b_modified);
}
