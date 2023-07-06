@tool
extends GridContainer

var data_type
var property_hint
var hint_string

@export var dir_subprop # (String, DIR)
var pkscn_subprop

var current_value
signal list_changed

var add_item = Button.new()
var default_value

func list_items(val):
	current_value = val
	
	if val:
		if data_type == TYPE_DICTIONARY:
			for k in val.keys():
				var item = pkscn_subprop.instantiate()
				add_child(item)
				item.set_item(k, val[k], self)
		else:
			for i in val.size():
				var item = pkscn_subprop.instantiate()
				add_child(item)
				item.set_item(i, val[i], self)
	
	add_child(add_item)
	add_item.set_h_size_flags(SIZE_EXPAND_FILL)
	add_item.connect("pressed", Callable(self, "_on_additem_pressed"))

func set_datatype(type, hint, h_string):
	data_type = type
	property_hint = hint
	hint_string = h_string
	
	var fp_subprop = dir_subprop
	# property_hint: int
	##	0: no further export hints
	##	26: float, String etc
	
	# hint_string: String
	## "2:" int
	## "3:" float
	## "4:" String
	if data_type == TYPE_DICTIONARY:
		fp_subprop += "/DictionaryItem.tscn"
		
		add_item.set_text("Add Pair")
	else:
		fp_subprop += "/ArrayItem"
		if property_hint:
			match hint_string:
				"2:":
					fp_subprop += "Int"
					default_value = 0
				"3:":
					fp_subprop += "Float"
					default_value = 0.0
				"4:":
					fp_subprop += "String"
					default_value = ""
				"5:":
					fp_subprop += "ColorAlpha"
					default_value = Color()
		else:
			fp_subprop += "Var"
		fp_subprop += ".tscn"
		
		add_item.set_text("Add Item")
	
	pkscn_subprop = load(fp_subprop)

# SIGNALS FROM INPUT

func _on_additem_pressed():
	var item = pkscn_subprop.instantiate()
	add_child(item)
	var index = item.get_position_in_parent() - 1
	move_child(item, index)
	
	if current_value is Dictionary:
		var new_key = "key_" + String(index)
		item.set_item(new_key, default_value, self)
		current_value[new_key] = default_value
	else:
		item.set_item(index, default_value, self)
		current_value.append(default_value)
	
	emit_signal("list_changed", current_value)

func _on_value_changed(v, i, a = current_value):
	a[i] = v
	
	emit_signal("list_changed", current_value)
	
func _on_key_changed(new_k, prev_k, a = current_value):
	var v = a[prev_k]
	a.erase(prev_k)
	a[new_k] = v
	
	emit_signal("list_changed", current_value)
