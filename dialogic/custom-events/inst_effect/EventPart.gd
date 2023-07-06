@tool
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"
 # has an event_data variable that stores the current data!!!

 ## node references
 # e.g. 
@onready var txt_effscene = $VBoxContainer/HBoxContainer/InputField
@onready var txt_tarray = $VBoxContainer/HBoxContainer2/InputField

const KEY_EFFSCENE = "effect_scene"
const KEY_TARGETARRAY = "target_array"

 # used to connect the signals
func _ready():
	# e.g. 
	txt_effscene.connect("text_changed", Callable(self, "_on_InputField_text_changed").bind(KEY_EFFSCENE))
	txt_tarray.connect("text_changed", Callable(self, "_on_InputField_text_changed").bind(KEY_TARGETARRAY))

 # called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	super.load_data(data)
	
	# Now update the ui nodes to display the data. 
	# e.g. 
	if KEY_EFFSCENE in event_data:
		txt_effscene.text = event_data[KEY_EFFSCENE]
	if KEY_TARGETARRAY in event_data:
		txt_tarray.text = event_data[KEY_TARGETARRAY]

 # has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

 ## EXAMPLE CHANGE IN ONE OF THE NODES
func _on_InputField_text_changed(text, key):
	event_data[key] = text
	
	# informs the parent about the changes!
	data_changed()
