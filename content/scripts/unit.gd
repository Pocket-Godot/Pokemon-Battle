tool
extends Sprite

export(Resource) var species

# ANIMATIONS
export(bool) var is_facing_front
export(Vector2) var proportional_offset setget set_proportional_offset
export(Vector2) var relative_forward setget set_relative_forward
export(Vector2) var relative_backward setget set_relative_backward
export(float) var relative_right setget set_relative_right
var original_position:Vector2

# MOVESETS
var moveset = []

# UI
export(NodePath) var np_associated_bar setget set_np_associated_bar
var associated_bar

# BATTLE PARAMETERS
var max_hp:int setget set_maxhp
signal maxhp_iset
var cur_hp:int setget set_curhp
signal curhp_iset

func _ready():
	# ANIMATION
	var new_texture
	if is_facing_front:
		new_texture = species.front
	else:
		new_texture = species.back
	set_texture(new_texture)
	
	# MOVESET
	var moves = [species.move1, species.move2, species.move3, species.move4]
	for m in moves:
		var dict
		if m:
			dict = {"move": m,
				"pp": m.power_points}
		else:
			dict = {"move": null}
		moveset.append(dict)
	
	# UI
	set_associated_bar(get_node(np_associated_bar))
	
	# BATTLE PARAMETERS
	set_maxhp(species.hp)
	set_curhp(max_hp, true)

func _set(p, v):
	if p == "position":
		original_position = v
		update_position()

# SET PROPTERTIES
#	ANIMATION

func set_proportional_offset(val:Vector2):
	proportional_offset = val
	update_position()

func set_relative_forward(val:Vector2):
	relative_forward = val
	update_position()
	
func set_relative_backward(val:Vector2):
	relative_backward = val
	update_position()
	
func set_relative_right(val:float):
	relative_right = val
	update_position()

#	UI

func set_np_associated_bar(val:NodePath):
	np_associated_bar = val
	
	# If node is avaiable by the time the property is set
	if has_node(val):
		set_associated_bar(get_node(val))

func set_associated_bar(val):
	if associated_bar and !Engine.editor_hint:
		disconnect("maxhp_iset", associated_bar, "_maxhp_iset")
		disconnect("curhp_iset", associated_bar, "_curhp_iset")
	
	if val:
		associated_bar = val
		if !Engine.editor_hint:
			var unit_name = species.get_name()
			associated_bar.set_name(unit_name)
			connect("maxhp_iset", associated_bar, "_maxhp_iset")
			connect("curhp_iset", associated_bar, "_curhp_iset")

#	BATTLE ANIMATIONS

func set_maxhp(val:int):
	max_hp = val
	if !Engine.editor_hint:
		emit_signal("maxhp_iset", val)

func set_curhp(val:int, instant:bool=false):
	cur_hp = val
	if !Engine.editor_hint:
		emit_signal("curhp_iset", val, instant)

# METHODS
	
func update_position():
	var final_pos = Vector2(relative_right, 0) * proportional_offset
	
	var new_propo_y = proportional_offset.y
	if new_propo_y:
		if new_propo_y > 0:
			final_pos += relative_forward * new_propo_y
		else:
			final_pos -= relative_backward * new_propo_y
	
	position = original_position + final_pos
