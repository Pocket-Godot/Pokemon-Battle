tool
extends SpinBox

var index

func _value(i, v):
	var index = i
	set_value(v)
	
	connect("value_changed", get_parent().get_parent(), "_on_value_changed", [i])
