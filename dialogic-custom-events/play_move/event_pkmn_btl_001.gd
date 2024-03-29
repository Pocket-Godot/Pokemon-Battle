extends Node

var state_dialog_turn
var associated_dialognode

func _ready():
	state_dialog_turn = get_node("/root/Battle/FSM/DialogTurn")

func handle_event(event_data, dialog_node):
	""" 
		If this event should wait for dialog advance to occur, uncomment the WAITING line
		If this event should wait for the user to pick a choice, uncomment the WAITINT_INPUT line
		While other states exist, they generally are not neccesary, but include IDLE, TYPING, and ANIMATING
	"""
	#dialog_node.set_state(dialog_node.state.WAITING)
	#dialog_node.set_state(dialog_node.state.WAITING_INPUT)
	
	#pass # fill with event action
	associated_dialognode = dialog_node
	
	state_dialog_turn.connect("all_anims_finished", Callable(self, "_all_anims_finished"))
	state_dialog_turn.play_battle_animation()
	
func _all_anims_finished():
	# once you want to continue with the next event
	state_dialog_turn.disconnect("all_anims_finished", Callable(self, "_all_anims_finished"))
	
	associated_dialognode._load_next_event()
	associated_dialognode.set_state(associated_dialognode.state.READY)
