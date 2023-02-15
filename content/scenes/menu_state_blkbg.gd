tool
extends MenuState

class_name MenuStateBlkBg

onready var shadow_bg = get_node("%ShadowBg")

func _activate():
	shadow_bg.show()
	._activate()

func _deactivate():
	._deactivate()
	shadow_bg.hide()
