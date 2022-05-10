tool
extends State

var action_sequences = []
var animplayer_pending = []
signal animplayer_cleared

func _ready():
	action_sequences = [
		{"anim_node": get_node("../../Allies/You/AnimationPlayer"),
			"track": "Tackle"},
		{"anim_node": get_node("../../Foes/Foe/Hit/AnimationPlayer"),
			"track": "Through"}]

func _activate():
	for a in action_sequences:
		var n = a["anim_node"]
		
		animplayer_pending.append(n)
		
		n.connect("next", self, "_anim_next")
		n.connect("animation_finished", self, "_anim_finished", [n])
	
	play_car()

func _anim_finished(anim_player):
	anim_player.disconnect("next", self, "_anim_next")
	anim_player.disconnect("animation_finished", self, "_anim_finished")
	
	animplayer_pending.erase(anim_player)
	
	if animplayer_pending.empty():
		emit_signal("animplayer_cleared")

func _anim_next():
	action_sequences.remove(0)
	
	if action_sequences.size():
		play_car()
		
func play_car():
	var action = action_sequences[0]
	
	action["anim_node"].play(action["track"])
