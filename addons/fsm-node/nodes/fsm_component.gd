tool
extends Node

class_name FSM_Component

var active = false

# GRAPH
var position:= Vector2()

# SIGNALS
signal activate
signal deactivate

func _get_configuration_warning():
	return "This is a base class not intended to be used as a node."

func is_active():
	return active

func is_class(c):
	return c == get_class() or .is_class(c)
