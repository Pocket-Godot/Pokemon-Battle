tool
extends Sprite

# Animation
export(Vector2) var proportional_offset setget set_proportional_offset
export(Vector2) var relative_forward setget set_relative_forward
export(Vector2) var relative_backward setget set_relative_backward
export(float) var relative_right setget set_relative_right
var original_position:Vector2

func _set(p, v):
	if p == "position":
		original_position = v
		update_position()
	
func update_position():
	var final_pos = Vector2(relative_right, 0) * proportional_offset
	
	var new_propo_y = proportional_offset.y
	if new_propo_y:
		if new_propo_y > 0:
			final_pos += relative_forward * new_propo_y
		else:
			final_pos -= relative_backward * new_propo_y
	
	position = original_position + final_pos

func set_proportional_offset(val:Vector2):
	proportional_offset = val
	update_position()

func set_relative_forward(val:Vector2):
	relative_forward = val
	update_position()
	
func  set_relative_backward(val:Vector2):
	relative_backward = val
	update_position()
	
func  set_relative_right(val:float):
	relative_right = val
	update_position()
