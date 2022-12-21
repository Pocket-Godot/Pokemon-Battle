tool
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"
 # has an event_data variable that stores the current data!!!

 ## node references
 # e.g. 
onready var txt_targetanim = $VBoxContainer/HBoxContainer/InputField
onready var txt_effscene = $VBoxContainer/HBoxContainer2/InputField

const KEY_TARGETANIM = "target_anim"
const KEY_EFFSCENE = "effect_scene"

 # used to connect the signals
func _ready():
	# e.g. 
	txt_targetanim.connect("text_changed", self, "_on_InputField_text_changed", [KEY_TARGETANIM])
	txt_targetanim.connect("text_changed", self, "_on_InputField_text_changed", [KEY_EFFSCENE])

 # called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data. 
	# e.g. 
	if KEY_TARGETANIM in event_data:
		txt_targetanim.text = event_data[KEY_TARGETANIM]
	if KEY_EFFSCENE in event_data:
		txt_effscene.text = event_data[KEY_EFFSCENE]

 # has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

 ## EXAMPLE CHANGE IN ONE OF THE NODES
func _on_InputField_text_changed(text, key):
	event_data[key] = text
	
	# informs the parent about the changes!
	data_changed()
