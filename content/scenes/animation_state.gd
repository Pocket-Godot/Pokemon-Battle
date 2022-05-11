tool
extends State

var action_sequences = []
var animplayer_pending = []
signal animplayer_cleared

var targets = []
export(String, FILE, "*.tscn") var fp_hit_sprite
var hit_sprite

func _ready():
	action_sequences = [
		{"anim_node": get_node("../../Allies/You/AnimationPlayer"),
			"track": "Tackle"}]
			
	hit_sprite = load(fp_hit_sprite)

func _activate():
	for a in action_sequences:
		var n = a["anim_node"]
		
		animplayer_pending.append(n)
		
		n.connect("next", self, "_anim_next")
		n.connect("animation_finished", self, "_anim_finished", [n])
	
	targets = [get_node("../../Foes/Foe")]
	
	play_car()

func _anim_finished(_s, anim_player):
	anim_player.disconnect("next", self, "_anim_next")
	anim_player.disconnect("animation_finished", self, "_anim_finished")
	
	animplayer_pending.erase(anim_player)
	
	is_animplayer_empty()

func _anim_next():
	action_sequences.remove(0)
	
	if action_sequences.size():
		play_car()
	else:
		for t in targets:
			# HIT EFFECTS
			var inst_hitsprite = hit_sprite.instance()
			t.add_child(inst_hitsprite)
			
			var tanim_player = inst_hitsprite.get_node("AnimationPlayer")
			animplayer_pending.append(tanim_player)
			tanim_player.connect("animation_finished", self, "_hiteffect_finished", [tanim_player])
			tanim_player.play("Strike")
			
			# HEALTH BAR
			t.cur_hp -= 5
			
			var heath_bar = t.associated_bar
			var bar_tween = heath_bar.get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Health/Tween")
			animplayer_pending.append(bar_tween)
			bar_tween.connect("tween_all_completed", self, "_bar_completed", [bar_tween])

func _bar_completed(tween):
	tween.disconnect("tween_all_completed", self, "_bar_completed")
	
	animplayer_pending.erase(tween)
	
	is_animplayer_empty()

func _hiteffect_finished(_s, hiteffect_player):
	hiteffect_player.disconnect("animation_finished", self, "_hiteffect_finished")
	
	animplayer_pending.erase(hiteffect_player)
	
	hiteffect_player.get_parent().queue_free()
	
	is_animplayer_empty()
	
func is_animplayer_empty():
	if animplayer_pending.empty():
		emit_signal("animplayer_cleared")

func play_car():
	var action = action_sequences[0]
	
	action["anim_node"].play(action["track"])
