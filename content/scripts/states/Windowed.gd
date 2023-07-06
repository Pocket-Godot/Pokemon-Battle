extends State

@export var np_window: NodePath
var window

func _activate():
	window.show()
	
func _deactivate():
	window.hide()
	
func _ready():
	super._ready()
	
	if !Engine.is_editor_hint():
		window = get_node(np_window)
	
		connect("activate", Callable(self, "_activate"))
		connect("deactivate", Callable(self, "_deactivate"))
