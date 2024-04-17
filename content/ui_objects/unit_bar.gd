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
		tween.interpolate_property(%Health, "value", %Health.get_value(), val, 1.0)
		
		tween.start()


func set_display_name(s):
	%Name.set_text(s)
