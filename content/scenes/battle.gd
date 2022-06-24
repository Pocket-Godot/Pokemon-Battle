extends Node

## The timeline to load when starting the scene
export(String, "TimelineDropdown") var timeline: String
var dialogic_node
signal dialogic_node_added

signal move_selected

var subturns = []
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

func _allanim_cleared():
	subturns.remove(0)
	
	if subturns.empty():
		emit_signal("end_turn")
	else:
		next_subturn()

func _on_move_btn_pressed(i:int):
	
	# PLAYER'S TURN
	var player_turn = {
		"user": get_node("Allies").get_child(0),
		"targets": [get_node("Foes/Foe")]
	}
	
	subturns.append(player_turn)
	
	# ENEMY'S TURN
	for f in get_node("Foes").get_children():
		var enemy_turn = {
			"user": f,
			"targets": [get_node("Allies").get_child(0)]
		}
		
		subturns.append(enemy_turn)
		
	next_subturn()

func next_subturn():
	var user_name = subturns[0]["user"].name
	Dialogic.set_variable("user_name", user_name)
	
	$FSM/Animation.set_animations(subturns[0])
	
	emit_signal("move_selected")
