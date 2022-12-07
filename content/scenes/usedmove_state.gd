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
var knockedout_targets = []
signal you_lose
signal foe_loses

func _ready():
	hit_sprite = load(fp_hit_sprite)

func _activate():
	
	# ENEMY'S TURN
	var root_node = get_parent().get_parent()
	var foes_node = root_node.get_node("Foes")
	for f in foes_node.get_children():
		var enemy_turn = {
			"user": f,
			"move": f.moveset[0]["move"],
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

# TURNS

func next_subturn():
	var user_name = subturns[0]["user"].name
	Dialogic.set_variable("user_name", user_name)
	
	var move_name = subturns[0]["move"].get_name()
	Dialogic.set_variable("move_name", move_name)
	
	var target_name = subturns[0]["targets"][0].name
	Dialogic.set_variable("target_name", target_name)
	
	set_move_animations(subturns[0])
	Dialogic.change_timeline('execute-move')
		
func end_of_subturn():
	subturns.remove(0)
	
	if subturns.empty():
		Dialogic.change_timeline('battle-commands')
		emit_signal("end_turn")
	else:
		next_subturn()

# BATTLE ANIMATIONS

func set_move_animations(d:Dictionary):
	var move = d["move"]
	var base_power = move.base_power
			
	targets = d["targets"]
	
	action_sequences = [
		{"anim_node": d["user"].get_node("AnimationPlayer"),
			"track": "Tackle"}]
	
	damage = base_power
	
	connect_within_action_sequences()
	
func connect_within_action_sequences():
	for a in action_sequences:
		var n = a["anim_node"]
		
		animplayer_pending.append(n)
		
		n.connect("next", self, "_move_anim_next")
		n.connect("animation_finished", self, "_move_anim_finished", [n])

func _move_anim_finished(_s, anim_player):
	anim_player.disconnect("next", self, "_move_anim_next")
	anim_player.disconnect("animation_finished", self, "_move_anim_finished")
	
	animplayer_pending.erase(anim_player)
	
	upon_empty_animation()

func _move_anim_next():
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
			
			# KNOCK OUTS
			if t.cur_hp <= 0:
				knockedout_targets.append(t)
				
		if knockedout_targets.size():
			var knockedout_names = PoolStringArray([])
			
			for t in knockedout_targets:
				knockedout_names.append(t.name)
				
			var str_knockedout_names = knockedout_names.join(", ")
			Dialogic.set_variable("knock_outs", str_knockedout_names)

func _bar_completed(tween):
	tween.disconnect("tween_all_completed", self, "_bar_completed")
	
	animplayer_pending.erase(tween)
	
	upon_empty_animation()

func _hiteffect_finished(_s, hiteffect_player):
	hiteffect_player.disconnect("animation_finished", self, "_hiteffect_finished")
	
	animplayer_pending.erase(hiteffect_player)
	
	hiteffect_player.get_parent().queue_free()
	
	upon_empty_animation()

func play_battle_animation():
	play_car()

func play_car():
	var action = action_sequences[0]
	
	action["anim_node"].play(action["track"])
	
func upon_empty_animation():
	if animplayer_pending.empty():
		emit_signal("all_anims_finished")
		
func play_knockout_animation():
	# SETTING UP
	for t in knockedout_targets:
		var action = {
			"anim_node": t.get_node("AnimationPlayer"),
			"track": "Faint"
		}
		
		action_sequences.append(action)
	
		# REMOVE SUBTURNS WHERE THE USER IS THE FAINTED
		for s in subturns:
			if s['user'] == t:
				subturns.erase(s)
	
	damage = 0
	
	connect_within_action_sequences()
	
	play_car()

func upon_no_more_reserves():
	if get_node("../../Allies/You").cur_hp <= 0:
		emit_signal("you_lose")
	elif get_node("../../Foes/Foe").cur_hp <= 0:
		emit_signal("foe_loses")
