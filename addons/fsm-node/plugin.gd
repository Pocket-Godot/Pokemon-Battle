@tool
extends EditorPlugin

var editor_interface
var editor_selection

var scenedock_tree

var MainPanel = preload("main_screen/MainPanel.tscn")
var main_panel_instance

var behind_popup
var PopupNewState = preload("res://addons/fsm-node/popups/NewState.tscn")
var PopupNewTransition = preload("res://addons/fsm-node/popups/NewTransition.tscn")
var popup_new_state
var popup_new_transition
var new_offset
var parent_fsm
var new_connection = {}
signal new_comp

var current_root_node: Node
var current_node_paths
var graph_fsm_edit_root
var GraphFsmEdit = preload("main_screen/GraphFSMEdit.tscn")
var GraphNodes = {
		"state": preload("main_screen/graph_nodes/GraphState.tscn"),
		"transition":  preload("main_screen/graph_nodes/GraphTransition.tscn")
	}

var toolbar_btns:Dictionary
var toolbar_btns_pressed_methods:Dictionary
var tool_mode
enum {TOOL_SELECT, TOOL_MOVE}
var select_state:bool = true
var select_transition:bool = true

func _enter_tree():
	editor_interface = get_editor_interface()
	editor_selection = editor_interface.get_selection()
	editor_selection.selection_changed.connect(Callable(self, "_on_selection_changed"))
	
	var scenedock = editor_interface.get_base_control().find_children("Scene", "SceneTreeDock", true, false)[0]
	scenedock_tree = scenedock.find_children("*", "Tree", true, false)[0]
	
	# Set up Main Screen
	main_panel_instance = MainPanel.instantiate()
	editor_interface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)
	
	# Set up Toolbars
	#	Get Buttons
	toolbar_btns = {
		"select": main_panel_instance.get_node("MarginContainer/HBoxContainer/HBoxContainer/Select"),
		"move": main_panel_instance.get_node("MarginContainer/HBoxContainer/HBoxContainer/Move"),
		"state":  main_panel_instance.get_node("MarginContainer/HBoxContainer/HBoxContainer2/State"),
		"transition":  main_panel_instance.get_node("MarginContainer/HBoxContainer/HBoxContainer2/Transition"),
		"addstate": main_panel_instance.get_node("MarginContainer/HBoxContainer/HBoxContainer3/AddState"),
		"addtransition": main_panel_instance.get_node("MarginContainer/HBoxContainer/HBoxContainer3/AddTransition"),
		"remove": main_panel_instance.get_node("MarginContainer/HBoxContainer/HBoxContainer3/Remove")
	}
	
	#	Reuse Godot Icons
	toolbar_btns["select"].set_button_icon(editor_interface.get_base_control().get_theme_icon("ToolSelect", "EditorIcons"))
	toolbar_btns["move"].set_button_icon(editor_interface.get_base_control().get_theme_icon("ToolMove", "EditorIcons"))
	toolbar_btns["remove"].set_button_icon(editor_interface.get_base_control().get_theme_icon("Remove", "EditorIcons"))
	
	#	Define Press Methods
	toolbar_btns_pressed_methods = {
		"select": "_on_select_pressed",
		"move": "_on_move_pressed",
		"state": "_on_state_pressed",
		"transition": "_on_transition_pressed",
		"addstate": "_on_addstate_pressed",
		"addtransition": "_on_addtransition_pressed",
		"remove": "_on_remove_pressed"
	}
	
	#	Connect Signals
	for k in toolbar_btns.keys():
		toolbar_btns[k].pressed.connect(Callable(self, toolbar_btns_pressed_methods[k]))
	
	# Add Popup Dialogs
	behind_popup = get_script_create_dialog().get_parent()
	popup_new_state = PopupNewState.instantiate()
	behind_popup.add_child(popup_new_state)
	popup_new_state.confirmed.connect(_make_new_state)
	popup_new_transition = PopupNewTransition.instantiate()
	behind_popup.add_child(popup_new_transition)
	popup_new_transition.confirmed.connect(_make_new_transition)
	
	# Graphworks
	graph_fsm_edit_root = main_panel_instance.get_node("ScrollContainer/VBoxContainer")
	get_tree().node_added.connect(_on_node_added_to_tree)
	get_tree().node_removed.connect(_on_node_removed_from_tree)
	get_tree().node_renamed.connect(_on_node_in_tree_renamed)


func _exit_tree():
	
	# REMOVE POPUP DIALOGS
	popup_new_transition.queue_free()
	popup_new_state.queue_free()
	
	# DISCONNECT SIGNALS
	for k in toolbar_btns.keys():
		toolbar_btns[k].pressed.disconnect(Callable(self, toolbar_btns_pressed_methods[k]))
	
	toolbar_btns = {}
	
	# REMOVE MAIN PANEL
	if main_panel_instance:
		main_panel_instance.queue_free()
	
	editor_selection.selection_changed.disconnect(_on_selection_changed)


func _get_plugin_icon():
	return preload("main_screen/icon.svg")


func _get_plugin_name():
	return "FSM"


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


# TOOLBAR BUTTON FUNCTIONS
func _on_selection_changed():
	for n in editor_selection.get_selected_nodes():
		if n is FSM:
			parent_fsm = n
			set_add_component_disabled(false)
			editor_interface.set_main_screen_editor("FSM")
			toolbar_btns["remove"].set_disabled(true)
			return
		elif n is FSM_Component:
			parent_fsm = n.get_parent()
			set_add_component_disabled(false)
			toolbar_btns["remove"].set_disabled(false)
			return
	
	set_add_component_disabled(true)
	toolbar_btns["remove"].set_disabled(true)


func _on_select_pressed():
	tool_mode = TOOL_SELECT


func _on_move_pressed():
	tool_mode = TOOL_MOVE


func _on_state_pressed(b):
	select_state = b


func _on_transition_pressed(b):
	select_transition = b


func _on_addstate_pressed():
	popup_new_state.popup_centered()


func _on_addtransition_pressed():
	popup_new_transition.popup_centered()


func _on_remove_pressed():
	for n in editor_selection.get_selected_nodes():
		if n is FSM_Component:
			n.queue_free()


func _make_new_state():
	# Generate New Node
	var inst_state = State.new()
	make_new_comp(inst_state, popup_new_state)


func _make_new_transition():
	# Instantiate New Node
	var inst_transition = Transition.new()
	make_new_comp(inst_transition, popup_new_transition)


func make_new_comp(inst_comp, popup_new_comp):
	#	Node Name
	var nd_input = popup_new_comp.find_node("Name")
	var new_name = nd_input.get_text()
	if new_name:
		inst_comp.set_name(new_name)
		new_connection["new"] = new_name
		
		# Clear Input
		nd_input.clear()
		
	#	Set Offset
	if new_offset:
		inst_comp.graph_offset = new_offset
		new_offset = Vector2()
	
	parent_fsm.add_child(inst_comp)
	inst_comp.set_owner(get_tree().get_edited_scene_root())
	new_comp.emit()


func set_add_component_disabled(b:bool):
	toolbar_btns["addstate"].set_disabled(b)
	toolbar_btns["addtransition"].set_disabled(b)


# Graphworks
func _on_node_added_to_tree(node):
	if node == get_tree().get_edited_scene_root():
		current_root_node = node
	
		var file_path = node.get_scene_file_path()
		var packed_scene = load(file_path)
		current_node_paths = packed_scene._bundled["node_paths"]
	
	if node is FSM:
		# Add new FSM Graph
		var gfe_instance = GraphFsmEdit.instantiate()
		graph_fsm_edit_root.add_child(gfe_instance)
		node.associated_graph_edit = gfe_instance
		gfe_instance.set_associated_fsm(node)
		gfe_instance.editor_interface = editor_interface
		
		gfe_instance.add_title_label(node.get_name())
		
		# Connect Signals
		gfe_instance.gui_input.connect(_on_fsm_input.bind(gfe_instance))
		gfe_instance.connection_from_empty.connect(_on_connect_from_empty.bind(gfe_instance))
		gfe_instance.connection_to_empty.connect(_on_connect_to_empty.bind(gfe_instance))
	
	elif node is FSM_Component:
		var parent = node.get_parent()
		if parent is FSM:
			var gfe = parent.associated_graph_edit
			
			# Adding Graph Node
			var is_state = node is State
			var state_key = "state" if is_state else "transition"
			var graph_node = GraphNodes[state_key].instantiate()
			gfe.add_child(graph_node)
			node.associated_graph_node = graph_node
			graph_node.set_associated_component(node)
			
			# Set Graph Node
			graph_node.set_position_offset(node.graph_offset)
			graph_node.set_comp_name(node.get_name())
			
			# Connections
			if is_state:
				if node.transitions:
					for t in node.transitions:
						parent.add_connection({"from": node, "to": t})
				
			else:
				if node.target_state:
					parent.add_connection({"from": node, "to": node.target_state})
			
			# Inheritance
			var node_path_array = get_nodepath_in_array(node)
			var root_item = scenedock_tree.get_root()
			if root_item:
				var tree_item = get_treeitem_from_nodepath(root_item, node_path_array)
				if tree_item:
					if tree_item.get_custom_color(0) == Color(1, 0.87, 0.4, 1):
						graph_node.set_inheritance()


func _on_node_removed_from_tree(node):
	if node is FSM:
		var gfe = node.associated_graph_edit
		graph_fsm_edit_root.remove_child(gfe)
		gfe.queue_free()
		
	elif node is FSM_Component:
		# Disconnect from other Comp Elements
		var parent = node.get_parent()
		var graph_node = node.associated_graph_node
		
		if parent is FSM:
			var erase_in_arr = []
			
			for c in parent.connections:
				if c["from"] == graph_node or c["to"] == graph_node:
					erase_in_arr.append(c)
			
			for d in erase_in_arr:
				parent.connections.erase(d)
		
		graph_node.queue_free()


func _on_node_in_tree_renamed(node):
	if node is FSM:
		node.associated_graph_edit.title.set_text(node.get_name())
		
	elif node is FSM_Component:
		node.associated_graph_node.set_comp_name(node.get_name())


func get_nodepath_in_array(base_node: Node)-> PackedStringArray:
	var node_path = current_root_node.get_path_to(base_node)
	var np_str = String(node_path)
	var np_array = np_str.split("/")
	return np_array


func get_treeitem_from_nodepath(base_item:TreeItem, array_node: PackedStringArray)-> TreeItem:
	var tree_item = base_item
	
	while tree_item != null:
		if tree_item.get_text(0) == array_node[0]:
			if array_node.size() == 1:
				return tree_item
			else:
				array_node.slice(1)
				tree_item = tree_item.get_next_in_tree()
		else:
			tree_item = tree_item.get_next()
	
	return null


# INTERFACE INTERACTIONS
func _cancel_node_connection():
	clear_new_connection()


func _connect_new_to_old():
	parent_fsm.associated_graph_edit.connect_node(new_connection["new"], 0, new_connection["old"], 0)
	clear_new_connection()


func _connect_old_to_new():
	parent_fsm.associated_graph_edit.connect_node(new_connection["old"], 0, new_connection["new"], 0)
	clear_new_connection()


func _on_connect_from_empty(from, _fr_sl, release_pos, fg):
	empty_connect(from, release_pos, fg, true)


func _on_connect_to_empty(from, _fr_sl, release_pos, fg):
	empty_connect(from, release_pos, fg, false)


func _on_fsm_input(event, fg):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			new_offset = event.get_position()
			parent_fsm = fg.associated_fsm
			popup_new_state.popup_centered()


func clear_new_connection():
	new_comp.disconnect(Callable(self, new_connection["method"]))
	new_connection["popup"].get_cancel().pressed.disconnect(_cancel_node_connection)
	
	new_connection.clear()


func empty_connect(port, release_pos, fg, is_from):
	# GET NEW OFFSET
	new_offset = release_pos
	parent_fsm = fg.associated_fsm
	
	if parent_fsm.get_node(port) is State:
		new_connection["popup"] = popup_new_transition
	else:
		new_connection["popup"] = popup_new_state
	
	new_connection["method"] = "_connect_new_to_old" if is_from else "_connect_old_to_new"
	
	new_connection["old"] = port
	
	new_connection["popup"].popup_centered()
	new_comp.connect(Callable(self, new_connection["method"]))
	new_connection["popup"].get_cancel().pressed.connect(Callable(self, "_cancel_node_connection"))
