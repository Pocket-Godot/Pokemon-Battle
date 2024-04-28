extends Marker2D

signal maxhp_is_set

func _maxhp_iset(val:int):
	%Health.set_max(val)
	emit_signal("maxhp_is_set", val)


func _curhp_iset(val:int, instant:bool=false):
	if instant:
		%Health.set_value(val)
	else:
		var tween = create_tween()
		tween.tween_property(%Health, "value", val, 1.0)
		
		tween.play()


func set_display_name(s):
	%Name.set_text(s)


func update_commands(n: Sprite2D):
	update_moveset(n.moveset)


func update_moveset(moveset):
	for i in range(1, $Moves.get_child_count()):
		var move_btn = $Moves.get_child(i)
		
		var h = i - 1
		var dict_move = moveset[h]
		var move = dict_move["move"]
		if move == null:
			move_btn.hide()
		else:
			move_btn.show()
			var button = move_btn.get_node("Button")
			button.update_movedata(move)
			
			var cur_pp = dict_move["pp"]
			button.update_power_points(cur_pp, move.power_points)
			button.set_disabled(cur_pp <= 0)
