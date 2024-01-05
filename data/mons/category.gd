extends Resource

@export var front: Texture2D
@export var back: Texture2D

@export var type1: Resource
@export var type2: Resource

@export var move1: Resource
@export var move2: Resource
@export var move3: Resource
@export var move4: Resource

@export var hp: int = 10

func get_mon_name()->String:
	return resource_path.get_file().get_basename().capitalize()
