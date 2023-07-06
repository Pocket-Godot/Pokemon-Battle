@tool
extends LineEdit

var index

func _value(i, v):
	var index = i
	set_text(v)
	
	connect("text_changed", Callable(get_parent().get_parent(), "_on_value_changed").bind(i))
