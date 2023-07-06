@tool
extends GraphNode

var associated_component:Node

func _on_dragged(_from, to):
	associated_component.graph_offset = to

func set_comp_name(val):
	$Name.set_text(val)

func set_associated_component(node):
	associated_component = node
