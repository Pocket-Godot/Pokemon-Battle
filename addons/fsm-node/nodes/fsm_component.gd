@tool
extends Node

class_name FSM_Component

var active = false

# GRAPH
@export var graph_offset: Vector2
var associated_graph_node

# SIGNALS
signal activate
signal deactivate

func _activate():
	pass

func _deactivate():
	pass

func _get_configuration_warnings():
	return "This is a base class not intended to be used as a node."

func _ready():
	if !Engine.is_editor_hint():
		connect("activate", Callable(self, "_activate"))
		connect("deactivate", Callable(self, "_deactivate"))

func get_class():
	return "FSM_Component"

func is_active():
	return active

func is_class(c):
	return c == get_class() or super.is_class(c)
