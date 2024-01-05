shader_type canvas_item;

varying vec2 vertex_pos;

uniform sampler2D gradient;
uniform bool hover;
uniform bool is_right;
uniform float left;
uniform float right;
uniform float side_width;

void vertex(){
	vertex_pos = VERTEX;
}

void fragment() {
	if (COLOR.rgb == vec3(0)) {
		if (hover) {
			if (is_right) {
				if (vertex_pos.x <= right) {
					COLOR = texture(gradient, vec2(0));
				} else {
					float pos_x = vertex_pos.x;
					pos_x -= right;
					pos_x /= side_width;
					COLOR = texture(gradient, vec2(pos_x, 0));
				}
			} else {
				if (vertex_pos.x >= left) {
					COLOR = texture(gradient, vec2(0));
				} else {
					float pos_x = vertex_pos.x;
					pos_x *= -1.0;
					pos_x -= right;
					pos_x /= side_width;
					COLOR = texture(gradient, vec2(pos_x, 0));
				}
			}
		} else {
			COLOR = texture(gradient, vec2(0));
		}
	}
}
