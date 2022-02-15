extends Sprite

# Animation
export(Vector2) var proportional_offset setget set_proportional_offset
export(Vector2) var relative_forward
export(Vector2) var relative_backward
export(float) var relative_right

func set_proportional_offset(val:Vector2):
	var final_pos = Vector2(relative_right, 0) * val
	
	var new_propo_y = val.y
	if new_propo_y:
		if new_propo_y > 0:
			final_pos += relative_forward * new_propo_y
		else:
			final_pos += relative_backward * new_propo_y
		
	proportional_offset = val
