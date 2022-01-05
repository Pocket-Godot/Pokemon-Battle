tool
extends State

var dialogic_node

func _activate():
	Dialogic.change_timeline('execute-move')

func _on_dialogic_node_added(nd):
	dialogic_node = nd
