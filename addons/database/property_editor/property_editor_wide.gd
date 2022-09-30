tool
extends VBoxContainer

class_name DataPropertyEditorWide

var property_name:String
var file_name:String
var tree_index = []

var resource_container
var editor_plugin
signal editor_plugin_is_set

var prev_val

func set_property(p):
	property_name = p["name"]
	$Name.set_text(property_name.capitalize())

func set_editor_plugin(node):
	editor_plugin = node
	emit_signal("editor_plugin_is_set")
