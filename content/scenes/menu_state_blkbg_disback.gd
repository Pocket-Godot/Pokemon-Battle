tool
extends MenuStateBlkBg

export(NodePath) var np_backbtn
var backbtn

func _ready():
	backbtn = get_node(np_backbtn)
	._ready()

func _activate():
	backbtn.set_disabled(true)
	._activate()

func _deactivate():
	._deactivate()
	backbtn.set_disabled(false)
