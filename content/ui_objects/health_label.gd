extends Label

var cur_hp = 1
var max_hp = 1

func _on_bar_value_changed(value):
	cur_hp = value
	set_text_by_hp()

func _on_maxhp_is_set(value):
	max_hp = value

func set_text_by_hp():
	var final_string = String(cur_hp)
	final_string += "/"
	final_string += String(max_hp)
	
	set_text(final_string)
