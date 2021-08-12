extends Node

enum STATES {COMMANDS, MOVES, TARGET, EXECUTION}
var state = STATES.COMMANDS

func _ready():
	$UI_Layer/DialogNode.set_process_input(false)
	
	activate_state(state)

func activate_state(s):
	match s:
		STATES.COMMANDS:
			$UI_Layer/MarginContainer/Commands.show()
			$UI_Layer/MarginContainer/Commands/Fight.grab_focus()
		STATES.MOVES:
			$UI_Layer/MarginContainer/Moves.show()
			$UI_Layer/MarginContainer/Moves/List/Move1/Button.grab_focus()

func change_state(s):
	deactivate_state(state)
	state = s
	activate_state(state)

func deactivate_state(s):
	match s:
		STATES.COMMANDS:
			$UI_Layer/MarginContainer/Commands.hide()
		STATES.MOVES:
			$UI_Layer/MarginContainer/Moves.hide()

func _command_fight():
	change_state(STATES.MOVES)

func _move_back():
	change_state(STATES.COMMANDS)

func _on_dialog_completed():
	if $UI_Layer/DialogNode.current_event:
		pass
