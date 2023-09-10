@tool
@icon("icons/state.svg")
class_name State
extends FSM_Component
## A node representing one type of behavior that would be in effect when active.

## The list of Transitions it connects to.
@export var transitions: Array[Transition]

func _ready():
	super._ready()
	
	if !Engine.is_editor_hint():
		set_physics_process(false)
		set_process(false)
		set_process_input(false)


func _get_configuration_warning():
	return "" if get_parent().is_class("FSM") else "Parent should be FSM."


## Sets the state whether to be active.
func set_active(b:bool):
	active = b
	
	set_physics_process(active)
	set_process(active)
	set_process_input(active)
	set_transitions()
	
	emit_signal("activate" if active else "deactivate")


## Sets all transitions it's connected to whether to be active.
func set_transitions():
	for t in transitions:
		t.set_active(active)
