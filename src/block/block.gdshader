shader_type spatial;

const float MAX_DISTANCE = 5.0;
const float MIN_DISTANCE = 0.0;

uniform float player_distance:hint_range(0.0, 20.0) = 1.0;
uniform vec4 color:source_color;

// Add shape for normalmap
uniform sampler2D shape_texture : repeat_disable;
uniform vec2 shape_scale = vec2(2.0, 2.0);
uniform vec2 shape_offset = vec2(-0.5, -0.5);


void fragment() {
	// 0.0 for nearest (full color), 1.0 for furthest (no color)
	float desaturate_diff = (max(player_distance - 5.0, 0.0) / MAX_DISTANCE);
	float shape_y = texture(shape_texture, (UV * shape_scale) + shape_offset).y;
	
	float r_modified = min(color.r + desaturate_diff, 1.0) * shape_y;
	float g_modified = min(color.g + desaturate_diff, 1.0) * shape_y;
	float b_modified = min(color.b + desaturate_diff, 1.0) * shape_y;
	
	ALBEDO = vec3(r_modified, g_modified, b_modified);
	//NORMAL_MAP.y = 
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
}
