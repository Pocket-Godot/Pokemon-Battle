@tool
extends ColorPickerButton

var index

func _value(i, v):
	var index = i
	set_pick_color(v)
	
	connect("color_changed", Callable(get_parent().get_parent(), "_on_value_changed").bind(i))
