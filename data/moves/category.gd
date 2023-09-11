extends Resource

@export var type: Resource

@export var base_power: int
@export var accuracy: int = 100
@export var power_points: int = 10

func get_move_name()->String:
	return resource_path.get_file().get_basename().capitalize()
