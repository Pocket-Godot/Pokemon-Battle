@tool
extends MenuState

class_name MenuStateBlkBg

@onready var shadow_bg = get_node("%ShadowBg")

func _activate():
	shadow_bg.show()
	super._activate()

func _deactivate():
	super._deactivate()
	shadow_bg.hide()
