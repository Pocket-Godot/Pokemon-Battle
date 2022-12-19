extends Node2D

export(Array, Resource) var species
var units = []

func _ready():
	for r in species:
		var dict = {}
		
		dict['species'] = r
		dict['cur_hp'] = r.hp
		
		units.append(dict)
