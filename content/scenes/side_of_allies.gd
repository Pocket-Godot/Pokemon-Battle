extends UnitSide

func _ready():
	super._ready()
	
	# COMMANDS
	for n in get_children():
		n.associated_bar.update_commands(n)
