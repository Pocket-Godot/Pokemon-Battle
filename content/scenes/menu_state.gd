@tool
extends State

class_name MenuState

@export var associated_menu: Control
@export var focus_btn: Control

func _activate():
	associated_menu.show()
	focus_btn.grab_focus()


func _deactivate():
	associated_menu.hide()
