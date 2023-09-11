@tool
extends State

@export_file("*dtl") var target_timeline: String

func _activate():
	Dialogic.change_timeline(target_timeline)
