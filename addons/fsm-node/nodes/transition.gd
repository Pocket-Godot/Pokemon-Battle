@tool
@icon("icons/transition.svg")
class_name Transition
extends FSM_Component
## A node that determines when to change state.

## The State to change to when condition is met.
@export var target_state: State

## An array of dictionaries, each recording an incoming signal.
## All of them will be disconnected first, only to be connected
## as long as the transition is active.
var incoming_signals

func _ready():
	super._ready()
	
	if !Engine.is_editor_hint():
		
		# SIGNALS
		incoming_signals = get_incoming_connections()
		set_active(false)


func _get_configuration_warning():
	return "" if get_parent().is_class("FSM") else "Parent should be FSM."


## To recieve a signal that should be emmited when the state is to be changed.
func _condition():
	get_parent().change_state(target_state)


## (Dis)connects all incoming signals depending on the activation of the state(s) connected to it.
func set_active(b:bool):
	if b:
		for d in incoming_signals:
			d["signal"].connect(d["callable"])
	else:
		for d in incoming_signals:
			d["signal"].disconnect(d["callable"])
