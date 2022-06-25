extends Node

## The timeline to load when starting the scene
export(String, "TimelineDropdown") var timeline: String
var dialogic_node
signal dialogic_node_added

signal move_selected

signal end_turn

func _ready():
	dialogic_node = Dialogic.start(timeline)
	add_child(dialogic_node)
	move_child(dialogic_node, get_child_count() - 2)
	dialogic_node.set_process_input(false)
	emit_signal("dialogic_node_added", dialogic_node)
	
	#CONNECT MOVES
	for i in 4:
		get_node("UI_Layer/MarginContainer/Moves/List/Move" + String(i+1) + "/Button").connect("pressed", self, "_on_move_btn_pressed", [i])

func _on_move_btn_pressed(i:int):
	
	# PLAYER'S TURN
	var player_turn = {
		"user": $Allies.get_child(0),
		"targets": [$Foes/Foe]
	}
	
	$FSM/UsedMove.subturns.append(player_turn)
	
	emit_signal("move_selected")
