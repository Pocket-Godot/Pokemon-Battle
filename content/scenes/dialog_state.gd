tool
extends State

var node_dialog

signal first_text_complete

func _activate():
	node_dialog.connect("text_complete", self, "_on_text_complete")
	Dialogic.change_timeline('execute-move')

func _deactivate():
	node_dialog.disconnect("text_complete", self, "_on_text_complete")

func _on_dialogic_node_added(nd):
	node_dialog = nd.get_node("DialogNode")

func _on_text_complete(text_data):
	if text_data["event_id"] == "dialogic_001":
		emit_signal("first_text_complete")
