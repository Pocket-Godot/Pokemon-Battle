tool
extends State

var dialogic_node

func _activate():
	print("E")
	dialogic_node.queue_free()
	dialogic_node = Dialogic.start('execute-move')
	add_child(dialogic_node)

func _on_dialogic_node_added(nd):
	dialogic_node = nd
