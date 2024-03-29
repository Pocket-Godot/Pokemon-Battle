extends MarginContainer

signal maxhp_is_set

func _maxhp_iset(val:int):
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Health.set_max(val)
	emit_signal("maxhp_is_set", val)


func _curhp_iset(val:int, instant:bool=false):
	var bar = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Health
	
	if instant:
		bar.set_value(val)
	else:
		var tween = create_tween()
		tween.interpolate_property(bar, "value", bar.get_value(), val, 1.0)
		
		tween.start()


func set_display_name(s):
	$PanelContainer/MarginContainer/VBoxContainer/HBox/Name.set_text(s)
