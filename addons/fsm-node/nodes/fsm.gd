@tool
@icon("icons/fsm.svg")
class_name FSM
extends Node
## A node that manages which State is to be active. Has [FSM_Component]s as its children nodes.
##
## In the FSM workspace, it is represented as a [GraphEdit], showing all its FSM component children and their relations.

var current_state
var state_tranistion_indexes

# For Graph Workspace
var associated_graph_edit: GraphEdit
var connections = []

## The State it starts with when the project is played. If not set, it will instead start with the first child State.
@export var starting_state: State

func _ready():
	
	# If called in the Editor
	if Engine.is_editor_hint():
		
		associated_graph_edit.connect_comp_nodes(connections)
		
		# To call _ready() again when the scene changes
		request_ready()
	
	# Otherwise
	else:
		
		if starting_state:
			current_state = starting_state
			current_state.set_active(true)
	
		# If starting_state is undefined, set it as
		# the first State child. 
		else:
			for c in get_children():
				if c is State:
					current_state = c
					c.set_active(true)
					break


func _notification(what):
	if Engine.is_editor_hint():
		match what:
			
			NOTIFICATION_MOVED_IN_PARENT:
					
				# REARRANGE PLACEMENT
				#	IF IT HAS GRAPHEDIT COUNTERPART
				if associated_graph_edit:
					var selfgraph_indx = associated_graph_edit.get_index()
					if selfgraph_indx > 0:
						var countdown_start = selfgraph_indx - 1
						var target_indx = selfgraph_indx
						var graph_fsm_edit_root = associated_graph_edit.get_parent()
						for i in range(countdown_start, -1, -1):
							var compared_node = graph_fsm_edit_root.get_child(i).associated_fsm
							if node_is_higher(self, compared_node):
								target_indx = i
							else:
								break
						if target_indx != selfgraph_indx:
							graph_fsm_edit_root.move_child(associated_graph_edit, target_indx)


func _get_configuration_warning():
	# to get called by update_configuration_warning() when there's a change in tree
	for c in get_children():
		if c is State:
			return ""
	return "Add at least one State to this node."


## Activates a state. 
func activate_state(s):
	current_state = s
	current_state.set_active(true)


func add_connection(c: Dictionary):
	if not c in connections:
		connections.append(c)


## Changes from one state to another.
func change_state(s):
	deactivate_state()
	activate_state(s)


## Deactivates the current state.
func deactivate_state():
	current_state.set_active(false)


func get_class():
	return "FSM"


func is_class(c):
	return c == get_class() or super.is_class(c)


func node_is_higher(node_a, node_b):
	var rel_path = node_a.get_path_to(node_b)
	var count = rel_path.get_name_count()
	var array_d = []
	var node_c
	
	for i in count:
		var n = rel_path.get_name(i)
		array_d += [n]
		
		if n == "..":
			# IF IT'S THE LAST ELEMENT OF THE LIST
			if i == count - 1:
				# NODE B MUST BE THE (GRAND)PARENT OF NODE A
				return false
		else:
			match i:
				0:
					# NODE B MUST BE THE (GRAND)CHILD OF NODE A
					return true
				1:
					# B OR ITS (GRAND)PARENT MUST BE THE SIBLING OF A
					node_c = node_a
					break
				_:
					# FIND THE HIGHEST PARENT WHERE THEY ARE SIBLINGS TO BE COMPARED TO
					var array_c = array_d.slice(0, array_d.size() - 3)
					var np_c = "/".join(PackedStringArray(array_c))
					node_c = node_a.get_node(np_c)
					break
	
	var np_d = "/".join(PackedStringArray(array_d))
	var node_d = node_a.get_node(np_d)
	return node_c.get_index() < node_d.get_index()
