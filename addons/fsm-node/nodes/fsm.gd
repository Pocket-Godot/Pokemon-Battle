tool
extends Node

class_name FSM, "icons/fsm.svg"

var current_state
var state_tranistion_indexes
export(NodePath) var starting_state

# GRAPH
var associated_graph_edit
var connections = []

func _ready():
	
	# IF THIS IS CALLED IN THE EDITOR
	if Engine.editor_hint:
		
		# CONNECT EVERYTHING TOGETHER
		for c in connections:
			associated_graph_edit.connect_node(c["from"].get_name(), 0, c["to"].get_name(), 0)
		
		# CALL _ready() AGAIN FOR WHEN THE SCENE CHANGES
		request_ready()
	
	# IF THIS IS NOT CALLED IN THE EDITOR
	else:
		
		# IF THE starting_state IS DEFNIED, WE'LL USE IT
		if starting_state:
			current_state = get_node(starting_state)
			current_state.set_active(true)
	
		# OTHERWISE, WE'LL USE THE FIRST STATE IN OUR CHILDREN
		else:
			for c in get_children():
				if c.is_class("State"):
					current_state = c
					c.set_active(true)
					break

func _notification(what):
	if Engine.editor_hint:
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
		if c.is_class("State"):
			return ""
	return "Add at least one State to this node."
	
func activate_state(s):
	# SET STATE
	current_state = s
	current_state.set_active(true)

func change_state(s):
	deactivate_state()
	activate_state(s)

func deactivate_state():
	current_state.set_active(false)

func get_class():
	return "FSM"

func is_class(c):
	return c == get_class() or .is_class(c)

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
					var np_c = PoolStringArray(array_c).join("/")
					node_c = node_a.get_node(np_c)
					break
	
	var np_d = PoolStringArray(array_d).join("/")
	var node_d = node_a.get_node(np_d)
	return node_c.get_index() < node_d.get_index()
