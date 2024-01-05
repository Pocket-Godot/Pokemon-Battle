@tool
extends GraphEdit

const CONNECT_FROM := "from"
const CONNECT_TO := "to"

const PCONNECT_COMP := "graph_comp"
const PCONNECT_ISFROM := "is_from"
const PCONNECT_SNAP := "snap"

@export_group("Connection Lines")
@export_color_no_alpha var line_color: Color
@export var arrow_head: Texture2D

var editor_interface

var associated_fsm: FSM

var comp_connections = []
var pending_connection = {}

func _draw():
	for c in comp_connections:
		var from_graph = c[CONNECT_FROM]
		
		var from = from_graph.position_offset * zoom - scroll_offset
		var to = c[CONNECT_TO].position_offset * zoom - scroll_offset
		
		draw_line(from, to, line_color, get_connection_lines_thickness())
		
		# For drawing arrowhead, rotation from offset is required
		if from_graph is GraphTransition:
			var arrow_pos = to
			var angle = from.angle_to_point(to)
			var backtrack = c[CONNECT_TO].radius
			arrow_pos -= Vector2(backtrack, 0).rotated(angle)
			draw_arrowhead(arrow_pos, angle)
	
	if pending_connection:
		var target_pos: Vector2
		if pending_connection[PCONNECT_SNAP]:
			target_pos = pending_connection[PCONNECT_SNAP].get_position()
		else:
			target_pos = get_local_mouse_position()
		
		var from_pos: Vector2
		var to_pos: Vector2
		
		if pending_connection[PCONNECT_ISFROM]:
			from_pos = pending_connection[PCONNECT_COMP].position_offset * zoom - scroll_offset
			to_pos = target_pos
		else:
			from_pos = target_pos
			to_pos = pending_connection[PCONNECT_COMP].position_offset * zoom - scroll_offset
		
		draw_line(from_pos, to_pos, line_color, get_connection_lines_thickness())
		
		if pending_connection[PCONNECT_ISFROM]:
			if pending_connection[PCONNECT_COMP] is GraphTransition:
				draw_arrowhead(to_pos, from_pos.angle_to_point(to_pos))
		else:
			if pending_connection[PCONNECT_COMP] is GraphState:
				var angle = from_pos.angle_to_point(to_pos)
				var pos = to_pos - Vector2(pending_connection[PCONNECT_COMP].radius, 0).rotated(angle)
				draw_arrowhead(pos, angle)


func _gui_input(event):
	if pending_connection:
		if event is InputEventMouseButton:
			if event.is_released() and event.get_button_index() == MOUSE_BUTTON_LEFT:
				if pending_connection[PCONNECT_SNAP]:
					var dict = {}
					
					if pending_connection[PCONNECT_ISFROM]:
						dict = {
								CONNECT_FROM: pending_connection[PCONNECT_COMP],
								CONNECT_TO: pending_connection[PCONNECT_SNAP],
							}
					else:
						dict = {
								CONNECT_FROM: pending_connection[PCONNECT_SNAP],
								CONNECT_TO: pending_connection[PCONNECT_COMP],
							}
					
					for c in comp_connections:
						if c == dict:
							pending_connection.clear()
							queue_redraw()
							return
						elif c[CONNECT_FROM] == dict[CONNECT_FROM] or (c[CONNECT_TO] == dict[CONNECT_TO] and not c[CONNECT_TO] is GraphTransition):
							remove_connection(c)
					
					add_new_connection(dict)
				
				pending_connection.clear()
				queue_redraw()
		
		elif event is InputEventMouseMotion:
			if pending_connection:
				for c in get_children():
					if c != pending_connection[PCONNECT_COMP] and c._has_point(event.get_position() - c.position_offset):
						pending_connection[PCONNECT_SNAP] = c
						queue_redraw()
						return
				
				pending_connection[PCONNECT_SNAP] = null
				queue_redraw()


func add_new_connection(dict):
	var from_comp = dict[CONNECT_FROM].associated_component
	var to_comp = dict[CONNECT_TO].associated_component
	
	if from_comp is State:
		from_comp.transitions.append(to_comp)
	else:
		from_comp.target_state = to_comp
	editor_interface.mark_scene_as_unsaved()
	from_comp.notify_property_list_changed()
	
	comp_connections.append(dict)


func add_title_label(s: String):
	var fsm_title = Label.new()
	fsm_title.set_text(s)
	get_menu_hbox().add_child(fsm_title)
	get_menu_hbox().move_child(fsm_title, 0)


func connect_comp_nodes(connections: Array):
	comp_connections = []
	
	for c in connections:
		var dict = {
				CONNECT_FROM: c[CONNECT_FROM].associated_graph_node,
				CONNECT_TO: c[CONNECT_TO].associated_graph_node,
			}
		
		comp_connections.append(dict)


func draw_arrowhead(pos: Vector2, angle: float):
	var offset = arrow_head.get_size() * Vector2(1, 0.5)
	var final_pos = pos - offset.rotated(angle)
	draw_set_transform(final_pos, angle, Vector2.ONE)
	draw_texture(arrow_head, Vector2.ZERO, line_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func remove_comp_from_connections(g:CompGraphElement, is_from:bool):
	var key_side: String
	if is_from:
		key_side = CONNECT_FROM
	else:
		key_side = CONNECT_TO
	
	for c in comp_connections:
		if c[key_side] == g:
			comp_connections.erase(c)
			break
	
	queue_redraw()


func remove_connection(dict):
	var from_comp = dict[CONNECT_FROM].associated_component
	var to_comp = dict[CONNECT_TO].associated_component
	
	if from_comp is State:
		from_comp.transitions.erase(to_comp)
	else:
		from_comp.target_state = null
	
	editor_interface.mark_scene_as_unsaved()
	from_comp.notify_property_list_changed()
	
	comp_connections.erase(dict)


func set_associated_fsm(node):
	associated_fsm = node


func start_pending_connection(graph_ele: CompGraphElement, is_from: bool):
	pending_connection = {
			PCONNECT_COMP: graph_ele,
			PCONNECT_ISFROM: is_from,
			PCONNECT_SNAP: null,
		}


func start_pending_connection_from_disconnecting_right(graph_ele: GraphElement):
	for c in comp_connections:
		if c[CONNECT_FROM] == graph_ele:
			remove_connection(c)
			start_pending_connection(c[CONNECT_TO], false)
			queue_redraw()
			return
	
	start_pending_connection(graph_ele, true)
