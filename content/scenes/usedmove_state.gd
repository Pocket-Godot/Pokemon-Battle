tool
extends State

var node_dialog

signal first_text_complete
var subturns = []
signal end_turn

# BATTLE ANIMATIONS

var action_sequences = []
var animplayer_pending = []
signal all_anims_finished

var targets = []
export(String, FILE, "*.tscn") var fp_hit_sprite
var damage
var hit_sprite

func _ready():
	hit_sprite = load(fp_hit_sprite)

func _activate():
	
	# ENEMY'S TURN
	var root_node = get_parent().get_parent()
	var foes_node = root_node.get_node("Foes")
	for f in foes_node.get_children():
		var enemy_turn = {
			"user": f,
			"targets": [root_node.get_node("Allies").get_child(0)]
		}
		
		subturns.append(enemy_turn)
		
	# DIALOGIC
	node_dialog.connect("text_complete", self, "_on_text_complete")
	
	next_subturn()

func _deactivate():
	node_dialog.disconnect("text_complete", self, "_on_text_complete")

func _on_dialogic_node_added(nd):
	node_dialog = nd.get_node("DialogNode")

func _on_text_complete(text_data):
	if text_data["event_id"] == "dialogic_001":
		Dialogic.next_event()

func next_subturn():
	var user_name = subturns[0]["user"].name
	Dialogic.set_variable("user_name", user_name)
	
	var target_name = subturns[0]["targets"][0].name
	Dialogic.set_variable("target_name", target_name)
	
	set_animations(subturns[0])
	Dialogic.change_timeline('execute-move')

# BATTLE ANIMATIONS

func set_animations(d:Dictionary):
	action_sequences = [
		{"anim_node": d["user"].get_node("AnimationPlayer"),
			"track": "Tackle"}]
			
	targets = d["targets"]
	
	damage = 5
	
	for a in action_sequences:
		var n = a["anim_node"]
		
		animplayer_pending.append(n)
		
		n.connect("next", self, "_anim_next")
		n.connect("animation_finished", self, "_anim_finished", [n])

func _anim_finished(_s, anim_player):
	anim_player.disconnect("next", self, "_anim_next")
	anim_player.disconnect("animation_finished", self, "_anim_finished")
	
	animplayer_pending.erase(anim_player)
	
	upon_empty_animation()

func _anim_next():
	action_sequences.remove(0)
	
	if action_sequences.size():
		play_car()
	elif damage:
		for t in targets:
			# HIT EFFECTS
			var inst_hitsprite = hit_sprite.instance()
			t.add_child(inst_hitsprite)
			
			var tanim_player = inst_hitsprite.get_node("AnimationPlayer")
			animplayer_pending.append(tanim_player)
			tanim_player.connect("animation_finished", self, "_hiteffect_finished", [tanim_player])
			tanim_player.play("Strike")
			
			# HEALTH BAR
			t.cur_hp -= damage
			
			var heath_bar = t.associated_bar
			var bar_tween = heath_bar.get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Health/Tween")
			animplayer_pending.append(bar_tween)
			bar_tween.connect("tween_all_completed", self, "_bar_completed", [bar_tween])

func _bar_completed(tween):
	tween.disconnect("tween_all_completed", self, "_bar_completed")
	
	animplayer_pending.erase(tween)
	
	upon_empty_animation()

func _hiteffect_finished(_s, hiteffect_player):
	hiteffect_player.disconnect("animation_finished", self, "_hiteffect_finished")
	
	animplayer_pending.erase(hiteffect_player)
	
	hiteffect_player.get_parent().queue_free()
	
	upon_empty_animation()
	
func upon_empty_animation():
	if animplayer_pending.empty():
		emit_signal("all_anims_finished")
		
func end_of_subturn():
		subturns.remove(0)
		
		if subturns.empty():
			Dialogic.change_timeline('battle-commands')
			emit_signal("end_turn")
		else:
			next_subturn()

func play_battle_animation():
	play_car()

func play_car():
	var action = action_sequences[0]
	
	action["anim_node"].play(action["track"])

func knock_outs():
	pass
