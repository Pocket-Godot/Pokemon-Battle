@tool
extends OptionButton

var option_values = []

func add_options(hint_string, hint_type, value):
	var arr_hints = hint_string.split(",")
	
	if hint_type == TYPE_STRING:
		for i in arr_hints.size():
			var s = arr_hints[i]
			add_item(s)
			option_values.append(s)
			
			if value and s == value:
				select(i)
		
	elif ":" in arr_hints[0]:
		for i in arr_hints.size():
			var s = arr_hints[i]
			var inner_arr = s.split(":")
			add_item(inner_arr[0])
			
			var val = int(inner_arr[1])
			option_values.append(val)
			
			if value and val == value:
				select(i)
		
	else:
		for i in arr_hints.size():
			add_item(arr_hints[i])
			option_values.append(i)
			
		if value:
			select(value)
