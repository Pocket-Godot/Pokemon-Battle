@tool
class_name CompGraphElement extends GraphElement

const THEME_TYPE = "CompGraphElement"

var associated_component: FSM_Component

var comp_name: String
var is_inherited: bool

var hover_over_connection: bool:
	set(val):
		get_material().set_shader_parameter("hover", val)
		hover_over_connection = val

var connection_is_right: bool:
	set(val):
		get_material().set_shader_parameter("is_right", val)
		connection_is_right = val

var current_state: int

var dragg_offset: Vector2

func _draw():
	var font = get_theme_font("font")
	var str_size = font.get_string_size(comp_name, HORIZONTAL_ALIGNMENT_CENTER)
	
	draw_frame(str_size)
	
	var str_pos = str_size / Vector2(-2, 4)
	var font_color
	if is_inherited:
		font_color = get_theme_color("font_inherited", THEME_TYPE)
	else:
		font_color = Color.WHITE
	draw_string(font, str_pos, comp_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, font_color)


func _gui_input(event):
	if get_parent() is GraphEdit and event is InputEventMouseButton and event.is_pressed():
		match event.get_button_index():
			MOUSE_BUTTON_LEFT:
				if hover_over_connection:
					if get_parent().is_right_disconnects_enabled() and connection_is_right:
						get_parent().start_pending_connection_from_disconnecting_right(self)
					else:
						get_parent().start_pending_connection(self, connection_is_right)
					
					accept_event()
			
			#MOUSE_BUTTON_RIGHT:
			#	if hover_over_connection:
			#		get_parent().remove_comp_from_connections(self, connection_is_right)


func _on_position_offset_changed():
	associated_component.graph_offset = position_offset


## Override
func draw_frame(size):
	pass


func get_border_color():
	if is_selected():
		return get_theme_color("border_selected", THEME_TYPE)
	else:
		return get_theme_color("border", THEME_TYPE)


func set_associated_component(node):
	associated_component = node


## Visually indicates that the component is inherited via scene.
func set_inheritance():
	$Name.set_theme_type_variation("Inherited")


func set_comp_name(val):
	comp_name = val


func set_hover(b: bool):
	hover_over_connection = b


func set_connection_is_right(b: bool):
	connection_is_right = b
