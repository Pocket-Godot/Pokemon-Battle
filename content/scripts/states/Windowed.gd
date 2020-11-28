extends State

export (NodePath) var np_window
var window

func _activate():
	window.show()
	
func _deactivate():
	window.hide()
	
func _ready():
	._ready()
	
	if !Engine.editor_hint:
		window = get_node(np_window)
	
		connect("activate", self, "_activate")
		connect("deactivate", self, "_deactivate")
