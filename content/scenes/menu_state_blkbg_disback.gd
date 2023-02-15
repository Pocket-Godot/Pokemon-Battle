tool
extends MenuStateBlkBg

export(NodePath) var np_backbtn
var backbtn

func _ready():
	backbtn = get_node(np_backbtn)
	._ready()

func _activate():
	np_backbtn.set_disable(true)
	._activate()

func _deactivate():
	._deactivate()
	np_backbtn.set_disable(false)
