extends State

export(NodePath) var np_associated_menu
export(NodePath) var np_focus_btn
var associated_menu
var focus_btn

func _ready():
	associated_menu = get_node(np_associated_menu)
	focus_btn = get_node(np_focus_btn)

func _activate():
	associated_menu.show()
	focus_btn.grab_focus()

func _deactivate():
	associated_menu.hide()
