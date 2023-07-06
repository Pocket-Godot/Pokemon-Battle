@tool
extends Sprite2D

var reserve_index := 0: set = set_reserve_index
var display_name
var species

# ANIMATIONS
@export var is_facing_front: bool
@export var proportional_offset: Vector2: set = set_proportional_offset
@export var relative_forward: Vector2: set = set_relative_forward
@export var relative_backward: Vector2: set = set_relative_backward
@export var relative_right: float: set = set_relative_right
var original_position:Vector2

#	MATERIALS
@export var glow_color : set = set_glow_color
@export var glow_extent: float: set = set_glow_extent

# MOVESETS
var moveset

# UI
@export var np_associated_bar: NodePath: set = set_np_associated_bar
var associated_bar

# BATTLE PARAMETERS
var max_hp:int: set = set_maxhp
signal maxhp_iset
var cur_hp:int: set = set_curhp
signal curhp_iset

func _ready():
	# UI
	set_associated_bar(get_node(np_associated_bar))

func _set(p, v):
	if p == "position":
		original_position = v
		update_position()

# SET PROPTERTIES
func set_reserve_index(v):
	reserve_index = v
	set_unit(v)
	
func set_unit(i):
	var unit = get_parent().units[i]
	
	species = unit["species"]
	display_name = species.get_name()
	associated_bar.set_name(display_name)
	Dialogic.set_variable("user_name", display_name)
	
	# ANIMATION
	var new_texture
	if is_facing_front:
		new_texture = species.front
	else:
		new_texture = species.back
	set_texture(new_texture)
	
	# MOVESET
	moveset = unit["moveset"]
	
	# BATTLE PARAMETERS
	set_maxhp(species.hp)
	set_curhp(unit["cur_hp"], true)

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

#	MATERIALS

func set_glow_color(val:Color):
	glow_color = val
	var v3 = Vector3(glow_color.r, glow_color.g, glow_color.b)
	get_material().set_shader_parameter("glow_color", v3)
	
func set_glow_extent(val:float):
	glow_extent = val
	get_material().set_shader_parameter("extent", glow_extent)

#	UI

func set_np_associated_bar(val:NodePath):
	np_associated_bar = val
	
	# If node is avaiable by the time the property is set
	if has_node(val):
		set_associated_bar(get_node(val))

func set_associated_bar(val):
	if associated_bar and !Engine.is_editor_hint():
		disconnect("maxhp_iset", Callable(associated_bar, "_maxhp_iset"))
		disconnect("curhp_iset", Callable(associated_bar, "_curhp_iset"))
	
	if val:
		associated_bar = val
		if !Engine.is_editor_hint():
			connect("maxhp_iset", Callable(associated_bar, "_maxhp_iset"))
			connect("curhp_iset", Callable(associated_bar, "_curhp_iset"))

#		HEALTH

func set_maxhp(val:int):
	max_hp = val
	if !Engine.is_editor_hint():
		emit_signal("maxhp_iset", val)

func set_curhp(val:int, instant:bool=false):
	cur_hp = val
	if !Engine.is_editor_hint():
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
