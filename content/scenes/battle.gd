extends Node

@onready var fsm_dialog_turn = $FSM/DialogTurn

var moves_list
signal move_selected

@onready var ally_list = $Allies.species

@onready var ally_battlebars = $UI_Layer/MarginContainer/StatusBars/VBoxContainer/Allies

signal end_turn

func _on_move_btn_pressed(i:int):

	# PLAYER'S TURN
	var player = $Allies.get_child(0)
	var player_turn = {
		"user": player,
		"timeline": "execute-move",
		"move_index": i,
		"targets": [$Foes/Foe]
	}
	
	fsm_dialog_turn.subturns.append(player_turn)
	
	emit_signal("move_selected")


func _on_switch_popmenu_pressed(item_i, unit_i):
	match item_i:
		1:	# SWITCH IN
			match $FSM.current_state.get_name():
				"SwitchOutKoed":
					print(90)
				_:
					var player = $Allies.get_child(0)
					var player_turn = {
						"user": player,
						"timeline": "we-switch",
						"reserve_index": unit_i,
					}
			
					fsm_dialog_turn.subturns.append(player_turn)
			
					emit_signal("move_selected")
		
		_:	# CHECK SUMMARY
			pass

func connect_to_reserve(u, i):
	# u CAN BE THE INDEX OR THE UNIT RESERVE BAR ITSELF
	var unit_reserve
	if u is int:
		unit_reserve = $UI_Layer/ShadowBg/Switch/VBoxContainer.get_child(u)
	else:
		unit_reserve = u
	
	# i CAN BE THE INDEX OR THE BATTLE BAR ITSELF
	var battlebar
	if i is int:
		battlebar = ally_battlebars.get_child(i)
	else:
		battlebar = i
	
	var battlebar_tween = battlebar.get_hpbar_tween()
	battlebar_tween.connect("tween_completed", Callable(unit_reserve, "_on_hp_tween_completed"))

func disconnect_from_reserve(i:int, j):
	var unit_reserve = $UI_Layer/ShadowBg/Switch/VBoxContainer.get_child(i)
	
	# i CAN BE THE INDEX OR THE BATTLE BAR ITSELF
	var battlebar
	if j is int:
		battlebar = ally_battlebars.get_child(j)
	else:
		battlebar = j
	
	var battlebar_tween = battlebar.get_hpbar_tween()
	
	battlebar_tween.disconnect("tween_completed", Callable(unit_reserve, "_on_hp_tween_completed"))
