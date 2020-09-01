tool
extends FSM_Component

class_name State, "icons/state.svg"

export(Array, NodePath) var transitions
var transition_nodes = []

func _get_configuration_warning():
	return "" if get_parent().get_class() == "FSM" else "Parent should be FSM."

func _ready():
	if !Engine.editor_hint:
		set_physics_process(false)
		set_process(false)
		set_process_input(false)
		
		for np in transitions:
			transition_nodes += [get_node(np)]

func get_class():
	return "State"

func set_active(b:bool):
	print(String(b), get_name())
	active = b
	
	set_physics_process(active)
	set_process(active)
	set_process_input(active)
	set_transitions()
	
	emit_signal("activate" if active else "deactivate")

func set_transitions():
	for t in transition_nodes:
		t.set_active(active)
