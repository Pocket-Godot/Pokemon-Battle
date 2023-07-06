@tool
extends MenuStateBlkBg

@export var np_backbtn: NodePath
var backbtn

func _ready():
	backbtn = get_node(np_backbtn)
	super._ready()

func _activate():
	backbtn.set_disabled(true)
	super._activate()

func _deactivate():
	super._deactivate()
	backbtn.set_disabled(false)
