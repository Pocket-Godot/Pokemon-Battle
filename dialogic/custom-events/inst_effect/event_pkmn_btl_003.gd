extends Node

var state_tousedmove
var associated_dialognode

func _ready():
	state_tousedmove = get_node("/root/Node/FSM/UsedMove")

func handle_event(event_data, dialog_node):
	""" 
		If this event should wait for dialog advance to occur, uncomment the WAITING line
		If this event should wait for the user to pick a choice, uncomment the WAITINT_INPUT line
		While other states exist, they generally are not neccesary, but include IDLE, TYPING, and ANIMATING
	"""
	#dialog_node.set_state(dialog_node.state.WAITING)
	#dialog_node.set_state(dialog_node.state.WAITING_INPUT)
	
	#pass # fill with event action
	var anim_name = event_data["target_anim"]
	
	associated_dialognode = dialog_node
	state_tousedmove.connect("all_anims_finished", self, "_all_anims_finished")
	
	state_tousedmove.play_animations(anim_name)
	
func _all_anims_finished():
	# once you want to continue with the next event
	state_tousedmove.disconnect("all_anims_finished", self, "_all_anims_finished")
	
	associated_dialognode._load_next_event()
	associated_dialognode.set_state(associated_dialognode.state.READY)
