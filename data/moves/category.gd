extends Resource

export(Resource) var type

export(int) var base_power
export(int) var accuracy = 100
export(int) var power_points

func get_name()->String:
	return resource_path.get_file().get_basename().capitalize()
