@tool
extends State

@export var target_timeline: String = "you-win"

func _activate():
	Dialogic.change_timeline(target_timeline)
