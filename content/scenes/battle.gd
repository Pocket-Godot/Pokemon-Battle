extends Node

func _ready():
	$UI_Layer/DialogNode.set_process_input(false)

func _on_dialog_completed():
	if $UI_Layer/DialogNode.current_event:
		pass
