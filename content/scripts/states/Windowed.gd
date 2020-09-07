extends State

export (NodePath) var np_window
var window

func _activate():
	window.show()
	
func _deactivate():
	window.hide()
	
func _ready():
	window = get_node(np_window)
	
	connect("activate", self, "_activate")
	connect("deactivate", self, "_deactivate")
