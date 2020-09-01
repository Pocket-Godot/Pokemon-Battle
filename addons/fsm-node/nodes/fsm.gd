tool
extends Node

class_name FSM, "icons/fsm.svg"

var current_state
var state_tranistion_indexes

func _ready():
	if !Engine.editor_hint:
		for c in get_children():
			if c.get_class() == "State":
				current_state = c
				c.set_active(true)
				break

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
