extends Button

@export var label_name: Label
@export var label_type: Label
@export var label_category: Label
@export var label_pp: Label

func update_movedata(move):
	var move_name = move.get_name()
	label_name.set_text(move_name)
	
	var type_name = move.type.get_key().capitalize()
	label_type.set_text(type_name)

func update_power_points(current, max_pp):
	var str_pp = String(current) + "/" + String(max_pp)
	label_pp.set_text(str_pp)
