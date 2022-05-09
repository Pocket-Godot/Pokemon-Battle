extends AnimationPlayer

signal next

const ANIM_NONE = "None"

func _finished(anim_name):
	if anim_name != ANIM_NONE:
		play(ANIM_NONE)
