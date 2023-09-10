@tool
extends GraphNode

var associated_component:Node

func _on_dragged(_from, to):
	associated_component.position_offset = to


func set_associated_component(node):
	associated_component = node


## Visually indicates that the component is inherited via scene.
func set_inheritance():
	$Name.set_theme_type_variation("Inherited")


func set_comp_name(val):
	$Name.set_text(val)
