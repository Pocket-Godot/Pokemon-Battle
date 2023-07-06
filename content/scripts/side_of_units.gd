extends Node2D

@export var species: Array[Resource]
var units = []

func _ready():
	for r in species:
		var dict = {
			"species": r,
			"cur_hp": r.hp
		}
		
		# MOVESET
		var moveset = []
		var moves = [r.move1, r.move2, r.move3, r.move4]
		for m in moves:
			var dict_m
			if m:
				dict_m = {"move": m,
					"pp": m.power_points}
					
				if m.type.fp_hit_effect:
					dict_m["hit_effect"] = load(m.type.fp_hit_effect)
			else:
				dict_m = {"move": null}
			moveset.append(dict_m)
		dict["moveset"] = moveset
		
		units.append(dict)
		
	for i in get_child_count():
		get_child(i).set_unit(i)

func some_units_are_koed()->bool:
	for c in get_children():
		if c.cur_hp <= 0:
			return true
	return false

func all_reserves_are_koed()->bool:
	for u in units:
		if u["cur_hp"] > 0:
			return false
	
	return true

func get_available_reserves()->int:
	var count = 0
	
	for u in units:
		if u["cur_hp"] > 0:
			count += 1
	
	return count
