tool
extends HBoxContainer

signal listgrid
signal key
signal value

func set_item(key, value, listgrid):
	emit_signal("listgrid", listgrid)
	emit_signal("key", key)
	emit_signal("value", key, value)

func _on_key_changed(v, _i, _a = null):
	$Value.set_index(v)
