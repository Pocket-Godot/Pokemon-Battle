shader_type canvas_item;

varying vec2 vertex_pos;

uniform sampler2D gradient;
uniform bool hover;
uniform float left;
uniform float diameter;
uniform bool is_right;

void vertex(){
	vertex_pos = VERTEX;
}

void fragment(){
	if (COLOR.rgb == vec3(0)) {
		if (hover) {
			float pos_x = vertex_pos.x;
			if (!is_right){
				pos_x *= -1.0;
			}
			pos_x -= left;
			pos_x /= diameter;
			COLOR = texture(gradient, vec2(pos_x, 0));
		} else {
			COLOR = texture(gradient, vec2(0));
		}
	}
}
