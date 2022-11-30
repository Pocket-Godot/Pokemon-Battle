extends MarginContainer

onready var label_name = $MarginContainer/HBoxContainer/Name
onready var label_type = $MarginContainer/HBoxContainer/Type
onready var label_category = $MarginContainer/HBoxContainer/Category
onready var label_pp = $MarginContainer/HBoxContainer/PP

func update_movedata(move):
	var move_name = move.get_name()
	label_name.set_text(move_name)
	
	var type_name = move.type.get_key().capitalize()
	label_type.set_text(type_name)

func update_power_points(current, max_pp):
	var str_pp = String(current) + "/" + String(max_pp)
	label_pp.set_text(str_pp)
