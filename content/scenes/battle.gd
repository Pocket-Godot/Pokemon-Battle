extends Node

onready var fsm_usedmove = $FSM/UsedMove

## The timeline to load when starting the scene
export(String, "TimelineDropdown") var timeline: String
var dialogic_node
signal dialogic_node_added

var moves_list
signal move_selected

onready var ally_list = $Allies.species

signal end_turn

func _ready():
	dialogic_node = Dialogic.start(timeline)
	add_child(dialogic_node)
	move_child(dialogic_node, get_child_count() - 2)
	dialogic_node.set_process_input(false)
	emit_signal("dialogic_node_added", dialogic_node)
	
	#CONNECT MOVES
	moves_list = $UI_Layer/MarginContainer/Moves/List
	for i in range(1, moves_list.get_child_count()):
		var move_btn = moves_list.get_child(i).get_child(0)
		move_btn.connect("pressed", self, "_on_move_btn_pressed", [i-1])
	
	var moveset = $Allies/You.moveset
	update_moves_list(moveset)
	
	var ally_indexes = []
	for n in $Allies.get_children():
		ally_indexes.append(n.reserve_index)
	
	# SWITCHING
	for i in ally_list.size():
		var unit_reserve = $UI_Layer/ShadowBg/Switch/VBoxContainer.get_child(i)
		unit_reserve.set_data(ally_list[i])
		unit_reserve.get_node("PopupMenu").connect("index_pressed", self, "_on_switch_popmenu_pressed", [i])
		
		for j in ally_indexes:
			if j == i:
				unit_reserve.disable_switch_option()
				ally_indexes.erase(j)
				break

func _on_commands_activated():
	if $Allies/You.moveset:
		var moveset = $Allies/You.moveset
		update_moves_list(moveset)

func _on_move_btn_pressed(i:int):

	# PLAYER'S TURN
	var player = $Allies.get_child(0)
	var player_turn = {
		"user": player,
		"timeline": "execute-move",
		"move_index": i,
		"targets": [$Foes/Foe]
	}
	
	fsm_usedmove.subturns.append(player_turn)
	
	emit_signal("move_selected")
	
func _on_switch_popmenu_pressed(item_i, unit_i):
	match item_i:
		1:	# SWITCH IN
			var player = $Allies.get_child(0)
			var player_turn = {
				"user": player,
				"timeline": "we-switch",
				"reserve_index": unit_i,
			}
	
			fsm_usedmove.subturns.append(player_turn)
	
			emit_signal("move_selected")
		
		_:	# CHECK SUMMARY
			pass

func update_moves_list(moveset):
	for i in range(1, moves_list.get_child_count()):
		var move_btn = moves_list.get_child(i)
		
		var h = i-1
		var dict_move = moveset[h]
		var move = dict_move["move"]
		if move == null:
			move_btn.hide()
		else:
			move_btn.show()
			move_btn.update_movedata(move)
			
			var cur_pp = dict_move["pp"]
			move_btn.update_power_points(cur_pp, move.power_points)
			move_btn.get_node("Button").set_disabled(cur_pp <= 0)
