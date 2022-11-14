shader_type spatial;

const float MAX_DISTANCE = 10.0;
const float MIN_DISTANCE = 0.0;

uniform float spirit_distance:hint_range(0.0, 10.0) = 1.0;
uniform vec4 color:source_color;


void fragment() {
	// 0.0 for nearest (full color), 1.0 for furthest (no color)
	float desaturate_diff = spirit_distance / MAX_DISTANCE;
	
	float r_modified = color.r + desaturate_diff;
	float g_modified = color.g + desaturate_diff;
	float b_modified = color.b + desaturate_diff;
	
	ALBEDO = vec3(r_modified, g_modified, b_modified);
}
