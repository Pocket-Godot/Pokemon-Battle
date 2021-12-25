extends Node

## The timeline to load when starting the scene
export(String, "TimelineDropdown") var timeline: String
var dialogic_node

func _ready():
	dialogic_node = Dialogic.start(timeline)
	add_child(dialogic_node)
	move_child(dialogic_node, get_child_count() - 2)
	dialogic_node.set_process_input(false)
	
	#CONNECT MOVES
	for i in 4:
		get_node("UI_Layer/MarginContainer/Moves/List/Move" + String(i+1) + "/Button").connect("pressed", self, "_on_move_btn_pressed", [i])

func _on_dialog_completed():
	if dialogic_node.current_event:
		pass

func _on_move_btn_pressed(i:int):
	print(i)
