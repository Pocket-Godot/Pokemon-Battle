@tool
class_name FSM_Component
extends Node
## A node representing one part of an FSM system. It is to be a child of an FSM node.
##
## In the FSM workspace, it is represented by a [GraphNode].

## If [code]true[/code], this component, as a [State], is active. [br]
## For a [Transition], it depends on the [param active] property of the [State] connected to it.
var active = false

## Emmited when [param active] becomes true.
signal activate

## Emmited when [param active] becomes false.
signal deactivate

@export_group("Graph Workspace")
## The position of this component in the FSM workspace.
@export var graph_offset: Vector2
## The [GraphNode] representing this componenet in the FSM workspace.
var associated_graph_node

func _ready():
	if !Engine.is_editor_hint():
		activate.connect(_activate)
		deactivate.connect(_deactivate)


func is_inherted():
	var node = self
	var file_path = get_scene_file_path()
	while file_path == "":
		node = node.get_parent()
			
		if node == get_tree().get_edited_scene_root():
			var initial_file_path = node.get_scene_file_path()
			var packed_scene = load(initial_file_path)
			var inst = packed_scene.get_state().get_node_instance(0)
			if inst:
				file_path = inst.get_path()
			break
		else:
			file_path = node.get_scene_file_path()
	
	if file_path:
		var node_path = NodePath("./" + str(node.get_path_to(self)))
		var packed_scene = load(file_path)
		var ps_node_count = packed_scene.get_state().get_node_count()
		for i in range(ps_node_count):
			if node_path == packed_scene.get_state().get_node_path(i):
				print("This node is inherited")
				break


func _get_configuration_warning():
	return "This is a base class not intended to be used as a node."


func _activate():
	pass


func _deactivate():
	pass


## Returns whether this component is active.
func is_active()-> bool:
	return active
