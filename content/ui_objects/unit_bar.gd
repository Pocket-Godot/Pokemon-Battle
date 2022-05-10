extends MarginContainer

func _maxhp_iset(val:int):
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Health.set_max(val) 

func _curhp_iset(val:int, instant:bool=false):
	if instant:
		$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Health.set_value(val)
