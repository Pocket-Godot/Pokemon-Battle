tool
extends State

export(String) var target_timeline = "you-win"

func _activate():
	Dialogic.change_timeline(target_timeline)
