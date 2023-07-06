@tool
extends HBoxContainer

signal listgrid
signal value

func set_item(i, val, lg):
	emit_signal("listgrid", lg)
	
	$Index.set_text(String(i))
	emit_signal("value", i, val)
