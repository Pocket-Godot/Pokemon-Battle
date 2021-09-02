tool
extends FSM_Component

class_name Transition, "icons/transition.svg"

export (NodePath) var target_state
var target_state_node
var incoming_signals

func _condition():
	get_parent().change_state(target_state_node)

func _get_configuration_warning():
	return "" if get_parent().is_class("FSM") else "Parent should be FSM."

func _ready():
	._ready()
	
	if !Engine.editor_hint:
		# TARGET STATE
		target_state_node = get_node(target_state)
		
		# SIGNALS
		incoming_signals = get_incoming_connections()
		set_active(false)

func get_class():
	return "Transition"

func is_class(c):
	return c == get_class() or .is_class(c)

func set_active(b:bool):
	if b:
		for d in incoming_signals:
			d["source"].connect(d["signal_name"], self, d["method_name"])
	else:
		for d in incoming_signals:
			d["source"].disconnect(d["signal_name"], self, d["method_name"])
